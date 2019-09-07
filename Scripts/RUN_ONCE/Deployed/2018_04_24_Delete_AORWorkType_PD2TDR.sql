use [WTS]
go

update AORRelease
set AORWorkTypeID = (select AORWorkTypeID from AORWorkType where AORWorkTypeName = 'MGMT Release')
where AORWorkTypeID = (select AORWorkTypeID from AORWorkType where AORWorkTypeName = 'PD2TDR Managed AORs');

delete from AORWorkType
where AORWorkTypeName = 'PD2TDR Managed AORs';