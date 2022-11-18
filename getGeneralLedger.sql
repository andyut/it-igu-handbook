SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[IGU_ACCT_GENERALLEDGER]

    @datefrom varchar(10) ,
    @dateto varchar(10) ,
    @account varchar(10) ,
    @company varchar(50)
as begin
select @company company,* from 
(
select  a.account acctcode,
        a.account + ' - ' + c.acctname account, 
        left(@datefrom,4) +'-' + substring(@datefrom,5,2) + '-' + right(@datefrom,2)  refdate, 
        '000000' transnum ,
        'Opening' U_Trans_No ,
        ' Opening' LineMemo ,
        0 DEBIT ,
        0 CREDIT  ,
        sum(a.debit - a.credit) AMOUNT
from JDT1 A 
    INNER JOIN OJDT B ON A.transid = b.transid 
    inner join OACT C ON A.ACCOUNT = C.ACCTCODE 
    LEFT OUTER JOIN OCRD d on a.U_IGU_BPID = d.cardcode
    LEFT OUTER JOIN OPRC e on a.ProfitCode= e.PrcCode
    LEFT OUTER JOIN OPRC f on a.OcrCode2= f.PrcCode

WHERE a.account like @account +'%'
AND LEFT(CONVERT(VARCHAR,A.REFDATE ,112) ,8) < @datefrom  
group by a.account,a.account + ' - ' + c.acctname

UNION ALL
select  a.account acctcode,
        a.account + ' - ' + c.acctname account, 
        convert(Varchar,a.refdate,23) refdate, 
        B.NUMBER transnum ,
        b.U_Trans_No ,
        a.LineMemo ,
        a.debit DEBIT ,
        A.credit CREDIT  ,
        a.debit - a.credit AMOUNT
from JDT1 A 
    INNER JOIN OJDT B ON A.transid = b.transid 
    inner join OACT C ON A.ACCOUNT = C.ACCTCODE 
    LEFT OUTER JOIN OCRD d on a.U_IGU_BPID = d.cardcode
    LEFT OUTER JOIN OPRC e on a.ProfitCode= e.PrcCode
    LEFT OUTER JOIN OPRC f on a.OcrCode2= f.PrcCode

WHERE a.account like @account +'%'
AND LEFT(CONVERT(VARCHAR,A.REFDATE ,112) ,8) between @datefrom and @dateto
)as a 
order by account ,refdate ,transnum

end
GO
