DECLARE @docentry int 


select @docentry = docentry   from OPOR WHERE DOCNUM = 2110000005 and year(docdate)='2022'

select * from odpo where docnum = 2110000003 and year(docdate)='2022'
select * from ovpm where docnum = 2110000003 and year(docdate)='2022'

select a.U_IGU_SOdocEntry, * From opor a
inner join por1 b on a.docentry = b.docentry 
where a.docentry = @docentry 