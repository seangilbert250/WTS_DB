use [WTS]
go

if [dbo].TableExists('dbo', 'AORReleaseResourceTeam') = 0
begin
	create table [dbo].[AORReleaseResourceTeam](
		[AORReleaseResourceTeamID] [int] identity(1,1) not null,
		[AORReleaseID] [int] not null,
		[ResourceID] [int] not null,
		[TeamResourceID] [int] not null,
		[Archive] [bit] not null default (0),
		[CreatedBy] [nvarchar](255) not null default ('WTS'),
		[CreatedDate] [datetime] not null default (getdate()),
		[UpdatedBy] [nvarchar](255) not null default ('WTS'),
		[UpdatedDate] [datetime] not null default (getdate()),
		constraint [PK_AORReleaseResourceTeam] primary key clustered([AORReleaseResourceTeamID] ASC),
		constraint [UK_AORReleaseResourceTeam] unique([AORReleaseID], [ResourceID], [TeamResourceID])
		with (pad_index = off, statistics_norecompute = off, ignore_dup_key = off, allow_row_locks = on, allow_page_locks = on) on [PRIMARY],
			constraint [FK_AORReleaseResourceTeam_AORRelease] foreign key ([AORReleaseID]) references [AORRelease]([AORReleaseID]),
			constraint [FK_AORReleaseResourceTeam_Resource] foreign key ([ResourceID]) references [WTS_RESOURCE]([WTS_RESOURCEID]),
			constraint [FK_AORReleaseResourceTeam_TeamResource] foreign key ([TeamResourceID]) references [WTS_RESOURCE]([WTS_RESOURCEID])
	) on [PRIMARY]
end;
go