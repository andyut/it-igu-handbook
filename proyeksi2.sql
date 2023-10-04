							declare @period varchar(20) ,
									@slpcode varchar(10) , 
									@company varchar(100)
							set nocount on
							declare @table table ( 
													company_id varchar(50) ,
													iname varchar(100 ) ,
													iperiod varchar(100) ,
													salesperson varchar(100) ,
													slpname varchar(100) , 
													lastsales numeric(19,6)   ,
													currentsales numeric(19,6)    ,
													proyeksi numeric(19,6),
													proyeksivalue numeric(19,6),
													itarget numeric(19,6) ,
													remain numeric(19,6) ,
													targetprcnt numeric(19,6), 
													sapstatus varchar(10)
													
							)

							set @period 	= '2023'    
							set @company  	= 'IGU'  
							insert into @table 
							SELECT 
									company_id,
									iname ,
									iperiod,
									salesperson ,
									slpname , 
									sum(lastsales) ,
									sum(currentsales) ,
									proyeksi ,
									0 proyeksivalue ,
									itarget ,
									0 remain ,
									0 targetprcnt ,  
									sapstatus
							from
							( 
							select  
									@company company_id ,
									@period + '_' + convert(varchar,c.slpcode)  iname ,
									@period iperiod ,
									'[' + c.slpname + '] ' + isnull(c.U_SlsEmpName,'') salesperson ,
									c.slpcode slpname, 
									0   lastsales ,
									sum( case when convert(integer,left(convert(varchar,a.docdate,112),4) )= convert(integer, @period )  then (a.doctotal - a.vatsum ) else 0 end)   currentsales ,
									ISNULL(D.u_proyeksi ,0)  proyeksi,
									0 proyeksivalue ,
									ISNULL(D.u_target ,0)  itarget,
									0 remain ,
									0 targetprcnt, 
									case when isnull(d.code,'') = '' then 'new' else 'update' end sapstatus



							from oinv a 
							inner join ocrd b on a.cardcode = b.cardcode 
							inner join oslp c on c.slpcode = b.slpcode and isnull(c.u_itype,'Y') = 'Y'
							inner join ocrg e on b.groupcode= e.groupcode
							LEFT OUTER JOIN [@SLSPROYEKSISUMMARY] D ON @period + '_' + convert(varchar,c.slpcode)  = D.CODE  
							where a.canceled = 'N'
							and convert(varchar,a.docdate,112) between @period  + '0101' and   @period + '1231'
							and c.slpcode >0
							group by  
									@period + '_' + convert(varchar,c.slpcode), 
									ISNULL(D.u_proyeksi ,0), ISNULL(D.u_target ,0),
									'[' + c.slpname + '] ' + isnull(c.U_SlsEmpName,'')  ,
									c.slpcode, 
									case when isnull(d.code,'') = '' then 'new' else 'update' end 
							 
							union all 

							select  
									@company company_id ,
									@period + '_' + convert(varchar,c.slpcode) iname ,
									@period iperiod ,
									'[' + c.slpname + '] ' + isnull(c.U_SlsEmpName,'') salesoerson ,
									c.slpcode , 
									0  lastsales ,
									-1 * sum( case when convert(integer,left(convert(varchar,a.docdate,112),4) )= convert(integer, @period )  then (a.doctotal - a.vatsum ) else 0 end)   currentsales ,
									ISNULL(D.u_proyeksi ,0) proyeksi,
									0 proyeksivalue ,
									ISNULL(D.u_target ,0)  itarget,
									0 remain ,
									0 targetprcnt, 
									case when isnull(d.code,'') = '' then 'new' else 'update' end 


							from orin a 
							inner join ocrd b on a.cardcode = b.cardcode 
							inner join oslp c on c.slpcode = b.slpcode and isnull(c.u_itype,'Y') = 'Y'
							inner join ocrg e on b.groupcode= e.groupcode
							LEFT OUTER JOIN [@SLSPROYEKSISUMMARY] D ON @period + '_' + convert(varchar,c.slpcode)  = D.CODE  
							where a.canceled = 'N'
							and convert(varchar,a.docdate,112) between (@period)  + '0101' and   @period + '1231'
							and c.slpcode >0
							group by  
									@period + '_' + convert(varchar,c.slpcode) , ISNULL(D.u_proyeksi ,0), ISNULL(D.u_target ,0),
									'[' + c.slpname + '] ' + isnull(c.U_SlsEmpName,'')  ,
									c.slpcode , 
									case when isnull(d.code,'') = '' then 'new' else 'update' end 
							union all
                            select  
									@company company_id ,
									@period + '_' + convert(varchar,c.slpcode) iname ,
									@period iperiod ,
									'[' + c.slpname + '] ' + isnull(c.U_SlsEmpName,'') salesoerson ,
									c.slpcode , 
									a.U_amount Amount ,
									0  currentsales ,
									ISNULL(D.u_proyeksi ,0) proyeksi,
									0 proyeksivalue ,
									ISNULL(D.u_target ,0)  itarget,
									0 remain ,
									0 targetprcnt, 
									case when isnull(d.code,'') = '' then 'new' else 'update' end 


							from [@SALES2022] a 
							inner join ocrd b on a.U_cardcode = b.cardcode 
							inner join oslp c on c.slpcode = b.slpcode and isnull(c.u_itype,'Y') = 'Y'
							inner join ocrg e on b.groupcode= e.groupcode
							LEFT OUTER JOIN [@SLSPROYEKSISUMMARY] D ON @period + '_' + convert(varchar,c.slpcode)  = D.CODE  
                            where c.SlpCode >-1
							  
							 
							)as a 

							group by 

							company_id,
									iname ,
									iperiod,
									salesperson ,
									slpname , 
									proyeksi ,
									proyeksivalue ,
									itarget ,
									remain ,
									targetprcnt, 
									sapstatus

							
							update @table 
							set proyeksivalue = lastsales + ( lastsales * proyeksi / 100 ) ,
								remain = itarget - currentsales ,
								targetprcnt = case when itarget <>0 then  (itarget - currentsales )/ itarget * 100 else 0 end 


							select * from @table
							order by salesperson 

 