select  b.U_Group ,
        B.itemcode ,
        b.itemname ,
        sum(a.OnHand) Quantity ,
        avg(a.AvgPrice) price ,
        sum(a.StockValue) total ,
        upper(b.InvntryUom) Uom
from oitw a 
inner join oitm b on a.itemcode =b.itemcode 
where b.InvntItem='Y'
and a.OnHand<>0
group by b.U_Group ,
        B.itemcode ,
        b.itemname,upper(b.InvntryUom) 
order by    b.U_Group ,
            B.itemcode ,
            b.itemname