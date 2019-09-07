use [WTS]
go

insert into AORRole(AORRoleName, [Description])
select a.AORRoleName, a.[Description] from (
	select 'Architect System' as AORRoleName, 'Architect System' as [Description]
	union all
	select 'BA' as AORRoleName, 'BA' as [Description]
	union all
	select 'BA Lead' as AORRoleName, 'BA Lead' as [Description]
	union all
	select 'Cyber' as AORRoleName, 'Cyber' as [Description]
	union all
	select 'Consultant' as AORRoleName, 'Consultant' as [Description]
	union all
	select 'Customer Liason' as AORRoleName, 'Customer Liason' as [Description]
	union all
	select 'SME' as AORRoleName, 'SME' as [Description]
	union all
	select 'Architect Technical' as AORRoleName, 'Architect Technical' as [Description]
	union all
	select 'Developer' as AORRoleName, 'Developer' as [Description]
	union all
	select 'Developer Lead' as AORRoleName, 'Developer Lead' as [Description]
	union all
	select 'Developer/DBA' as AORRoleName, 'Developer/DBA' as [Description]
	union all
	select 'BA Manager' as AORRoleName, 'BA Manager' as [Description]
	union all
	select 'Contract Manager' as AORRoleName, 'Contract Manager' as [Description]
	union all
	select 'Product Owner' as AORRoleName, 'Product Owner' as [Description]
	union all
	select 'Training Manager' as AORRoleName, 'Training Manager' as [Description]
) a;