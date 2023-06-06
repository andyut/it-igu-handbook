declare 
        @datefrom varchar(10) ,
        @dateto  varchar(10)  
 set @datefrom = '20230501'
 set @dateto = '20230531'
	select 
					'INDOGUNA_' +  convert(Varchar,T0.OBJTYPE ) + '_' +  convert(varchar,T0.DOCENTRY  ) id,  
					'INDOGUNA_' +  convert(Varchar,T0.OBJTYPE ) + '_' +  convert(varchar,T0.DOCENTRY  ) name,  
                    t0.docentry,
                    t0.canceled s_canceled  , 
                    
                    isnull(t0.numatcard,'') numatcard,
					convert(varchar,T0.docduedate,121) docdate, 
					T1.beginStr + convert(varchar,T0.DocNum) ord_no , 
					T0.CardCode cardcode  , 
					T0.cardname   cardname  , 
					T0.shiptocode   shiptocode  , 
                    replace( replace(t0.address2, char(13),''),char(10),'') address,
					isnull(replace(replace(t0.comments,char(13),''),char(10),''),'')  remarks, 
                    convert(varchar,t0.CreateDate,23) sap_createdate,
                    t01.user_Code + ' '+  isnull(T0.U_Last_Update_By,'') sap_createuser,
					left(right('00' + convert(varchar, T0.doctime),4),2) + ':' + right(right('00' + convert(varchar, T0.doctime),4),2) doctime , 
                    b.groupname customer_group ,
                    c.slpname +' '+ isnull(c.u_slsempname,'') salesperson,
                    isnull(c.memo,'None') salesgroup,
                    isnull(c.u_email,'') sales_email
                    
                    
			FROM  ORDR  (nolock) T0 
                INNER JOIN OUSR  (nolock) T01 ON t0.UserSign = t01.userid 
                INNER JOIN OCRD  (nolock) A ON A.CARDCODE = T0.CARDCODE 
                inner join ocrg  (nolock) b on a.groupcode = b.groupcode 
                inner join oslp  (nolock) c on t0.slpcode = c.slpcode 
				INNER JOIN NNM1  (nolock) T1 ON T0.Series = T1.Series 
				 
			where 1=1 and T0.DocdueDate between @datefrom and @dateto
			--AND T1.beginstr + convert(varchar,T0.DocNum) between  @INVFROM  and @INVTO
			and t0.CANCELED in('N','Y')
			ORDER BY T1.beginStr + convert(varchar,T0.DocNum) 
 