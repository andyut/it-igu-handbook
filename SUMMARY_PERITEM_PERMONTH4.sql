declare @dateto varchar(20) ,
        @customer varchar(50) ,
        @salesperson varchar(50)

set @dateto =  '""" + self.dateto.strftime("%Y")   + """'
set @customer ='""" + cardname   + """'
set @salesperson =  '""" + salesperson   + """' 

							select 
								'""" + str(comp.name) + """' company_id,
								SalesGroup,
								SalesPerson,
								u_group,
								SUM(ijan) jan ,
								SUM(ifeb) feb ,
								SUM(imar) mar ,
								SUM(iapr) apr ,
								SUM(imay) may ,
								SUM(ijun) jun ,
								SUM(ijul) jul ,
								SUM(iags) ags ,
								SUM(isep) sep ,
								SUM(iokt) okt ,
								SUM(inov) nov ,
								SUM(ides) des ,
								SUM(Total)Total 
							from 
							(
							select  isnull(c.memo,'NoGroup') SalesGroup,
									c.slpName + ' ' + isnull(c.u_slsEmpName,'') SalesPerson,
									f.u_group u_group,
								SUM(case month(a.docdate) when 1 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum )  else 0 end) ijan ,
								SUM(case month(a.docdate) when 2 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) ifeb ,
								SUM(case month(a.docdate) when 3 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) imar ,
								SUM(case month(a.docdate) when 4 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) iapr ,
								SUM(case month(a.docdate) when 5 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) imay ,
								SUM(case month(a.docdate) when 6 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) ijun ,
								SUM(case month(a.docdate) when 7 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) ijul ,
								SUM(case month(a.docdate) when 8 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) iags ,
								SUM(case month(a.docdate) when 9 then  e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) isep ,
								SUM(case month(a.docdate) when 10 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) iokt ,
								SUM(case month(a.docdate) when 11 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) inov ,
								SUM(case month(a.docdate) when 12 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) ides ,
								SUM( e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ))    Total 

							from oinv a 
								inner join ocrd b on a.cardcode = b.cardcode 
								inner join oslp c on b.slpcode = c.slpcode 
								inner join ocrg d on b.groupcode = d.groupcode
								inner join inv1 e on a.docentry = e.docentry 
								inner join oitm f on e.itemcode = f.itemcode 
							where 
							a.canceled = 'N'
							and year(a.docdate) = @dateto 
							and  b.cardcode + b.cardname like '%' + isnull( @customer,'') + '%'
							and  c.slpname like '%' + @salesperson + '%'

							group by    isnull(c.memo,'NoGroup') ,
										c.slpName + ' ' + isnull(c.u_slsEmpName,'') ,
										f.u_group 
							union all 
							select      isnull(c.memo,'NoGroup') ,
										c.slpName + ' ' + isnull(c.u_slsEmpName,'')  ,
										f.u_group ,
								-1* SUM(case month(a.docdate) when 1 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) ijan ,
								-1* SUM(case month(a.docdate) when 2 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) ifeb ,
								-1* SUM(case month(a.docdate) when 3 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) imar ,
								-1* SUM(case month(a.docdate) when 4 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) iapr ,
								-1* SUM(case month(a.docdate) when 5 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) imay ,
								-1* SUM(case month(a.docdate) when 6 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) ijun ,
								-1* SUM(case month(a.docdate) when 7 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) ijul ,
								-1* SUM(case month(a.docdate) when 8 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) iags ,
								-1* SUM(case month(a.docdate) when 9 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) isep ,
								-1* SUM(case month(a.docdate) when 10 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) iokt ,
								-1* SUM(case month(a.docdate) when 11 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) inov ,
								-1* SUM(case month(a.docdate) when 12 then e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ) else 0 end) ides ,
								-1* SUM( e.linetotal - ((e.linetotal / ( a.doctotal -a.vatsum+a.DiscSum))*a.DiscSum ))    Total 

							from orin a 
								inner join ocrd b on a.cardcode = b.cardcode 
								inner join oslp c on b.slpcode = c.slpcode 
								inner join ocrg d on b.groupcode = d.groupcode
								inner join rin1 e on a.docentry = e.docentry 
								inner join oitm f on e.itemcode = f.itemcode 
							where 
							a.canceled = 'N'
							and year(a.docdate) = @dateto 
							and  b.cardcode + b.cardname like '%' + isnull( @customer,'') + '%'
							and  c.slpname like '%' + @salesperson + '%'

							group by    isnull(c.memo,'NoGroup') ,
										c.slpName + ' ' + isnull(c.u_slsEmpName,'') ,
										f.u_group 
							) as a 
							group by    SalesGroup,
								SalesPerson ,
								u_group 
							order by    SalesGroup,
								SalesPerson,
								u_group 