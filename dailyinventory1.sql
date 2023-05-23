declare @datefrom varchar(20) ,
        @dateto varchar(20)


set @datefrom = '20230101'
set @dateto = '20230331'


select * From ODLN a 
inner join DLN1
WHERE CONVERT(VARCHAR,DOCDATE ,112) >='20230101'
and a.transtype in  (14,16,13,15 ) 