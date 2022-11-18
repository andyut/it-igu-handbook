declare @datefrom varchar(20) ,
        @dateto varchar(20) ,
        @vendor varchar(50) ,
        @account varchar(20),
        @company varchar(100)

set @datefrom = '2022-03-01'
set @dateto = '2022-03-31'
set @vendor =''
set @account = '2110001' 
set @company = 'INDOGUNA'
/*
select  top 50 a.* from jdt1 a 
inner join ojdt b on a.Transid = b.transid 
inner join ocrd c on a.shortname  = c.cardcode 
inner join ocrg d on c.groupcode = d.groupcode
where a.account = @account 
and convert(varchar,a.refdate ,23 ) between @datefrom and @dateto
*/

select '000-OPENING BALANCE' TransNumber ,
        @datefrom refdate, 
        '00-OPENING BALANCE' TransName ,
            d.groupname ,
            c.cardcode ,
            c.cardname ,
            sum(a.debit) debit ,
            sum(a.credit) credit ,
            sum(a.credit - a.debit) amount ,
            case when isnull(a.fcCurrency,'IDR') ='IDR' then 'IDR' else a.fccurrency end currency,
            sum(case when isnull(a.fcCurrency,'IDR') = 'IDR' then a.credit - a.debit  else  a.fccredit - a.fcdebit end ) FCAmount ,
            sum(a.BalScCred - a.BalScDeb) balance,
            'Opening Balance AP 'linememo ,
            ' - ' ref1 , ' - '  ref2
from jdt1 a 
inner join ojdt b on a.Transid = b.transid 
inner join ocrd c on a.shortname  = c.cardcode 
inner join ocrg d on c.groupcode = d.groupcode
left outer join [@igu_transtype] e on a.transtype = e.code 
where a.account = @account 
and convert(varchar,a.refdate ,23 ) between @datefrom and @dateto        
group by 
            d.groupname ,
            c.cardcode ,
            c.cardname ,
            case when isnull(a.fcCurrency,'IDR') ='IDR' then 'IDR' else a.fccurrency end 
union ALL

select   
            isnull(b.u_trans_no,b.number) TransNumber,
            convert(varchar,a.refdate,23) refdate ,
            convert(varchar,a.transtype) + '-' + isnull(e.name,'') transName,
            d.groupname ,
            c.cardcode ,
            c.cardname ,
            a.debit ,
            a.credit ,
            a.credit - a.debit amount ,
            case when isnull(a.fcCurrency,'IDR') ='IDR' then 'IDR' else a.fccurrency end currency,
            case when isnull(a.fcCurrency,'IDR') = 'IDR' then a.credit - a.debit  else  a.fccredit - a.fcdebit end FCAmount ,
            a.BalScCred - a.BalScDeb balance,
            a.linememo ,
            a.ref1 , a.ref2
from jdt1 a 
inner join ojdt b on a.Transid = b.transid 
inner join ocrd c on a.shortname  = c.cardcode 
inner join ocrg d on c.groupcode = d.groupcode
left outer join [@igu_transtype] e on a.transtype = e.code 
where a.account = @account 
and convert(varchar,a.refdate ,23 ) between @datefrom and @dateto