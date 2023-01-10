

 declare @dateto varchar(10)  
                            declare @before varchar(10) ,@after varchar(10) 
                            set @dateto = '20221118'
                            select @after = year(dateadd(year,1,convert(date , @dateto) ))
                            select @before = year(convert(date , @dateto))
                            select  'jogja' Company, 
                                    a.itemcode , 
                                    a.itemname ,
                                    @before periode,
                                    d.name assetCategory,
                                    convert(varchar,a.capdate,23) capdate,
                                    case left(convert(varchar,a.capdate,112),4) when @before then e.apc else  b.apc end                'Harga Perolehan' ,
                                    b.orDpAcc           'Akm. Penyusutan Th Lalu',        
                                    b.apc- b.orDpAcc    'Nilai Buku Th Lalu',        
                                    c.orddpramt         'Penyusutan Th. Berjalan',  
                                    case left(convert(varchar,a.capdate,112),4) when @before then  e.apc else 0 end 'Tambahan',    
                                    b.orDpAcc +  c.orddpramt   'Akm. Penyusutan Th. Berjalan',      
                                    case when  left(convert(varchar,a.capdate,112),4)  = @before  then  e.apc - b.orDpAcc -  c.orddpramt 
                                            else   b.apc - b.orDpAcc -  c.orddpramt 
                                    end 'Nilai Buku Th. Berjalan' 
                            from OITM A
                            LEFT OUTER join itm8 b on a.itemcode = b.itemcode  and b.DprArea = 'Main Area' and periodcat =  @before  
                            inner join (select  code , name from OACS) d on a.assetclass = d.code
                            LEFT OUTER join 
                            (   select itemcode,periodcat, sum(OrdDprAmt)OrdDprAmt From DRN2 a 
                                    inner join odrn b on a.docentry = b.docentry 
                                where    b.dprarea ='Main Area' and periodcat =  @before AND b.canceled='N'
                            group by itemcode,periodcat
                            )c on a.itemcode = c.itemcode and b.PeriodCat= c.PeriodCat 
                            left outer join 
                                    (
                                        SELECT 
                                                "ItemCode", SUM(T0.APC) AS "APC"
                                        FROM "FIX1" T0
                                        WHERE 
                                            t0."TransType" = '110'
                                            and t0.DprArea='Main Area'  and year(t0.refdate)= @before
                                    GROUP BY "ItemCode")as  e on a.itemcode = e.itemcode 