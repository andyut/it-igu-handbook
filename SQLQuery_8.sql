declare @datefrom varchar(20) , @dateto varchar(20) 

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
    a.U_AwBillNo

from opor a
inner join ocrd b on a.cardcode = b.cardcode 
inner join ocrg c on b.groupcode = c.groupcode 

where a.canceled='N'  

select * from oact where left(acctCode,4)='2140'
SELECT TOP 400  LINEMEMO, * FROM JDT1 WHERE account='2140001'
and year(refdate)='2022'