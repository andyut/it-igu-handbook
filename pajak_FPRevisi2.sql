
/*
008-23.95318112

select len('008-23.95398112')
*/
declare @rowcount int , @rowmax int 
declare @table table ( idx int identity (1,1), nopajak varchar(50))
set @rowcount = 95318112 
set @rowmax = 95398112 
while @rowcount <= @rowmax

begin 
    insert into @table 
    select '008-23.' + convert(varchar,@rowcount)
set @rowcount = @rowcount + 1 

end 
select * from @table
select right(isnull(U_IDU_FPajak,''),15),docentry,docnum from oinv a 
where right(isnull(U_IDU_FPajak,''),15) between '008-23.95318112' and '008-23.95398112'
and a.CANCELED='N'
