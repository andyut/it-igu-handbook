select top 400 
        a.TransNo , 
        a.DocDate ,
        a.ReferenceType ,
        a.Collector , 
        b.InvoiceTypeName ,
        b.InvoiceNo ,
        b.InvoiceDate ,
        b.InvoiceRefNo ,
        b.InvoiceKwitansiNo         
        ,b.*
from [dbo].[Tx_PaymentIn] a 
inner join [dbo].[Tx_PaymentIn_ArCorporate] b on a.id = b.DetId
where year(a.transdate)='2022'
and status  <>'Posted'
and a.ReferenceType <>'Payment'
and convert(a.docdate,112)