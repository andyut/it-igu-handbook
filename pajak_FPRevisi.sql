declare 

       @NOFAKTUR1   VARCHAR(50), 
       @NOFAKTUR2   VARCHAR(50), 
       @DATEFROM    VARCHAR(10),
       @DATETO      VARCHAR(10)
      
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
set @datefrom ='20230501'
set @dateto = '20230531'
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
 