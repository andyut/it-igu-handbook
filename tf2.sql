declare 
									@datefrom varchar(10) ,
									@dateto varchar(10) ,
									@account varchar(10) ,
									@company varchar(50)
							set @datefrom = '""" +  self.datefrom.strftime("%Y%m%d")  + """'
							set @dateto = '"""+  self.dateto.strftime("%Y%m%d")  +"""'
							SET NOCOUNT ON
							set @account = '""" + account + """'
							set @company = '""" + comp.code_base  + """'

							declare @table table (  idx int identity(1,1) ,
													company_id varchar(20) ,
													account varchar(50) ,
													docdate varchar(10) ,
													transno varchar(50) ,
													ref1 varchar(50) ,
													linememo varchar(100) ,
													debit numeric(19,2) ,
													credit numeric(19,2) ,
													balance numeric(19,2)
												)
							insert into @table 
							select @company company,* from 
							(
							select  
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
							group by a.account + ' - ' + c.acctname

							UNION ALL
							select  
									a.account + ' - ' + c.acctname account, 
									convert(Varchar,a.refdate,23) refdate, 
									B.NUMBER transnum ,
									CASE WHEN ISNULL(b.U_Trans_No,'')='' THEN CONVERT(VARCHAR,B.REF1) ELSE  ISNULL(b.U_Trans_No,'') END   ,
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
							

							DECLARE @ROWCOUNT INT , @ROWMAX INT ,@BALANCE NUMERIC(19,2)

							SET @ROWCOUNT = 1
							SELECT  @ROWMAX = COUNT(*) FROM @TABLE 
							SET @BALANCE =0
							WHILE @ROWCOUNT <= @ROWMAX 
							BEGIN
									SELECT @BALANCE = BALANCE FROM @TABLE WHERE IDX = @ROWCOUNT
									SET @ROWCOUNT = @ROWCOUNT + 1
									UPDATE @TABLE SET   BALANCE = @BALANCE + BALANCE FROM @TABLE WHERE IDX = @ROWCOUNT
									
							END 


							SELECT * FROM @TABLE ORDER BY IDX            