						declare @datefrom varchar(20), @dateto varchar(20) ,@arperson varchar(20)
						declare @cardname varchar(50), @account varchar(10)

						declare @table table (   docentry int ,
												docdate varchar(10),			
												documentdate varchar(10),						
                                                docduedate varchar(10)	,						
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
												ppn numeric(19,6),
                                                DocType varchar(100),
                                                DocSubType varchar(100),
                                                U_TF_date varchar(100),
                                                U_LT_No  varchar(100),
                                                U_RemDelay varchar(200),
                                                U_No_Giro varchar(200),
                                                U_Tgl_Jt_Tempo_Giro varchar(100),
                                                U_IGU_Checklist varchar(100),
                                                U_IGU_checklistdate varchar(100),
                                                U_Cust_GR_No varchar(100),
												arperson varchar(50),
                                                transtype varchar(100),
												topcount int ,
												topdesc varchar(200),
												datediff numeric(19,2),
												denda numeric(19,2),
												dendastatus varchar(5)
												)

						set @datefrom = '20230501'
						set @cardname = ''
					    set @ACCOUNT = '1130001'
						set @arperson = 'DEWI'
						insert into @table 
						select  
                                a.docentry ,  
								convert(varchar,a.docdate,23) docdate , 
								convert(varchar,a.taxdate,23) taxdate , 
								convert(varchar,a.docduedate,23) Docduedate , 
								a.docnum , 
								a.numatCard,
								a.U_Kw_No ,
								a.U_IDU_FPajak ,
								a.cardcode, 
								b.cardname,
								a.shiptocode,
								a.DocTotal , 
								a.DocTotal - a.paidsys balance,
								ISNULL(A.U_CUST_PO_NO,'') po ,
								a.doctotal - a.vatsum amount, 
								a.vatsum ppn ,
                                a.DocType doctype,
                                a.DocSubType docsubtype,
                                a.U_TF_date tf_date,
                                a.U_LT_No Penagihan_No,
                                a.U_RemDelay DelayRemarks,
                                a.U_No_Giro ,
                                a.U_Tgl_Jt_Tempo_Giro ,
                                a.U_IGU_Checklist ,
                                a.U_IGU_checklistdate ,
                                a.U_Cust_GR_No,
								b.U_AR_Person ,
								'Invoice' transtype ,
								d.ExtraDays topcount,
								d.PymntGroup ,
								DATEDIFF(day, a.docduedate,DATEADD(day,a.docduedate,7)),
								0,
								'N'

								

						from oinv a
						inner join ocrd b on a.cardcode = b.cardcode 
						inner join ocrg c on b.GroupCode = c.GroupCode 
						inner join octg d on b.GroupNum = d.GroupNum
						where a.canceled='N' and a.DocStatus='O' 
						and a.ctlAccount = @Account 
						and a.cardcode + a.cardname like '%' +  @cardname + '%'
						and isnull(B.U_AR_Person,'')  like '%' +  @arperson + '%'
						and (a.DocTotal - a.paidsys)<>0 
						and convert(varchar,a.docdate,112) <= @datefrom


						insert into @table 
						select  
                                a.docentry ,
                                convert(varchar,a.docdate,23) docdate , 
								convert(varchar,a.taxdate,23) taxdate , 
								convert(varchar,a.docduedate,23) docduedate , 
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
                                a.DocType doctype,
                                a.DocSubType docsubtype,
                                a.U_TF_date tf_date,
                                a.U_LT_No Penagihan_No,
                                a.U_RemDelay DelayRemarks,
                                a.U_No_Giro ,
                                a.U_Tgl_Jt_Tempo_Giro ,
                                a.U_IGU_Checklist ,
                                a.U_IGU_checklistdate ,
                                a.U_Cust_GR_No,
								b.U_AR_Person ,
								'CN' doctype,
								b.U_AR_Person,
								d.ExtraDays topcount,
								d.PymntGroup ,
								DATEDIFF(day, a.docduedate,DATEADD(day,a.docduedate,7)),
								0,
								'N'
						from orin a
						inner join ocrd  b on a.cardcode = b.cardcode 
						inner join ocrg c on b.GroupCode = c.GroupCode 
						inner join octg d on b.GroupNum = d.GroupNum
						where a.canceled='N' and a.DocStatus='O' 
						and a.ctlAccount = @Account 
						and a.cardcode + a.cardname  like '%' +  @cardname + '%'
						and isnull(B.U_AR_Person,'')  like '%' +  @arperson + '%'
						and (a.DocTotal - a.paidsys)<>0
						and convert(varchar,a.docdate,112) <= @datefrom

						insert into @table 
						select  a.transid , 
								convert(varchar,a.refdate,23) docdate , 
								convert(varchar,a.taxdate,23) taxdate , 
								convert(varchar,a.duedate,23) duedate , 
								e.number Docnum  , 
								e.number numatCard,
								isnull(e.u_trans_no,'') +'-' + a.LineMemo U_Kw_No ,
								'' U_IDU_FPajak ,
								a.ShortName, 
								b.cardname,
								b.shiptodef,
								(a.BalScDeb - a.BalScCred ), 
								(a.BalScDeb - a.BalScCred) balance,
								''  po ,
								(a.BalScDeb - a.BalScCred) amount, 
								0 ppn ,
                                ''  doctype,
                                ''   docsubtype,
                                '' tf_date,
                                ''  Penagihan_No,
                                ''  DelayRemarks,
                                '' U_No_Giro ,
                                '' U_Tgl_Jt_Tempo_Giro ,
                                '' U_IGU_Checklist ,
                                '' U_IGU_checklistdate ,
                                '' U_Cust_GR_No,
								b.U_AR_Person ,
								'UnReconsile' trasntype,
								d.ExtraDays topcount,
								d.PymntGroup ,
								0,
								0,
								'N'

								

						from JDT1 a
						inner join ocrd b on a.ShortName = b.cardcode and a.TransType in (24,30)
						inner join ocrg c on b.GroupCode = c.GroupCode 
						inner join octg d on b.GroupNum = d.GroupNum
                        inner join ojdt e on a.transid = e.transid 
						where  b.cardcode + b.cardname like '%' +  @cardname + '%'
						and isnull(B.U_AR_Person,'')  like '%' +  @arperson + '%'
						and a.Account = @Account 
						and (a.BalScDeb - a.BalScCred)<>0 
						and convert(varchar,a.refdate,112) <= @datefrom

						select  *,'""" + comp.code_base + """' company from @table    
						order by docdate ,docnum             
			--