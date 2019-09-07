use [WTS]
go

update AORWorkType
set AORWorkTypeName = 'Release/Deployment MGMT',
	[Description] = 'Release/Deployment MGMT'
where AORWorkTypeName = 'Release MGMT';