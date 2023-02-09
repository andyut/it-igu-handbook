declare 
        @dateto varchar(10) ,
        @company varchar(50) 
set @dateto = '20230131'

SELECT DISTINCT  
            @company company,
			CONVERT(vARCHAR,T1.docduedate,23) 'Doc Date', 
			CONVERT(vARCHAR,T1.docdate,23) 'Delivery Date', 
			T2.BEGINSTR+ CONVERT(VARCHAR,T1.DOCNUM) 'SO Number',
			T1.CARDCODE 'Code', 
			T1.SHIPTOCODE 'Name' , 
			t6.groupname 'Group', 
			t5.U_ar_Person' AR Person', 
			T3.DocTotal 'Total',
            t5.notes
	FROM DLN1 T0 
		INNER JOIN ORDR T1 ON T0.BASEENTRY = T1.DOCENTRY AND T0.BASETYPE=17 
        INNER JOIN OCRD T5 ON T1.cardcode = t5.cardcode 
        INNER JOIN OCRG T6 ON T5.groupcode = t6.groupcode 
		INNER JOIN OSLP  T4 ON T5.SlpCode=T4.SlpCode
		INNER JOIN NNM1 T2 ON T1.[Series] = T2.[Series] AND T0.[TargetType] not in (13,15)
		INNER JOIN ODLN T3 ON T0.DOCENTRY = T3.DOCENTRY 
	WHERE   T3.DOCSTATUS ='O'
		AND CONVERT(VARCHAR,T1.docduedate,112)>='20161231'
		and CONVERT(VARCHAR,T1.docduedate,112)<=@dateto  
order by  CONVERT(vARCHAR,T1.docduedate,23) , 
			T2.BEGINSTR+ CONVERT(VARCHAR,T1.DOCNUM) ,
			T1.CARDCODE  , 
			T1.SHIPTOCODE  , 
			t6.groupname  , 
			t5.U_ar_Person  
 