use [WTS]
go

update SRType
set SRType = 'Usability/Efficiency',
	[Description] = 'Usability/Efficiency'
where SRType = 'Other Maintenance';
