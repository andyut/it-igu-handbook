declare 
        @dateto varchar(10) ,
        @partner varchar(50) 

SET @DATETO = '20230125'

	SELECT DISTINCT 
			@dateto 'Date To',
			T0.DOCENTRY ,
			T3.DOCSTATUS, 
			CONVERT(vARCHAR,T1.DOCDUEDATE,23) DOCDATE,
			CONVERT(vARCHAR,T3.DOCDATE,23) TGLPOTONGSTOCK,
			t3.docnum,
			T2.BEGINSTR+ CONVERT(VARCHAR,T1.DOCNUM) DO_NUMBER ,
			T1.CARDCODE, 
			T1.SHIPTOCODE , 
			t6.groupname memo,
			T1.CARDNAME ,
			T3.NUMATCARD,
			T4.U_SlsEmpName, 
            ISNULL(T5.U_AR_Person,'-') ARPERSON,
			T3.DocTotal,
            
			T1.COMMENTS ,
            ISNULL(T5.Notes,'-') TUKARFAKTUR
	FROM DLN1 T0 
		INNER JOIN ORDR T1 ON T0.BASEENTRY = T1.DOCENTRY AND T0.BASETYPE=17 
        INNER JOIN OCRD T5 ON T1.cardcode = t5.cardcode 
        INNER JOIN OCRG T6 ON T5.groupcode = t6.groupcode 
		INNER JOIN OSLP  T4 ON T5.SlpCode=T4.SlpCode
		INNER JOIN NNM1 T2 ON T1.[Series] = T2.[Series] AND T0.[TargetType] not in (13,15)
		INNER JOIN ODLN T3 ON T0.DOCENTRY = T3.DOCENTRY 
	WHERE   
			T1.CARDCODE + ISNULL(T1.SHIPTOCODE ,'') + ISNULL(T1.CARDNAME,'')   LIKE '%'+ isnull(replace(@partner ,' ','%'),'')+ '%'
		AND T3.DOCSTATUS ='O'
		AND CONVERT(VARCHAR,T3.docdate,112)>='20161231'
		and CONVERT(VARCHAR,T3.docdate,112)<=@dateto  
 ORDER BY CONVERT(vARCHAR,T1.DOCDUEDATE,23)