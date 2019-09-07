use [WTS]
go

update AORWorkType
set AORWorkTypeName = 'Workload MGMT',
	[Description] = 'Workload MGMT'
where AORWorkTypeName = 'MGMT Workload';

update AORWorkType
set AORWorkTypeName = 'Release MGMT',
	[Description] = 'Release MGMT'
where AORWorkTypeName = 'MGMT Release';