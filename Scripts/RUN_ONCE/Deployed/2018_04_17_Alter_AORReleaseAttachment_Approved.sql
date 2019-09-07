use [WTS]
go

if (dbo.ColumnExists('dbo', 'AORReleaseAttachment', 'Approved') = 0)
	begin
		alter table AORReleaseAttachment
		add Approved bit not null default(0);
	end;
go

if (dbo.ColumnExists('dbo', 'AORReleaseAttachment', 'ApprovedByID') = 0)
	begin
		alter table AORReleaseAttachment
		add ApprovedByID int null;

		alter table AORReleaseAttachment
		add constraint [FK_AORReleaseAttachment_WTS_RESOURCE] foreign key ([ApprovedByID]) references [WTS_RESOURCE]([WTS_RESOURCEID]);
	end;
go

if (dbo.ColumnExists('dbo', 'AORReleaseAttachment', 'ApprovedDate') = 0)
	begin
		alter table AORReleaseAttachment
		add ApprovedDate datetime null;
	end;
go