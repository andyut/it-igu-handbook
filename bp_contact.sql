select a.cntctcode AS [Key],
        A.NAME , 
       A.[Position] ,
       A.Address ,
       A.Cellolar,
       b.u_idu_almtNPWP,
       B.CARDCODE ,
       B.CARDNAME ,
       B.CardFName ,
       b.lictradnum,
       B.U_AR_Person ,
       B.ShipToDef ,  
       a.u_igu_noktp,
       a.U_igu_nonpwp,
       a.U_blacklist
 from  DBO.OCPR a
INNER JOIN  DBO.OCRD B ON A.CARDCODE = B.CARDCODE 
where b.U_blacklist ='Y'