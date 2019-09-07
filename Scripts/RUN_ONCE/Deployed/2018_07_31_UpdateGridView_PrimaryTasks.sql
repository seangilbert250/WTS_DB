use [WTS]
go

update GridView
set SectionsXML = REPLACE(cast(SectionsXML as nvarchar(max)), 'PARENT WORK TASK', 'PRIMARY TASK' )
where cast(SectionsXML as nvarchar(max)) Like '%Parent Work Task%'
