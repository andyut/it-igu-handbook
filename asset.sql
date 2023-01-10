SELECT * FROM ITM8 WHERE ITEMCODE ='KEN0055'
SELECT  OITM."ItemCode", 
        OITM."ItemName", 
        OITM."FrgnName", 
        OITM."CapDate", 
        nc.APC AS "Acquisition Cost", 
        Dep."dep" +"Spdep" AS "Accum Dep", 
        "SALvl" AS "Salvage", 
        dm."rtr" AS "RetirementValue", 
        nc.APC - (Dep."dep" + "Spdep") -dm."rtr" AS "Profit/Loss"

FROM OITM
INNER JOIN (SELECT "ItemCode", SUM("OrDpAcc") AS "ordpacc" 
FROM ITM8
GROUP BY "ItemCode") AS APC ON APC."itemcode" = OITM."ItemCode"
INNER JOIN (SELECT "ItemCode", SUM("OrdDprPost") AS "dep", SUM("SpDprPost" + "OrdDprPst1") AS "Spdep"
FROM ODPV
GROUP BY "ItemCode") AS DEP ON DEP."itemcode" = OITM."ItemCode"
INNER JOIN (SELECT "ItemCode", SUM(T0.APC) AS "APC"
FROM "FIX1" T0
WHERE t0."TransType" = '110'
GROUP BY "ItemCode") AS nc ON nc."itemcode" = OITM."ItemCode"
INNER JOIN (SELECT "ItemCode", SUM(a0."SalvageVal") AS "SALvl", SUM("TransAmnt") AS "a"
FROM "FIX1" a0
INNER JOIN "OFIX" a1 ON a1."AbsEntry" = a0."AbsEntry"
GROUP BY "ItemCode") AS d ON d."itemcode" = OITM."ItemCode"
LEFT OUTER JOIN (SELECT "ItemCode", SUM(T0."TransAmnt") AS "Rtr"
FROM "FIX1" T0
INNER JOIN "OFIX" T1 ON T1."AbsEntry" = T0."AbsEntry" AND t0."TransType" = '210'
GROUP BY "ItemCode") AS dm ON dm."itemcode" = OITM."ItemCode"
WHERE OITM."ItemType" = 'F' and oitm.itemcode = 'KEN0055'

declare @dateto varchar(10)  
declare @before varchar(10) ,@after varchar(10) 
set @dateto = '20221115'
select @after = year(dateadd(year,1,convert(date , @dateto) ))
select @before = convert(varchar,year(convert(date , @dateto)))

select  '""" + comp.code_base + """' Company, 
        a.itemcode , 
        a.itemname ,
        @before periode,
        d.name assetCategory,
        convert(varchar,a.capdate,23) capdate,
        case when left(convert(varchar,a.capdate,112),4) = @before then 0  else  b.apc end                'Harga Perolehan' ,
        b.orDpAcc           'Akm. Penyusutan Th Lalu',        
        b.apc- b.orDpAcc    'Nilai Buku Th Lalu',        
        c.orddpramt         'Penyusutan Th. Berjalan',  
        case when left(convert(varchar,a.capdate,112),4) = @before then  e.apc else e.APC end 'Tambahan',    
        left(convert(varchar,a.capdate,112),4),
        b.apc,
        b.orDpAcc +  c.orddpramt   'Akm. Penyusutan Th. Berjalan',      
        b.apc- b.orDpAcc -  c.orddpramt 'Nilai Buku Th. Berjalan' 
from OITM A
inner join itm8 b on a.itemcode = b.itemcode  and ltrim(rtrim(b.DprArea)) like  '%Main%' and convert(varchar,periodcat) =  @before  
inner join (select  code , name from OACS) d on a.assetclass = d.code

LEFT OUTER join 
(   select itemcode,periodcat, sum(OrdDprAmt)OrdDprAmt From DRN2 a 
        inner join odrn b on a.docentry = b.docentry 
where    b.dprarea ='Main Area' and periodcat =  @before AND b.canceled='N'
group by itemcode,periodcat
)c on a.itemcode = c.itemcode and b.PeriodCat= c.PeriodCat 
left outer join 
        (
            SELECT 
                    "ItemCode", SUM(T0.APC) AS "APC"
            FROM "FIX1" T0
            WHERE 
                t0."TransType" = '110'
                and t0.DprArea='Main Area'  and year(t0.refdate)= @before
        GROUP BY "ItemCode")as  e on a.itemcode = e.itemcode 
WHERE A.ITEMCODE = 'KEN0055'

SELECT * FROM ITM8 b WHERE ITEMCODE ='KEN0055' and  ltrim(rtrim(b.DprArea)) like  '%Main%' and convert(varchar,periodcat) =  @before



select  * from OFIX A 
    INNER JOIN FIX1 B ON a.AbsEntry = b.AbsEntry
where b.ItemCode= 'KEN0055' AND b.DprArea ='Main Area'



 declare @dateto varchar(10)  
                            declare @before varchar(10) ,@after varchar(10) 
                            set @dateto = '20221118'
                            select @after = year(dateadd(year,1,convert(date , @dateto) ))
                            select @before = year(convert(date , @dateto))
                            select  'jogja' Company, 
                                    a.itemcode , 
                                    a.itemname ,
                                    @before periode,
                                    d.name assetCategory,
                                    convert(varchar,a.capdate,23) capdate,
                                    case left(convert(varchar,a.capdate,112),4) when @before then e.apc else  b.apc end                'Harga Perolehan' ,
                                    b.orDpAcc           'Akm. Penyusutan Th Lalu',        
                                    b.apc- b.orDpAcc    'Nilai Buku Th Lalu',        
                                    c.orddpramt         'Penyusutan Th. Berjalan',  
                                    case left(convert(varchar,a.capdate,112),4) when @before then  e.apc else 0 end 'Tambahan',    
                                    b.orDpAcc +  c.orddpramt   'Akm. Penyusutan Th. Berjalan',      
                                    case  left(convert(varchar,a.capdate,112),4)  = @before  then  e.apc - b.orDpAcc -  c.orddpramt 
                                            else   b.apc - b.orDpAcc -  c.orddpramt 
                                    end 'Nilai Buku Th. Berjalan' 
                            from OITM A
                            LEFT OUTER join itm8 b on a.itemcode = b.itemcode  and b.DprArea = 'Main Area' and periodcat =  @before  
                            inner join (select  code , name from OACS) d on a.assetclass = d.code
                            LEFT OUTER join 
                            (   select itemcode,periodcat, sum(OrdDprAmt)OrdDprAmt From DRN2 a 
                                    inner join odrn b on a.docentry = b.docentry 
                                where    b.dprarea ='Main Area' and periodcat =  @before AND b.canceled='N'
                            group by itemcode,periodcat
                            )c on a.itemcode = c.itemcode and b.PeriodCat= c.PeriodCat 
                            left outer join 
                                    (
                                        SELECT 
                                                "ItemCode", SUM(T0.APC) AS "APC"
                                        FROM "FIX1" T0
                                        WHERE 
                                            t0."TransType" = '110'
                                            and t0.DprArea='Main Area'  and year(t0.refdate)= @before
                                    GROUP BY "ItemCode")as  e on a.itemcode = e.itemcode 