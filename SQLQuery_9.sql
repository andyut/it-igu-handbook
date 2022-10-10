

select  
        bb.docnum PO,
        b.docnum APInvoice, 
        convert(varchar,a.refdate,23) refdate,
        convert(varchar,b.DocDueDate,23) ETA, 
        convert(varchar,b.TaxDate,23) ReqPaymentDate,
        isnull(a.FCCurrency,'IDR') curr,
        b.cardcode ,
        c.cardname ,
        d.groupname ,
        a.fccredit - a.fcdebit AmountFC,
        a.credit - a.debit  AmountLC,
        a.BalScCred - a.BalScDeb  BalanceLC,
        a.BalFCCred - a.BalFCDeb BalanceFC
From jdt1 a 
left outer join opch b on a.CreatedBy = b.docentry and a.TransType=18 
left outer join opor bb on b.u_igu_soDocentry  = bb.docentry 
left outer join ocrd c on b.cardcode = c.cardcode 
left outer  join ocrg d on c.groupcode = d.groupcode
where a.account ='2110001'
--and left(convert(varchar,a.refdate,112),4)='2022'

and transtype in (19,18)
and b.canceled= 'N'
and a.BalScCred - a.BalScDeb<>0




--select  *from oact where LocManTran = 'Y'

 




select   a.docnum, a.docdate, a.cardcode, a.cardname ,isnull(a.DocCur,'IDR'), a.DocTotalFC,a.DocTotalSy,a.PaidSumFc , a.PaidSumSc  from odpo a where a.DocTotalSy - a.PaidSumSc <>0 
union all 
select   a.docnum, a.docdate, a.cardcode, a.cardname ,isnull(a.DocCur,'IDR'), a.DocTotalFC,a.DocTotalSy,a.PaidSumFc , a.PaidSumSc  from opch a where a.DocTotalSy - a.PaidSumSc <>0 


