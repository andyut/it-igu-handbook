						declare @partner varchar(20) ,@arperson varchar(50)

						set @partner = 'SM'
						set @arperson = '' 

						select                  'IGU_LIVE' +  convert(Varchar,a.docentry) id ,  
												'IGU_LIVE' + convert(Varchar,a.docentry) name ,  
												a.cardcode , 
												a.cardname , 
												isnull(a.cardfname,'') cardfname,  
												b.groupname ,  
												isnull(a.lictradnum,'000000000000000') lictradnum ,  
												isnull(replace(replace(a.U_Alamat_NPWP ,char(13),''),char(10),''),'') alamatnpwp ,  
												upper(isnull(a.U_AR_Person,'None')) ar_person,  
												upper('['+ c.SlpName + '] ' + isnull(c.U_SlsEmpName,'')) salesperson,  
												isnull(c.memo,'') salesgroup,  
												isnull(a.U_locktimeout ,'-1') lock_limit ,  
												isnull(a.U_IGU_LockBP,'') lock_bp ,  
												D.PymntGroup ,  
												A.CreditLine ,  
												A.Balance ,  
												A.DNotesBal ,  
												A.OrdersBal ,  
												A.Phone1 ,  
												a.phone2,  
												a.Cellular ,  
												a.Fax ,  
												a.E_Mail ,  
												a.IntrntSite ,  
												a.Notes ,  
												a.CntctPrsn ,  
												a.BillToDef ,  
												replace(a.Address ,char(13),'') Address,  
												replace(a.MailAddres ,char(13),'') MailAddres  ,b60,a60,
												A.U_IDU_NIK ,
												A.U_IGU_KK ,
												A.U_IGU_SIUP ,
												A.U_IGU_TDP ,
												A.U_IGU_SKD ,
												A.U_IGU_AKTE, 
												A.U_Parent_Group,
												A.U_IGU_virtualrek,
												A.U_print_va    ,
												a.cardcode  + isnull(a.cardname,'') bpname,
												a.free_text   itext ,
                                                a.U_delivery_invoice ,
                                                a.U_PrintFaktur ,
                                                a.U_PrintKwitansi ,
                                                a.U_PrintFP ,
                                                a.U_PenagihanType,
                                                'Catatan TukarFaktur: ' + isnull(a.Notes,'')  + char(13)+'<br/>'+
                                                'Faktur Pengiriman  : ' + isnull(a.U_delivery_invoice,'N') + char(13)+'<br/>'+
                                                'Print Faktur  : ' + isnull(a.U_PrintFaktur,'Y') + char(13)+'<br/>'+
                                                'Print Kwitansi  : ' + 
                                                                            case isnull(a.U_PrintKwitansi,'N')
                                                                                    when 'N' then 'Tidak Print Kwitansi'
                                                                                    when 'Y' then 'Print Kwitansi'
                                                                                    when 'O' then 'Print Kwitansi Per Outlet'
                                                                                    when 'P' then 'Print Kwitansi Per PO '
                                                                            end + char(13)+'<br/>'+
                                                'Print Faktur Pajak  : ' + isnull(a.U_PrintFP,'N')+ char(13)+'<br/>'+
                                                'Tukar Faktur  : ' + isnull(a.U_PenagihanType,'Y') + char(13)+'<br/>' +
                                                'Lain Lain : ' + isnull(a.free_text,'')+ char(13)+'<br/>'
                                                
                                                as printsummary 
												from OCRD (NOLOCK) A   
												INNER JOIN OCRG (NOLOCK)  B ON A.GroupCode = B.GroupCode   
												INNER JOIN OSLP (NOLOCK)  C ON A.SLPCODE = C.SlpCode  
												INNER JOIN OCTG  (NOLOCK)  D ON A.GroupNum = D.GroupNum  
												left outer join 
															(

															select
																	c.cardcode ,
																	c.cardname ,
																	sum( CASE WHEN '""" +  self.env.user.company_id.code_base + """' = 'igu23' and  convert(varchar,a.refdate,112)='20221231'
																	
																	then case when convert(varchar,DATEADD(month, -2, getdate()),112)<=  convert(varchar,a.taxdate,112) then  (a.BalScDeb -a.balsccred ) else 0 end 
																	else case when convert(varchar,DATEADD(month, -2, getdate()),112)<=  convert(varchar,a.refdate,112) then  (a.BalScDeb -a.balsccred ) else 0 end
																	end) 'b60' ,
																	sum( CASE WHEN '""" +  self.env.user.company_id.code_base + """' = 'igu23' and  convert(varchar,a.refdate,112)='20221231'																	
																	then case when convert(varchar,DATEADD(month, -2, getdate()),112)>  convert(varchar,a.taxdate,112) then  (a.BalScDeb -a.balsccred ) else 0 end  
																	else  case when convert(varchar,DATEADD(month, -2, getdate()),112)>convert(varchar,a.refdate,112) then  (a.BalScDeb -a.balsccred ) else 0 end  
																	end ) 'a60' 

															from jdt1 (NOLOCK)  a 
																inner join ojdt (NOLOCK)  b on a.transid = b.transid 
																inner join ocrd (NOLOCK)  c on a.ShortName = c.cardcode 
																inner join ocrg  (NOLOCK) d on d.groupcode = c.groupcode
																INNER JOIN oslp  (NOLOCK) f on c.slpcode  = f.slpcode 
																inner join [@igu_transtype] e on a.transtype = e.code 

															where 
																	left(a.account ,3)='113' 
																	and ( c.cardtype='C' AND c.cardcode + UPPER(c.cardname) + UPPER(isnull(c.cardfname,''))+ UPPER(ISNULL(c.BillToDef,'')) like '%' + @partner  + '%' )
																	and a.BalScDeb -a.balsccred  <>0 
																	and convert(varchar,a.refdate,112)<=convert(varchar,getdate(),112)
																	and isnull(c.u_AR_Person,'') like '%' + @arperson + '%'
															group by c.cardcode ,
																	c.cardname 
															) as E on a.cardcode = e.cardcode ,
															OADM  (NOLOCK) G
												where a.cardtype='C' AND a.cardcode + UPPER(a.cardname) + upper(isnull(a.U_Parent_Group,'')) + UPPER(isnull(a.cardfname,''))+ UPPER(ISNULL(a.BillToDef,'')) like '%' + @partner  + '%' 
												and isnull(a.u_AR_Person,'') like '%' + @arperson + '%'
						