                                declare 
                                            @datefrom varchar(20),
                                            @dateto varchar(20) ,
                                            @company varchar(50) ,
                                            @item varchar(50) ,
                                            @supplier  varchar(50) ,
                                            @igroup varchar(50) 
 
                                            set @datefrom = '"""+   self.datefrom.strftime("%Y%m%d") + """' 
                                            set @dateto = '"""+   self.dateto.strftime("%Y%m%d") + """' 
                                            set @company = '"""+   comp.code_base + """' 
                                            set @item = '""" + item + """'
                                            set @supplier ='""" + partner + """'
                                            set @igroup = '""" + igroup + """'

                                declare @table table (  idx int identity(1,1)  , 
                                                        docentry int,
                                                        docnum varchar(100) ,  
                                                        grpo int ,
                                                        numatcard varchar(100))

                                declare @table2 table (  idx int identity(1,1)  , 
                                                        oipf  int,
                                                        opdn int )

                                declare @table3 table (  idx int identity(1,1)  , 
                                                        opdn  int,
                                                        bea_masuk numeric(19,2),
                                                        shipment numeric(19,2),
                                                        receiving numeric(19,2),
                                                        pib_pnbp numeric(19,2),
                                                        surveyor numeric(19,2),
                                                        h_biaya numeric(19,2),
                                                        lainlain numeric(19,2),
                                                        total numeric(19,2) ) 

                                INSERT INTO @TABLE
                                select DISTINCT A.DOCENTRY, D.DOCNUM ,c.docentry , D.NUMATCARD 
                                from OPCH (nolock)  A 
                                    INNER JOIN PCH1 (nolock)  B ON A.DOCENTRY  = B.DOCENTRY
                                    INNER JOIN PDN1 (nolock) C ON B.BASEENTRY = C.DOCENTRY AND B.BASETYPE = 20 
                                    INNER JOIN OPOR (nolock) D ON C.BASEENTRY = D.DOCENTRY AND C.BASETYPE=22 
                                
                                where  convert(varchar,a.docdate,112)between @datefrom and @dateto


                                
                                insert into  @table2 
                                select distinct a.docentry ,b.oribaBsEnt  from OIPF (nolock) a 
                                inner join ipf1 (nolock) b on a.DocEntry = b.docentry 
                                where  convert(varchar,a.docdate,112)between @datefrom and @dateto
                                order by b.oribaBsEnt

                                insert into @table3
                                select c.opdn,-1 * sum(bea_masuk) ,
                                        -1 * sum(shipment) ,
                                        -1 * sum(receiving) ,
                                        -1 * sum(pib_pnbp) ,
                                        -1 * sum(surveyor) ,
                                        -1 * sum(h_biaya) ,
                                        -1 * sum(lainlain) , 
                                        -1 *  sum(amount) from oipf (nolock) a 
                                inner join 
                                (
                                        select  a.transid, 
                                                SUM(case when a.account = '2140001' then a.debit - a.credit else 0 end )  bea_masuk,
                                                SUM(case when a.account = '2140002' then a.debit - a.credit else 0 end ) shipment,
                                                SUM(case when a.account = '2140003' then a.debit - a.credit else 0 end ) receiving,
                                                SUM(case when a.account = '2140004' then a.debit - a.credit else 0 end ) pib_pnbp,
                                                SUM(case when a.account = '2140005' then a.debit - a.credit else 0 end ) surveyor,
                                                SUM(case when a.account = '2140006' then a.debit - a.credit else 0 end ) h_biaya,
                                                SUM(case when a.account = '2140007' then a.debit - a.credit else 0 end ) lainlain,      
                                                sum(a.debit - a.credit) amount
                                        from jdt1 (nolock) a 
                                            inner join ojdt (nolock) b on a.transid = b.transid 
                                        where  convert(varchar,b.refdate,112)between @datefrom and @dateto
                                        and left(a.account,4)='2140' and a.TransType =69
                                        group by a.transid 
                                )B ON a.JdtNum = b.transid 
                                inner join @table2 c on a.docentry = c.oipf 
                                where  convert(varchar,a.docdate,112)between @datefrom and @dateto
                                group by c.opdn 

                                select 
                                        @company company,
                                    'AP Invoice',
                                    a.docentry ,
                                    a.docnum ,
                                    f.docnum PO, 
                                    f.numatcard Vendor_invoice, 
                                    a.numatcard,
                                    isnull(b.U_PI_Number,isnull(a.u_PI_NO,'')) PI_Number ,
                                    isnull(b.U_slaughterhouse,'') 'Rumah Potong/EST',
                                    a.U_Vessel ,
                                    a.U_Container ,
                                    a.U_Pesawat ,
                                    a.U_AwBillNo ,
                                    a.U_VendDO_No ,
                                    a.U_Cust_PO_No ,
                                    a.U_PL_No ,
                                    a.U_Do_No ,
                                    a.U_IGU_PIBNo ,
                                    a.U_IGU_PIB_Nop nopen,
                                    a.U_igu_invoice_vendor ,
                                    a.U_igu_ndpbm,
                                    a.docDate ,
                                    a.cardcode ,
                                    a.cardname ,
                                    a.shiptocode,
                                    h.groupname group_Vendor,
                                    k.whsname ,
                                    b.itemcode ,
                                    e.itemname ,
                                    e.U_group ,
                                    e.u_Subgroup ,
                                    e.u_country ,
                                    b.vatgroup PPn_inTrx,
                                    e.vatgourpSa PPn_inMaster,
                                    isnull(convert(varchar,e.u_hs_code),'') HSCode,
                                    isnull(convert(varchar,e.u_spegroup),'') spegroup,
                                    isnull(e.U_spec,'') U_spec, 
                                    b.Quantity ,
                                    
                                    b.Currency ,
                                    b.Rate ,
                                    b.Price ,
                                    b.TotalFrgn, 
                                    b.TotalSumSy,
                                    b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal ) LineTotal , 
                                    (isnull(i.bea_masuk,0)/(a.max1099 - a.vatsum)) * (b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal )) bea_masuk , 
                                    (isnull(i.shipment,0)/(a.max1099 - a.vatsum)) * (b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal )) shipment , 
                                    (isnull(i.receiving,0)/(a.max1099 - a.vatsum)) * (b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal )) receiving , 
                                    (isnull(i.pib_pnbp,0)/(a.max1099 - a.vatsum)) * (b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal )) pib_pnbp , 
                                    (isnull(i.surveyor,0)/(a.max1099 - a.vatsum)) * (b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal )) surveyor , 
                                    (isnull(i.h_biaya,0)/(a.max1099 - a.vatsum)) * (b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal )) h_biaya , 
                                    (isnull(i.lainlain,0)/(a.max1099 - a.vatsum)) * (b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal )) lainlain ,  
                                    (isnull(i.total,0)/(a.max1099 - a.vatsum)) * (b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal )) landed , 
                                    b.dstrbsumSc freight  ,
                                    (b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal ))+ b.dstrbsumSc + (isnull(i.total,0)/(a.max1099 - a.vatsum))* (b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal ))  Total
                                    
                                from OPCH (nolock) A 
                                inner join pch1 (nolock) b on a.docentry = b.docentry 
                                inner join oitm (nolock) e on b.itemcode = e.itemcode
                                inner join ocrd (nolock) g on a.cardcode = g.cardcode 
                                inner join ocrg (nolock) h on g.groupcode = h.groupcode 
                                inner join owhs (nolock) k on b.whscode = k.whscode
                                left outer join @table f on a.docentry = f.docentry
                                left outer join @table3 i on f.grpo = i.opdn

                                WHERE  convert(varchar,a.docdate,112)between @datefrom and @dateto
                                    and g.cardcode + g.cardname like '%' + @supplier + '%'
                                    and h.groupname like '%' + @igroup + '%' 
                                    and e.itemcode + e.itemname like '%' + @item + '%'                                 
                                    and a.canceled ='N'   
                                    and (a.max1099 - a.vatsum) <>0
                                union all
                                select @company company,
                                    'AP Credit',
                                    a.docentry ,
                                    a.docnum ,
                                    '-' PO,
                                    '' Vendor_invoice, 
                                    a.numatcard,
                                    isnull(b.U_PI_Number,isnull(a.u_PI_NO,'')) U_PI_No ,
                                    isnull(b.U_slaughterhouse,'') 'Rumah Potong/EST',
                                    a.U_Vessel ,
                                    a.U_Container ,
                                    a.U_Pesawat ,
                                    a.U_AwBillNo ,
                                    a.U_VendDO_No ,
                                    a.U_Cust_PO_No ,
                                    a.U_PL_No ,
                                    a.U_Do_No ,
                                    a.U_IGU_PIBNo ,
                                    a.U_IGU_PIB_Nop nopen,
                                    a.U_igu_invoice_vendor ,
                                    a.U_igu_ndpbm,
                                    a.docDate ,
                                    a.cardcode ,
                                    a.cardname ,
                                    a.shiptocode,
                                    h.groupname group_Vendor,
                                    k.whsname ,
                                    b.itemcode ,
                                    e.itemname ,
                                    e.U_group ,
                                    e.u_Subgroup ,
                                    e.u_country ,
                                    b.vatgroup PPn_inTrx,
                                    e.vatgourpSa PPn_inMaster,
                                    isnull(convert(varchar,e.u_hs_code),'') HSCode,
                                    isnull(convert(varchar,e.u_spegroup),'') spegroup,
                                    isnull(e.U_spec,'') ,
                                    -1 * b.Quantity ,
                                    b.Currency ,
                                    b.Rate ,
                                    -1 * b.Price ,
                                    -1 * b.TotalFrgn, 
                                    -1 * b.TotalSumSy, 
                                    -1 * (b.LineTotal - (a.DiscPrcnt/ 100 * b.LineTotal )),
                                        0 landed         ,
                                        0 landed         ,
                                        0 landed         ,
                                        0 landed         ,
                                        0 landed         ,
                                        0 landed         ,
                                        0 landed         ,
                                        0 landed         ,
                                        isnull(b.dstrbsumSc,0)  Freight ,
                                        -1 * ((b.LineTotal - (isnull(a.DiscPrcnt,0)/ 100 * b.LineTotal )) + isnull(b.dstrbsumSc,0) )
                                from orpc (nolock) A 
                                inner join rpc1 (nolock) b on a.docentry = b.docentry 
                                inner join oitm (nolock) e on b.itemcode = e.itemcode 
                                inner join ocrd (nolock) g on a.cardcode = g.cardcode 
                                inner join ocrg (nolock) h on g.groupcode = h.groupcode 
                                inner join owhs (nolock) k on b.whscode = k.whscode
                                inner join 
                                    (select distinct a.docentry from rpc1 a (nolock) 
                                        inner join orpc b on a.docentry = b.docentry 
                                        where  convert(varchar,b.docdate,112)between @datefrom and @dateto and a.basetype<>204
                                    ) c on a.docentry = c.docentry  
                                WHERE  convert(varchar,a.docdate,112)between @datefrom and @dateto
                                and a.canceled ='N'  
                                and g.cardcode + g.cardname like '%' + @supplier + '%'
                                and h.groupname like '%' + @igroup + '%' 
                                and e.itemcode + e.itemname like '%' + @item + '%'          