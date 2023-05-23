SELECT  a.DocNum ,
        CONVERT(VARCHAR,a.DocDate ,23) DocDate,
        CONVERT(VARCHAR,a.DocDueDate ,23) DocDueDate ,
         CONVERT(VARCHAR,a.TaxDate ,23)  TaxDate ,
        a.CardCode ,
        a.NumAtCard ,
        a.cardname ,
        e.GroupName ,
        a.DocCur ,
        b.ItemCode ,
        b.Dscription ,
        b.Quantity ,
        b.OpenQty ,
        b.price ,
        b.LineTotal ,
        b.VatSum ,
        sum(c.Quantity) receiptQty,
        b.Quantity  - sum(c.Quantity) BALANCE
FROM OPOR A
INNER JOIN POR1 B ON A.Docentry = b.DocEntry
inner join ocrd d on a.cardcode = d.cardcode 
inner join ocrg e on d.groupcode = e.groupcode 
left outer join pdn1 c on b.DocEntry = c.BaseEntry and c.BaseType = 22 and c.BaseLine = b.LineNum 
where  a.DocCur ='IDR'
group by a.DocNum ,
        CONVERT(VARCHAR,a.DocDate ,23) ,
       CONVERT(VARCHAR,a.DocDueDate ,23) ,
        CONVERT(VARCHAR,a.TaxDate ,23)  ,
        a.CardCode ,
        a.NumAtCard ,
        e.GroupName ,
        a.cardname ,
        a.DocCur ,
        b.ItemCode ,
        b.Dscription ,
        b.Quantity ,
        b.OpenQty ,
        b.price ,
        b.LineTotal ,
        b.VatSum 

HAVING  b.Quantity  - sum(c.Quantity) >0