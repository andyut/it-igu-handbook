SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[IGU_ACT_INVOICE_DETAIL]
    @inv_from varchar(20),
    @inv_to varchar(20),
    @datefrom varchar(20),
    @dateto varchar(20)
AS
BEGIN
select
                            
                            D.VatGroup inv_ppn , 
                            ISNULL(D.ItemCode,'')  inv_itemcode,
                            D.Dscription + ISNULL(D.FREETXT ,'') inv_itemname ,
                            isnull(d.U_Qty_AR,d.quantity) inv_quantity ,
                            isnull(d.U_Price_AR ,round(d.price,0))  inv_price,
                            D.LineTotal inv_amount  ,
                            E.InvntryUom inv_uom ,
                            a.docnum invoice_no ,
                            a.numatcard so_no
                    from DBO.OINV  A 
                    INNER JOIN DBO.OCRD B ON A.CARDCODE  = B.CARDCODE 
                    INNER JOIN DBO.OSLP C ON C.SlpCode = B.SlpCode
                    INNER JOIN DBO.INV1 D ON A.DOCENTRY = D.DOCENTRY 
                    LEFT OUTER JOIN DBO.OITM E ON D.ITEMCODE = E.ITEMCODE                     
                    WHERE convert(varchar,A.DOCNUM) between @inv_from and   @inv_to
                        and convert(varchar,a.docdate,112) between  @datefrom and   @dateto and a.canceled='N'
                    ORDER BY a.NumAtCard , d.linenum

end
GO
