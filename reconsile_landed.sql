DECLARE @DATETO varchar(10),
        @vendor varchar(50),
        @account varchar(20)

declare @table table ( 
                        transid varchar(50) ,
                        transname varchar(100) ,
                        account varchar(50) ,
                        docnum varchar(20) ,
                        docdate varchar(20) ,
                        eta varchar(20) ,
                        reqpayment varchar(20) ,
                        cardcode varchar(20) ,
                        cardname varchar(100) ,
                        ref1 varchar(100) ,
                        taxnumber varchar(50) ,
                        fakturpajak varchar(50) ,
                        igroup varchar(20) ,
                        currency varchar(10) ,
                        balancefc numeric(19,6) ,
                        balancesy numeric(19,6) ,po_no varchar(50))

set @account = '2110001'
set @vendor =''
set @dateto = '20221231'

insert into @table 
select  A.TransId,
        'AP INVOICE' transName,
        a.account ,
        b.docnum ,
        convert(varchar,b.docdate,23) docdate ,
        convert(varchar,b.docduedate,23) ETA,
        convert(varchar,b.taxdate,23)  ReqPaymentDate,
        c.cardcode ,
        c.cardname  , 
        b.numatcard,
        c.LicTradNum taxnumber,
        b.U_IDU_FPajak, 
        d.groupname igroup ,
        b.DocCur ,
        a.BalFcCred - a.BalFcDeb ,
        a.BalScCred - a.BalScDeb ,
        convert(varchar,bb.docnum)

from JDT1 a
    inner join OPCH B On a.TransId = b.TransId and a.transtype = b.ObjType 
    left outer  join opor Bb On b.U_IGU_SOdocEntry = bb.docentry
    inner join ocrd c on b.cardcode = c.cardcode 
    inner join ocrg d on c.groupcode = d.groupcode 
where a.account = @account 
and convert(varchar,a.refdate,112)<=@DATETO
and a.BalScCred - a.BalScDeb <>0
union all
select  A.TransId,
        'AP CreditNote' transName,
        a.account ,
        b.docnum ,
        convert(varchar,b.docdate,23) docdate ,
        convert(varchar,b.docduedate,23) ETA,
        convert(varchar,b.taxdate,23)  ReqPaymentDate,
        c.cardcode ,
        c.cardname  , 
        b.numatcard,
        c.LicTradNum taxnumber,
        b.U_IDU_FPajak, 
        d.groupname igroup ,
        b.DocCur ,
        a.BalFcCred - a.BalFcDeb ,
        a.BalScCred - a.BalScDeb ,
        convert(varchar,bb.docnum)

from JDT1 a
    inner join ORPC B On a.TransId = b.TransId and a.transtype = b.ObjType 
    left outer  join opor Bb On b.U_IGU_SOdocEntry = bb.docentry
    inner join ocrd c on b.cardcode = c.cardcode 
    inner join ocrg d on c.groupcode = d.groupcode 
where a.account = @account 
and convert(varchar,a.refdate,112)<=@DATETO
and a.BalScCred - a.BalScDeb <>0

union all
select  A.TransId,
        'AP DOWNPAYMENT' transName,
        a.account ,
        b.docnum ,
        convert(varchar,b.docdate,23) docdate ,
        convert(varchar,b.docduedate,23) ETA,
        convert(varchar,b.taxdate,23)  ReqPaymentDate,
        c.cardcode ,
        c.cardname  , 
        b.numatcard,
        c.LicTradNum taxnumber,
        b.U_IDU_FPajak, 
        d.groupname igroup ,
        b.DocCur ,
        a.BalFcCred - a.BalFcDeb ,
        a.BalScCred - a.BalScDeb ,
        convert(varchar,bb.docnum)

from JDT1 a
    inner join ODPO B On a.TransId = b.TransId and a.transtype = b.ObjType 
    left outer  join opor Bb On b.U_IGU_SOdocEntry = bb.docentry
    inner join ocrd c on b.cardcode = c.cardcode 
    inner join ocrg d on c.groupcode = d.groupcode 
where a.account = @account 
and convert(varchar,a.refdate,112)<=@DATETO
and a.BalScCred - a.BalScDeb <>0


union all
select  A.TransId,
        'OUTGOING PAYMENT' transName,
        a.account ,
        b.docnum ,
        convert(varchar,b.docdate,23) docdate ,
        convert(varchar,b.docduedate,23) ETA,
        convert(varchar,b.taxdate,23)  ReqPaymentDate,
        c.cardcode ,
        c.cardname  , 
        b.U_Trans_No,
        c.LicTradNum taxnumber,
        '' FakturPajak,
        d.groupname igroup ,
        b.DocCurr ,
        a.BalFcCred - a.BalFcDeb ,
        a.BalScCred - a.BalScDeb ,
        convert(varchar,b.docnum) + '-' + isnull(b.U_Trans_No,'')  payment
from JDT1 a
    inner join OVPM B On a.TransId = b.TransId and a.transtype = b.ObjType 
    inner join ocrd c on b.cardcode = c.cardcode 
    inner join ocrg d on c.groupcode = d.groupcode 
where a.account = @account 
and convert(varchar,a.refdate,112)<=@DATETO
and a.BalScCred - a.BalScDeb <>0

union all
select  A.TransId,
        'JURNAL ENTRY' transName,
        a.account , 
        b.number ,
        convert(varchar,b.refdate,23) docdate ,
        convert(varchar,b.duedate,23) ETA,
        convert(varchar,b.taxdate,23)  ReqPaymentDate,
        c.cardcode ,
        c.cardname  , 
        b.U_Trans_No,
        c.LicTradNum taxnumber,
         '' FakturPajak,
        d.groupname igroup ,
        case isnull(a.FCCurrency,'')  when '' then 'IDR' ELSE a.FCCurrency end docur  ,
        a.BalFcCred - a.BalFcDeb  BalanceFC,
        a.BalScCred - a.BalScDeb BalanceSy  ,
        isnull(b.U_Trans_No,'') refpo

from JDT1 a
    inner join OJDT B On a.TransId = b.TransId and a.transtype = b.ObjType 
    inner join ocrd c on c.cardcode = a.shortname 
    inner join ocrg d on c.groupcode = d.groupcode 
where a.account = @account 
and convert(varchar,a.refdate,112)<=@DATETO
and a.BalScCred - a.BalScDeb <>0


select *from @table order by cardcode, docdate , transname
 