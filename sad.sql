select 
        a.DocNum ,
        a.CountDate ,
        a.Comments ,
        b.ItemCode ,
        b.ItemName ,
        B.OnHandBef,
        b.CountQty ,
        B.OnHandBef - b.CountQty diff,
        b.price ,
        b.DocTotal
from oiqr a
 inner join iqr1 b on a.DocEntry = b.DocEntry
