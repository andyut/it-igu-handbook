select  'proyeksi' Header,
                right(convert(varchar,a.DueDate ,112),2) iday, 
                case 
                when d.GroupCode in (100,102,120) then '01-CATERING'
                when d.GroupCode in (103) then '02-HOREKA'
                when d.GroupCode in (105) then '03-RETAIL'
                when d.GroupCode in (106) then '04-PASTRY'
                when d.GroupCode in (107,120) then '05-QSR'
                when d.GroupCode in (109,110) then '06-WET'
                when d.GroupCode in (114) then '07-ECOMMERCE'
                when d.GroupCode in (108,116,117,118,121) then '08-GROUP'
                else   '09-OTHERS'
                end idivisi,
                sum(a.debit-a.credit) amount
        from jdt1 A
        inner join ojdt B ON A.transid = b.transid 
        inner join ocrd c on a.ShortName = c.cardcode 
        inner join ocrg d on c.groupcode = d.groupcode 

        where left(convert(varchar,a.DueDate ,112),6) = left(@dateto,6)
        and a.account ='1130001' and a.transtype in (13,14)
        group by right(convert(varchar,a.DueDate ,112),2) ,
                case 
                when d.GroupCode in (100,102,120) then '01-CATERING'
                when d.GroupCode in (103) then '02-HOREKA'
                when d.GroupCode in (105) then '03-RETAIL'
                when d.GroupCode in (106) then '04-PASTRY'
                when d.GroupCode in (107,120) then '05-QSR'
                when d.GroupCode in (109,110) then '06-WET'
                when d.GroupCode in (114) then '07-ECOMMERCE'
                when d.GroupCode in (108,116,117,118,121) then '08-GROUP'
                else   '09-OTHERS'
                end