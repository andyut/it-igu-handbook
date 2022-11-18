 DECLARE 
		@DATEFROM varchar(10),
		@DATETO varchar(10) ,
		@partner varchar(50),
        @company varchar(50)


SET @DATEFROM = '20220101'
SET @DATETO = '20220331'
SET @PARTNER =''
SET @COMPANY = 'IGU'
select	 
        @company,
        LEFT(A.ACCOUNT,1) ACCOUNT, 
		f.groupname  ,
		d.cardcode, 
		d.cardname ,
		sum(a.debit-a.credit) balance 

From jdt1 a
	inner join  [dbo].[@IGU_TRANSTYPE] b on a.transtype = b.code
	inner join oact c on a.account = c.acctcode 
 left outer join 
		 (
			select a.ObjType, a.docnum , a.docentry, a.canceled,a.docdate,a.cardcode,a.cardname,a.NumAtCard,a.Comments ,a.U_IGU_PIBNo , a.U_IGU_PIB_Nop, a.U_PI_No, a.U_Container, a.u_vessel from orpc a  where left(convert(varchar,a.docdate,112),8) between @DATEFROM and @DATETO 
				union all 
			select a.ObjType,a.docnum , a.docentry, a.canceled,a.docdate,a.cardcode,a.cardname,a.NumAtCard,a.Comments,a.U_IGU_PIBNo , a.U_IGU_PIB_Nop, a.U_PI_No, a.U_Container, a.u_vessel  from opch a   where left(convert(varchar,a.docdate,112),8) between @DATEFROM and @DATETO 
				union all 
			select a.ObjType,a.docnum , a.docentry, a.canceled,a.docdate,a.cardcode,a.cardname,a.NumAtCard,a.Comments,a.U_IGU_PIBNo , a.U_IGU_PIB_Nop, a.U_PI_No, a.U_Container, a.u_vessel  from opdn a   where left(convert(varchar,a.docdate,112),8) between @DATEFROM and @DATETO 
				union all 
			select a.ObjType,a.docnum , a.docentry, a.canceled,a.docdate,a.cardcode,a.cardname,a.NumAtCard,a.Comments,a.U_IGU_PIBNo , a.U_IGU_PIB_Nop, a.U_PI_No, a.U_Container, a.u_vessel  from orpd a   where left(convert(varchar,a.docdate,112),8) between @DATEFROM and @DATETO 
				union all 
			select a.ObjType,a.docnum, a.docentry,a.canceled,a.docdate,a.cardcode,a.SuppName,a.Ref1,a.JdtMemo,'' U_IGU_PIBNo , '' U_IGU_PIB_Nop, '' U_PI_No, '' U_Container, '' u_vessel   from oipf a   where left(convert(varchar,a.docdate,112),8) between @DATEFROM and @DATETO 

		 )as d on a.TransType = d.ObjType and a.CreatedBy = d.DocEntry
 INNER JOIN ocrd e on d.cardcode = e.cardcode 
 INNER JOIN ocrg f on e.groupcode = f.groupcode 
where a.transtype in (20,19,21,18,69) 
and left(convert(varchar,a.refdate,112),8) between @DATEFROM and @DATETO
and (left(a.account,1)='5' or left((a.account),4)='1190')
and upper((e.cardcode + e.cardname)) like '%'+ upper(replace(@partner,' ','%'))  + '%'

group by 
        LEFT(A.ACCOUNT,1) ,
        d.cardcode, 
		d.cardname ,
		f.groupname  
order by 
		f.groupname  ,
		d.cardcode, 
		d.cardname 

 