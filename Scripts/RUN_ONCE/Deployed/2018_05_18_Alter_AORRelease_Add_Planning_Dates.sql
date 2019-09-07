use WTS
go

alter table AORRelease
add PlannedStartDate datetime null,
	PlannedEndDate datetime null;
go
