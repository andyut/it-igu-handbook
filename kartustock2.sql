                    declare @company varchar(50) 
                    declare @datefrom varchar(20) 
                    declare @dateto varchar(20) 

                    set @company ='Indoguna'
                    set @datefrom = '2022-01-01'
                    set @dateto = '2022-03-31'

                    select
											
                                            @datefrom docdate, 
                                            '00-OPENING BALANCE' TransName, 
                                            '-Opening' cardname,
                                            '-Opening Balance' Linememo,
                                            c.ItemCode,
											c.ItemName, 
											c.U_Group ,
											c.U_SubGroup ,
                                            c.invntryUom,
											sum(b.LayerInQty - b.LayerOutQ) Quantity, 
                                            0 price ,
                                            0 calcPrice,
											sum(b.transValue) 
								from oivl as  a 
									inner join ivl1 as b on a.TransSeq = b.TransSeq
									inner join oitm c on a.ItemCode = c.ItemCode

								where convert(varchar,a.docdate,112)<=@dateto   
								group by    c.ItemCode,
											c.ItemName, 
											c.U_Group ,
											c.U_SubGroup  ,c.invntryUom
								having    sum(b.transValue) <>0		
                    union all
                    select  
                            convert(varchar,a.docdate,23) docdate,
                            convert(varchar,a.transtype) + '-' + isnull(c.name ,'') transname ,
                            a.cardname , 
                            isnull(a.base_ref,'')+ '-'  + isnull(a.comments,'') ,
                            b.itemcode,
                            b.ItemName, 
                            b.U_Group ,
                            b.U_SubGroup ,
                            b.invntryUom,
                            (a.inqty  - a.outqty) Quantity, 
                            a.price price ,
                            a.calcprice calcPrice,
                            (a.transValue) 

                    from oinm A
                    inner join oitm b on a.itemcode = b.itemcode 
                    left outer join [@igu_transtype] c on a.transtype = c.code
                    where convert(varchar,a.docdate,23) between @datefrom and @dateto

                