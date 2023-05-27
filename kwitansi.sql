declare @TABLE table(   idate varchar(10),
                        kwitansi varchar(50),
                        totalvalue numeric(19,2),
                        istatus varchar(5)
                    )


select month(a.U_kw_PrintDate ),a.U_kw_No kwitansi,
      sum(a.doctotal) ,
      case when sum(a.doctotal)>=5000000 then '1' else '0'
      end istatus,
      isnull(b.U_PrintKwitansi,'N') printkwitansi
from oinv A
inner join ocrd b on a.cardcode = b.cardcode 
where convert(varchar,a.docdate,112) >='20230101' 
group by    a.U_kw_PrintDate ,
            a.U_kw_No,
            isnull(b.U_PrintKwitansi,'N') 
having  isnull(a.U_kw_PrintDate,'')<>''


            
select U_kw_PrintDate ,printkwitansi,
        count(U_kw_No) 
        from (
select distinct U_kw_No,isnull(b.U_PrintKwitansi,'N') printkwitansi,
                month(U_kw_PrintDate)U_kw_PrintDate 
from oinv a 
inner join ocrd b on a.cardcode =b.cardcode 
where 
convert(varchar,a.docdate,112) >='20230101' 
and isnull(a.u_kw_no ,'')<>''  
and isnull(a.U_kw_PrintDate ,'')<>''  
)as a 
group by printkwitansi,U_kw_PrintDate