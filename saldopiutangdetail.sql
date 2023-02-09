						declare @datefrom varchar(20), @dateto varchar(20) 
						declare @cardname varchar(50)

						declare @table table (  idx int identity(1,1),
												docdate varchar(10),													
												docnum varchar(20) ,
												numatcard varchar(200)  ,
												kwitansi varchar(200) ,
												fp varchar(50) ,
												cardcode varchar(20),
												cardname varchar(100),
												shipto 	varchar(100),
												amount numeric(19,6) ,
												balance numeric(19,6),
												po varchar(100) ,
												dpp numeric(19,6) ,
												ppn numeric(19,6),doctype varchar(10))

						set @datefrom = '20230115'
						set @cardname = 'RC0021'
						set nocount ON
						insert into @table 
						select   
								convert(varchar,a.docdate,23) docdate , 
								c.U_Trans_No Docnum  , 
								a.linememo numatCard,
								'-'U_Kw_No ,
								'' U_IDU_FPajak ,
								a.ShortName, 
								b.cardname,
								b.shiptodef,
								(a.BalScDeb - a.BalScCred ), 
								(a.BalScDeb - a.BalScCred balance,
								''  po ,
								(a.BalScDeb - a.BalScCred) amount, 
								0 ppn ,
								'Payment' doctype
								

						from JDT1 a
						inner join ocrd b on a.ShortName = b.cardcode and a.TransType in (24,30)
                        inner join ojdt c on a.transid = c.transid 
						where  b.cardcode + b.cardname like '%' +  @cardname + '%'
						and (a.BalScDeb - a.BalScCred)<>0 
						and convert(varchar,a.refdate,112) <= @datefrom

						insert into @table 
						select  convert(varchar,a.docdate,23) docdate , 
								a.docnum , 
								a.numatCard,
								a.U_Kw_No ,
								a.U_IDU_FPajak ,
								a.cardcode, 
								b.cardname,
								a.shiptocode,
								-1 * (a.DocTotal) , 
								-1 * (a.DocTotal - a.paidsys) ,
								ISNULL(A.U_CUST_PO_NO,''),
								-1 * (a.doctotal - a.vatsum) amount, 
								-1 * (a.vatsum) ppn,
								'CN' doctype
						from orin a
						inner join ocrd  b on a.cardcode = b.cardcode 
						where a.canceled='N' and a.DocStatus='O' 
						and a.cardcode + a.cardname  like '%' +  @cardname + '%'
						and (a.DocTotal - a.paidsys)<>0
						and convert(varchar,a.docdate,112) <= @datefrom
						select  *,'""" + comp.code_base + """' company from @table                
			

select top 40 * from jdt1 where account ='1130001'