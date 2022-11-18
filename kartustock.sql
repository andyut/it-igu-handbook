
					declare @datefrom varchar(10) , 
							@dateto varchar(10)

					declare @container varchar(100) ,
							@po_number varchar(50) ,
							@vendor_invoice varchar(50),
							@vendor_do varchar(50),
							@partner varchar(50)
					set nocount on
					set @datefrom = '20220801' 
					set @dateto = '20221031' 
					set @container = '' 
					set @partner = '' 
					set @vendor_do = '' 
					set @vendor_invoice = '' 
					set @po_number = ''  

					select 
						'IGU' Company, 
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
						a.DocCur ,
						a.DocRate ,
						a.DocTotalFC ,
						a.DocTotalSy ,
						a.U_IGU_PIBNo PIB,
						a.U_IGU_PIB_Nop NoPEN,
						a.U_IGU_PIBRemarks PIBRemarks,
						a.U_VendDO_No ,                        
						a.U_Vessel ,
						a.U_Container ,
						a.U_igu_invoice_vendor ,
						a.U_AwBillNo ,
                        b.docentry ,
                        b.docnum ,
                        b.docdate
					from opor a
                    LEFT OUTER JOIN ODPO b on convert(varchar,a.docentry) = isnull(b.U_IGU_SOdocEntry,'')
                    LEFT OUTER JOIN OPDN C on convert(varchar,a.docentry) = isnull(C.U_IGU_SOdocEntry,'')
                    LEFT OUTER JOIN OPCH d on convert(varchar,a.docentry) = isnull(d.U_IGU_SOdocEntry,'')
                    
					where a.canceled='N'        
					and convert(varchar,a.docdate,112) 
					  between @datefrom and @dateto
 