					declare @datefrom varchar(10) , 
							@dateto varchar(10)

					declare @container varchar(100) ,
							@po_number varchar(50) ,
							@vendor_invoice varchar(50),
							@vendor_do varchar(50),
							@partner varchar(50)
					set nocount on
					set @datefrom = '20221201' 
					set @dateto = '20221231' 
					set @container = '""" + container  + """' 
					set @partner = '""" + partner  + """' 
					set @vendor_do = '""" + vendor_do  + """' 
					set @vendor_invoice = '""" + vendor_invoice  + """' 
					set @po_number = '""" + po_number  + """'  
 
					select 
					'""" + "{}".format( self.env.user.company_id.id) + """' Company,
					a.U_IDU_WebTransNo ,
					a.docnum ,
					a.docentry ,
					a.canceled,
					a.docdate ,
					a.docduedate ,
					a.taxdate ,
					a.NumAtCard ,
					a.cardcode ,
					a.cardname ,
					ab.groupname customerGroup,
					a.DocCur ,
					a.DocRate ,
					a.DocTotalFC ,
					a.DocTotalSy ,
					a.U_IGU_PIBNo PIB,
					a.U_IGU_PIB_Nop NoPEN,
					a.U_IGU_PIBRemarks PIBRemarks,
					a.U_VendDO_No ,                        
					a.U_Vessel ,
					ltrim(rtrim(a.U_Container)) ,
					a.U_igu_invoice_vendor ,
					a.U_AwBillNo,
					b.docentry apdp_docentry,
					b.docnum  apdp_docnum,
					b.docdate apdp_docdate,
					case isnull(b.docentry,0) when 0 then 0 else 1 end apdp_satus,
					c.docentry grpo_docentry,
					c.docnum grpo_docnum,
					c.docdate grpo_docdate,
					case isnull(c.docentry,0) when 0 then 0 else 1 end grpo_satus ,
					e.docdate , e.docnum 
					from opor a
					inner join ocrd aa on a.cardcode = aa.cardcode 
					inner join ocrg ab on aa.groupcode  = ab.groupcode 
					LEFT OUTER JOIN ODPO b on convert(varchar,a.docentry) = isnull(b.U_IGU_SOdocEntry,'')and b.CANCELED='N'
					LEFT OUTER JOIN OPDN C on convert(varchar,a.docentry) = isnull(C.U_IGU_SOdocEntry,'') and c.CANCELED='N'
					LEFT OUTER JOIN 
					(

					select  c.U_IGU_SOdocEntry docentry ,
					a.docnum ,
					a.docdate ,
					a.cardcode ,
					a.cardname ,
					b.SumApplied ,
					c.objtype , 
					c.U_IGU_SOdocEntry
					from ovpm a 
					inner join vpm2 b on a.docentry = b.docnum and a.canceled='N'
					inner join 
					(
					select docentry , objtype, docdate,U_IGU_SOdocEntry from ODPO where convert(varchar,docdate,112) between @datefrom and @dateto and canceled='N'
					union ALL 
					select docentry , objtype,docdate, U_IGU_SOdocEntry from OPCH where convert(varchar,docdate,112) between @datefrom and @dateto  and canceled='N'
					) as c on b.docentry = c.docentry and b.invtype = c.objtype 

					)	as	E on a.docentry = e.U_IGU_SOdocEntry
					where convert(varchar,a.docdate,112) 
					between @datefrom and @dateto