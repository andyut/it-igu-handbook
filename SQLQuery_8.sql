declare @datefrom varchar(20) , @dateto varchar(20) 
set @datefrom = '{{datefrom}}'
set @dateto = '{{@dateto}}'

select 
    a.U_IDU_WebTransNo ,
    a.docnum ,
    a.docentry ,
    a.docdate ,
    a.docduedate ,
    a.taxdate ,
    a.NumAtCard ,
    a.cardcode ,
    a.cardname ,
    c.GroupName ,
    a.DocCur ,
    a.DocRate ,
    a.DocTotalFC ,
    a.DocTotalSy ,

    a.U_IGU_PIBNo PIB,
    a.U_IGU_PIB_Nop NoPEN,
    a.U_IGU_PIBRemarks PIBRemarks,
    a.U_VendDO_No ,
    
    a.U_Vessel ,
    a.U_Container ,
    a.U_igu_invoice_vendor ,
    a.U_AwBillNo ,
    d.docnum receiptPO,
    d.docdate receiptPODate

from opor a
inner join ocrd b on a.cardcode = b.cardcode 
inner join ocrg c on b.groupcode = c.groupcode 
inner join opdn d on a.DocEntry = d.U_IGU_SOdocEntry

where a.canceled='N'  
and convert(varchar,a.docdate,112) between @datefrom and @dateto
AND b.cardcode in 
(

'VI0124',
'VI0068',
'VI0074'
)
/*
select * from oact where left(acctCode,4)='2140'
SELECT TOP 400  LINEMEMO, * FROM JDT1 WHERE account='2140001'
and year(refdate)='2022'
*/

--select * from ocrd where cardname like '%PAL%'
 

 select  
        d.groupname,
        a.cardcode, 
        a.cardname ,
        c.PymntGroup,
        a.LicTradNum npwp ,
        a.U_Alamat_NPWP alamatnpwp,
        a.MailAddres ,
        a.Address
 
from ocrd a 
    inner join octg c on a.GroupNum = c.groupnum 
    inner join ocrg d on a.groupcode = d.groupcode
    inner join 
    (select cardcode, count(*) icoun from opdn where convert(varchar,docdate,112)>='20200101' group by cardcode) 
    b on a.cardcode = b.CardCode


select PymntGroup , groupnum,ExtraDays  from octg