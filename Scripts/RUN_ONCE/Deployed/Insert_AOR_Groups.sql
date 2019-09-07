use [WTS]
go

insert into AORGroup(AORGroupName, [Description])
select a.AORGroupName, a.[Description] from (
	select 'Business Analyst' as AORGroupName, 'Business Analyst' as [Description]
	union all
	select 'Developer' as AORGroupName, 'Developer' as [Description]
	union all
	select 'Management' as AORGroupName, 'Management' as [Description]
) a;

insert into AORRoleGroup (AORRoleID, AORGroupID)
select aro.AORRoleID,
	(select AORGroupID from AORGroup where AORGroupName = 'Business Analyst')
from AORRole aro
where AORRoleName in ('Architect System', 'BA', 'BA Lead', 'Cyber', 'Consultant', 'Customer Liason', 'SME');

insert into AORRoleGroup (AORRoleID, AORGroupID)
select aro.AORRoleID,
	(select AORGroupID from AORGroup where AORGroupName = 'Developer')
from AORRole aro
where AORRoleName in ('Architect Technical', 'Developer', 'Developer Lead', 'Developer/DBA');

insert into AORRoleGroup (AORRoleID, AORGroupID)
select aro.AORRoleID,
	(select AORGroupID from AORGroup where AORGroupName = 'Management')
from AORRole aro
where AORRoleName in ('BA Manager', 'Contract Manager', 'Product Owner', 'Training Manager');
