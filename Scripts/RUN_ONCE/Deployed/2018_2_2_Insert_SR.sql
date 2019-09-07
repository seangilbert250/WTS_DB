use [WTS]
go

insert into AORSR (
	SRID,
	SubmittedBy,
	SubmittedDate,
	Keywords,
	Websystem,
	[Status],
	SRType,
	[Priority],
	LCMB,
	ITI,
	ITIPOC,
	[Description],
	LastReply,
	CRID,
	Sort,
	Archive,
	CreatedBy,
	CreatedDate,
	UpdatedBy,
	UpdatedDate,
	Imported
)
values (
	-1,
	'Hannah.Walden',
	'2/2/2018',
	null,
	'R&D WTS',
	'COLLABORATION/IN-WORK',
	'Process',
	'High',
	0,
	1,
	'Sean.Walker',
	'Ongoing maintenance is required to ensure the Workload Tracking System aligns with process needs.',
	null,
	-18,
	0,
	0,
	'hannah.walden',
	getdate(),
	'hannah.walden',
	getdate(),
	0
);

