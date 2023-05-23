select   a.transid ,
        b.Line_ID ,
        a.U_FP
from opch a 
inner join jdt1  b on a.transid = b.transid 

where isnull(U_FP,'')<>''
and left(convert(varchar,a.docdate,112),4) ='2023'