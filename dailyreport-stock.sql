                            declare 
                            
                                    @datefrom varchar(10) , 
                                    @dateto varchar(10) , 
                                    @item varchar(50) ,
                                    @group varchar(50),
                                    @company varchar(50)




                            set @datefrom = '20230301'
                            set @dateto = '20230331'
                            set @item = ''
                            set @group = ''

                            set @company = 'IGU'

                            select 
                                    @company Company,
                                    @datefrom DateFrom,
                                    @dateto Dateto,
                                    B.U_PERTANIAN ,
                                    
                                    SUM ( CASE when convert(varchar,a.docdate,112)< @datefrom then  (A.INQTY - a.OUTQTY) else 0 end ) OpeningBalanceQty,

                                    SUM ( CASE when convert(varchar,a.docdate,112)between  @datefrom  and @dateto
                                                    and a.transtype in ( 20,19,21,18,69 ) 
                                                then  (A.INQTY - a.OUTQTY) else 0 end ) PembelianQty,


                                    SUM ( CASE when convert(varchar,a.docdate,112)between  @datefrom  and @dateto
                                                    and a.transtype in (14,16,13,15 ) 
                                                then  (A.INQTY - a.OUTQTY) else 0 end ) PenjualanQty,

                                    SUM ( CASE when convert(varchar,a.docdate,112)between  @datefrom  and @dateto
                                                    and a.transtype in (67) 
                                                then  (A.INQTY - a.OUTQTY) else 0 end ) InventoryTransferQty, 

                                    SUM ( CASE when convert(varchar,a.docdate,112)between  @datefrom  and @dateto
                                                    and a.transtype in (-2,58,60,162,59 ) 
                                                then  (A.INQTY - a.OUTQTY) else 0 end ) AdjustmentQty, 

                                    SUM ( CASE when convert(varchar,a.docdate,112)between  @datefrom  and @dateto
                                                    and a.transtype in (10000071) 
                                                then  (A.INQTY - a.OUTQTY) else 0 end ) SAPOpnameQty, 

                                    SUM ( CASE when convert(varchar,a.docdate,112)<= @dateto then  (A.INQTY - a.OUTQTY) else 0 end ) EndingBalanceQty
                            from OINM (NOLOCK)A
                                INNER JOIN OITM (NOLOCK) B ON A.ITEMCODE = B.ITEMCODE  
                            where 
                                convert(varchar,a.docdate,112) <=@dateto
                                and a.itemcode + b.itemname like '%' + isnull(@item,'') +'%' 
                             AND ISNULL(B.U_PERTANIAN,'')<>''
                            group by 
                            B.U_PERTANIAN
                            order by 
                            B.U_PERTANIAN