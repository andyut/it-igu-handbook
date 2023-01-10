declare 
 
        @datefrom varchar(10) , 
        @dateto varchar(10) , 
        @item varchar(50) ,
        @company varchar(50)



set @datefrom = '20220101'
set @dateto = '20220531'
set @item = ''
set @group = ''

set @company = 'Semarang'

select 
        @company Company,
        @datefrom DateFrom,
        @dateto Dateto,
        A.ITEMCODE ,
        B.ITEMNAME ,
        B.u_GROUP ,
        B.U_SUBGROUP , 
        C.WHSNAME WAREHOUSE,
        SUM ( CASE when convert(varchar,a.docdate,112)< @datefrom then  (A.INQTY - a.OUTQTY) else 0 end ) OpeningBalance,
        SUM ( CASE when convert(varchar,a.docdate,112)between  @datefrom  and @dateto
                        and a.transtype in ( 20,19,21,18,69 ) 
                    then  (A.INQTY - a.OUTQTY) else 0 end ) Pembelian,
        SUM ( CASE when convert(varchar,a.docdate,112)between  @datefrom  and @dateto
                        and a.transtype in (14,16,13,15 ) 
                    then  (A.INQTY - a.OUTQTY) else 0 end ) Penjualan,
        SUM ( CASE when convert(varchar,a.docdate,112)between  @datefrom  and @dateto
                        and a.transtype in (67) 
                    then  (A.INQTY - a.OUTQTY) else 0 end ) InventoryTransfer, 
        SUM ( CASE when convert(varchar,a.docdate,112)between  @datefrom  and @dateto
                        and a.transtype in (-2,58,60,162,59 ) 
                    then  (A.INQTY - a.OUTQTY) else 0 end ) Adjustment, 
        SUM ( CASE when convert(varchar,a.docdate,112)between  @datefrom  and @dateto
                        and a.transtype in (10000071) 
                    then  (A.INQTY - a.OUTQTY) else 0 end ) SAPOpname, 
        SUM ( CASE when convert(varchar,a.docdate,112)<= @dateto then  (A.INQTY - a.OUTQTY) else 0 end ) EndingBalance
from OINM (NOLOCK)A
    INNER JOIN OITM (NOLOCK) B ON A.ITEMCODE = B.ITEMCODE 
    inner join OWHS (NOLOCK) C ON A.WAREHOUSE = C.WHSCODE
where 
    convert(varchar,a.docdate,112) <=@dateto
    and a.itemcode + b.itemname like '%' + isnull(@item,'') +'%'
    and c.whscode + c.whsname like '%' + isnull(@warehouse,'') +'%'

 group by 
A.ITEMCODE ,
        B.ITEMNAME ,
        B.u_GROUP ,
        B.U_SUBGROUP  ,C.WHSNAME 
 
