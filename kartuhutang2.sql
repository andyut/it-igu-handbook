

select 
        
        PO_NUMBER,
        AP_INVOICE,
        DOCDATE,
        TransNo,
        PaymentNo ,
        NumAtCard,
        doctotal
from (
select  
        '1' idx,
        B.DOCNUM PO_NUMBER,
        A.DOCNUM AP_INVOICE,
        CONVERT(vARCHAR,A.DOCDATE,23) DOCDATE,
        '-' TransNo,
        '' PaymentNo ,
        a.NumAtCard ,

        a.doctotal
FROM OPCH A 
INNER JOIN OPOR B ON A.U_IGU_SOdocEntry = B.DOCENTRY
where  a.CardCode =  'VL0192'
AND CONVERT(VARCHAR,A.DOCDATE,112) BETWEEN '20220101' AND '20221231'
AND A.Canceled= 'N'
union all
select '2' idx,
        D.DOCNUM PO_NUMBER,
        C.DocNum AP_INVOICE,
        CONVERT(VARCHAR,a.DOCDATE ,23)DOCDATE,
        a.U_Trans_No ,
        convert(varchar,a.DocNum) paymentno,
        a.ref1 NumAtCard ,
        b.SumApplied 
from ovpm a 
inner join vpm2 b on a.DocEntry = b.DocNum 
INNER JOIN OPCH c on b.DocEntry = c.DocEntry and c.ObjType = b.InvType 
INNER JOIN OPOR D on C.U_IGU_SOdocEntry = D.DocEntry
where a.CardCode =  'VL0192'
AND CONVERT(VARCHAR,A.DOCDATE,112) BETWEEN '20220101' AND '20221231'
AND A.Canceled= 'N'
)as a 

order by 


PO_NUMBER,
        AP_INVOICE,
        idx,
        DOCDATE