 
ALTER PROCEDURE [dbo].[IGU_fakturpajak002]

       @NOFAKTUR1   VARCHAR(50), 
       @NOFAKTUR2   VARCHAR(50), 
       @DATEFROM    VARCHAR(10),
       @DATETO      VARCHAR(10)
       

AS 
BEGIN

DECLARE @nomorterakhir VARCHAR(20) , 
        @nextnumber int  , 
        @nextfpajak varchar(20)  

DECLARE @TABLE TABLE ( IDX INT IDENTITY(1,1), NOSERIES VARCHAR(50), NOMOR BIGINT )
DECLARE @TABLE2 TABLE ( IDX INT IDENTITY(1,1), 
                                docentry int, 
                                docnum int ,
                                docdate date ,
                                numatcard varchar(50) ,
                                cardname varchar(100),
                                vatgroup varchar(50),
                                fpajak varchar(50)   )

DECLARE @ROWCOUNT INT , @ROWMAX INT , @SERIES VARCHAR(50), @NOMOR1 BIGINT , @NOMOR2 BIGINT  

/*
CARI NOMOR TERAKHIR
*/

    SELECT  
        @nomorterakhir = max (right(a.U_IDU_FPajak,len(a.U_IDU_FPajak)-4))
    FROM oinv a 
    WHERE 
            isnull(a.U_IDU_FPajak,'') <>'' 
    AND substring(a.U_IDU_FPajak,5,15)  
    BETWEEN  
            @NOFAKTUR1 AND @NOFAKTUR2 
    


/*
END --- CARI NOMOR TERAKHIR

*/
if isnull(@nomorterakhir,'')='' 
    begin 
        set @nomorterakhir = right(@NOFAKTUR1,8)
    end 
/*
TAMBAHIN 1 NOMOR 
*/
set @nextnumber = right('00000000' + right(@nomorterakhir ,8) + 1,8)
set @nextfpajak = left(@nomorterakhir,7) + right('00000000'+ convert(varchar,@nextnumber),8)

--select @nomorterakhir , @nextnumber , @nextfpajak 

/*
END --- TAMBAHIN 1 NOMOR 
*/
 
 
/*
    BIKIN LIST NOMOR FAKTUR
*/

SET @ROWCOUNT = 1 

SET @NOMOR1 = RIGHT(@nextfpajak ,8) 
SET @NOMOR2 = RIGHT(@NOFAKTUR2,8)
 
WHILE  @NOMOR1 <= @NOMOR2 
BEGIN 
        INSERT INTO @TABLE 
        SELECT LEFT(@NOFAKTUR1,7) + right('00000000'+ CONVERT(VARCHAR,@NOMOR1 ),8), @NOMOR1
        SET @NOMOR1 = @NOMOR1 + 1 
END 
 
/*
 END --   BIKIN LIST NOMOR FAKTUR
*/
 

insert into @TABLE2
select  distinct a.docentry,a.docnum, a.docdate,a.numatcard,a.cardname,
        case left( case left(a.cardcode,2) when 'FC' then b.VatGroup else isnull(c.VatGourpSa,b.VatGroup) end ,7) 
        when 'ppnk_01' then '010.'
        when 'ppn_01' then '010.'
        when 'PPNK_03' then '030.'
        when 'ppnk_08' then '080.'
        when 'non_bkp' then '080.'
        when 'ppnk_07' then '070.'
        when 'ppnk_04' then '040.'
        when 'ppn_04' then '040.'
        when 'PPNS8_1' then '080.'
        when 'PPNS8_2' then '080.'
        when 'PPNS8_4' then '080.'
        when 'PPNS8_5' then '080.'
        when 'PPNS8_3' then '080.' 
        end ,a.u_idu_fpajak  from oinv a  
    inner join inv1 b on a.docentry = b.docentry 
    left outer join oitm c on b.itemcode = c.itemcode
where year(a.docdate)>='2019' and isnull(a.u_idu_fpajak,'')='' and a.canceled='N'
--and b.vatgroup <>'non_bkp' 
and convert(varchar,a.docdate,112) between @datefrom and @dateto


group by a.docentry,a.docnum, a.docdate,a.numatcard,a.cardname,
        case   left( case left(a.cardcode,2) when 'FC' then b.VatGroup else isnull(c.VatGourpSa,b.VatGroup) end ,7) 
                when 'ppnk_01' then '010.'
                when 'ppn_01' then '010.'
                when 'PPNK_03' then '030.'
                when 'ppnk_08' then '080.'
                when 'non_bkp' then '080.'
                when 'ppnk_07' then '070.'
                when 'ppnk_04' then '040.'
                when 'ppn_04' then '040.'
                when 'PPNS8_1' then '080.'
                when 'PPNS8_2' then '080.'
                when 'PPNS8_4' then '080.'
                when 'PPNS8_5' then '080.'
                when 'PPNS8_3' then '080.' 
        end,a.u_idu_fpajak 
 

set @ROWCOUNT = 1
select @rowmax = count(*) from @TABLE2

while @rowcount <= @rowmax 
begin 

        update @TABLE2 
        set fpajak = a.vatgroup + b.NOSERIES
        from 
                @table2 a 
                inner join @table b on a.idx = b.IDX
        where a.idx  = @rowcount
        set @rowcount = @rowcount + 1 

end  
 
update oinv 
set U_IDU_FPajak = b.fpajak
from 
     OINV A     
     INNER JOIN @TABLE2 B ON A.docentry = b.docentry 
 
select * from @TABLE2 

--select * from @TABLE2 
end
GO
