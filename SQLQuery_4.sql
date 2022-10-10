select   
        a.TransNo ,
        a.SapSalesOrderId  ,f.beginstr,e.docnum,
        a.bpcode, 
        a.bpname ,
        a.refno ,
        convert(varchar,a.DocDate,23) docdate, 
        a.[Status] ,
        b.UserName usercreate ,
        c.UserName userupdate ,
        a.SalesEmployeeName ,
        a.Remarks ,
        a.CreatedDate ,
        a.ModifiedDate ,
        
        a.ApproveCrdtLimitCategory  approvalCategory ,
        a.ApproveCrdtLimitLastAgingDate ,
        a.ApproveCrdtLimitLastAgingDay ,
        a.ApproveCrdtLimitRemarks ,
        d.UserName ,
        a.ApproveCrdtLimitDate

from Tx_SalesOrder  a
inner join Tm_User b on a.CreatedUser = b.id 
left outer join Tm_User c on a.ModifiedUser = c.id 
left outer join Tm_User d on a.ApproveCrdtLimitUser = d.id 
left outer join igu_live.dbo.ordr e on a.SapSalesOrderId = e.docentry 
left outer join igu_live.dbo.nnm1 f on e.series = f.series 

where convert(varchar,a.CreatedDate ,112)= convert(varchar,'20221007',112)

and isnull(a.IsApproveCrdtLimitByPass ,'')<>''
and a.status <>'Cancel'