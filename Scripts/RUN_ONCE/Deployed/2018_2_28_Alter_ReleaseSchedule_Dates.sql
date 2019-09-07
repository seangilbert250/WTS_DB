use [WTS]
go

alter table ReleaseSchedule
	add PlannedDevTestStart date null,
		PlannedDevTestEnd date null,
		PlannedIP1Start date null,
		PlannedIP1End date null,
		PlannedIP2Start date null,
		PlannedIP2End date null,
		PlannedIP3Start date null,
		PlannedIP3End date null,
		ActualStart date null,
		ActualEnd date null,
		ActualDevTestStart date null,
		ActualDevTestEnd date null,
		ActualIP1Start date null,
		ActualIP1End date null,
		ActualIP2Start date null,
		ActualIP2End date null,
		ActualIP3Start date null,
		ActualIP3End date null;
go

