declare 
                @datefrom varchar(20),
                @dateto varchar(20),
                @company varchar(50) ,
                @item varchar(50) ,
                @supplier  varchar(50) ,
                @igroup varchar(50) 


        set @datefrom = '20220101' 
        set @dateto = '20221231' 
        set @company = 'IGU' 
        set @item = ''
        set @supplier =''
        set @igroup = ''

            declare @table table (  idx int identity(1,1)  , 
                    docentry int,
                    docnum varchar(50) ,  
                    grpo int ,
                    numatcard varchar(50))

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
            from OPCH (nolock) A 
            INNER JOIN PCH1 (nolock)  B ON A.DOCENTRY  = B.DOCENTRY
            INNER JOIN PDN1 (nolock)  C ON B.BASEENTRY = C.DOCENTRY AND B.BASETYPE = 20 
            INNER JOIN OPOR (nolock)  D ON C.BASEENTRY = D.DOCENTRY AND C.BASETYPE=22 

            where convert(varchar,a.docdate,112)between @datefrom and @dateto



            insert into  @table2 
            select distinct a.docentry ,b.oribaBsEnt  from OIPF (nolock)  a 
            inner join ipf1 (nolock)  b on a.DocEntry = b.docentry 
            where  convert(varchar,a.docdate,112)between @datefrom and @dateto
            order by b.oribaBsEnt

            insert into @table3
            select c.opdn, 
            -1 *    sum(bea_masuk) ,
            -1 *    sum(shipment) ,
            -1 *    sum(receiving) ,
            -1 *    sum(pib_pnbp) ,
            -1 *    sum(surveyor) ,                                    
            -1 *    sum(h_biaya) ,
            -1 *    sum(lainlain) , 
            -1 *    sum(amount) 

            from oipf (nolock) a 
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

            select distinct
            @company company,
            'AP Invoice' docs,
            a.doctype,
            a.docentry ,
            a.docnum ,
            a.numatcard ,
            a.shiptocode, 
            a.U_PI_No PI_Number,
            a.u_Vessel ,
            replace(replace(a.u_Container,char(10),'') ,char(13),'')u_Container , 
            a.u_Pesawat ,
            a.u_AwBillNo ,
            a.u_VendDO_No ,
            a.u_IGU_PIBNo, 
            a.u_IGU_PIB_Nop Nopen ,
            convert(varchar,a.u_IGU_PIBRemarks) KodeBilling ,
            convert(varchar ,a.u_IDU_Referensi) NTPN ,
            a.u_IGU_Invoice_Vendor ,
            a.u_IGU_PPh_21 PPh22,
            a.u_IGU_TotalCif2 NilaiPabean_IDR ,
            a.u_IGU_NDPBM ,
            a.docDate ,
            a.cardcode ,
            a.cardname ,
            a.shiptocode,
            C.GROUPNAME ,
            (a.DocTotalSy) Doctotal,
            (a.DpmAmntSC) DownPayment ,
            (a.VatSum) PPn,
            (a.Max1099)  - (a.VatSum)  Amount,
            isnull(i.bea_masuk,0) bea_masuk ,
            isnull(i.shipment,0) shipment ,
            isnull(i.receiving,0) receiving ,
            isnull(i.pib_pnbp,0) pib_pnbp ,
            isnull(i.surveyor,0) surveyor ,
            isnull(i.h_biaya,0) h_biaya ,
            isnull(i.lainlain,0) lainlain , 
            isnull(i.total,0) TotalLandedCost ,
            isnull(a.TotalExpSC,0) Freight,
            (isnull(a.Max1099,0) )  - (isnull(a.VatSum,0)) + isnull(a.TotalExpSC,0) + isnull(i.total,0)  total
            from OPCH A 
            INNER JOIN OCRD B ON A.CARDCODE = B.CARDCODE 
            INNER JOIN OCRG C ON B.GROUPCODE = C.GROUPCODE
            left outer join @table f on a.docentry = f.docentry
            left outer join @table3 i on f.grpo = i.opdn
            WHERE  convert(varchar,a.docdate,112)between @datefrom and @dateto
            and a.canceled ='N' 
            and a.CtlAccount = '2110001'
            and b.cardcode + b.cardname like '%' + @supplier + '%'   
            and c.groupname like '%' + @igroup + '%'

            UNION ALL

            select distinct
            @company company,
            'AP Credit',
            a.doctype,
            a.docentry ,
            a.docnum ,
            a.numatcard ,
            a.shiptocode, 
            a.U_PI_No PI_Number,
            a.u_Vessel ,
            replace(replace(a.u_Container,char(10),'') ,char(13),'') u_Container, 
            a.u_Pesawat ,
            a.u_AwBillNo ,
            a.u_VendDO_No ,
            a.u_IGU_PIBNo, 
            a.u_IGU_PIB_Nop Nopen ,
            convert(varchar,a.u_IGU_PIBRemarks) KodeBilling ,
            convert(varchar ,a.u_IDU_Referensi) NTPN ,
            a.u_IGU_Invoice_Vendor ,
            a.u_IGU_PPh_21 PPh22,
            a.u_IGU_TotalCif2 NilaiPabean_IDR ,
            a.u_IGU_NDPBM ,
            a.docDate ,
            a.cardcode ,
            a.cardname ,
            a.shiptocode,
            c.groupname ,
            -1* (a.DocTotalSy) Doctotal,
            -1* (a.DpmAmntSC) DownPayment ,
            -1* (a.VatSum) VatSum,
            -1* (a.Max1099  - (a.VatSum))  Amount,
            0 LANDED ,
            0 LANDED ,
            0 LANDED ,
            0 LANDED ,
            0 LANDED ,
            0 LANDED ,
            0 LANDED ,
            0 LANDED ,
            -1* a.TotalExpSC Freight,
            -1* (a.Max1099  - (a.VatSum) + isnull(a.TotalExpSC,0))  total
            from orpc A 
            INNER JOIN OCRD B ON A.CARDCODE = B.CARDCODE 
            INNER JOIN OCRG C ON B.GROUPCODE = C.GROUPCODE
            inner join 
            (select distinct a.docentry from rpc1 a
            inner join orpc b on a.docentry = b.docentry where  convert(varchar,b.docdate,112)between @datefrom and @dateto and a.basetype<>204) d on a.docentry = d.docentry  
            WHERE  convert(varchar,a.docdate,112)between @datefrom and @dateto
            and a.canceled ='N'  
            and a.CtlAccount = '2110001'
            and b.cardcode + b.cardname like '%' + @supplier + '%'   
            and c.groupname like '%' + @igroup + '%'