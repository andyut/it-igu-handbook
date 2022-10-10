select top 400  * from OIVL a
    inner join ivl1 b on a.TransSeq = b.TransSeq 
    inner join owhs c on a.loccode = c.WhsCode



select * from 