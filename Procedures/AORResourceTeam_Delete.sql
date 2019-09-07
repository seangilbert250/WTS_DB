use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORResourceTeam_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORResourceTeam_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORResourceTeam_Delete]
	@AORReleaseResourceTeamID int,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from AORReleaseResourceTeam where AORReleaseResourceTeamID = @AORReleaseResourceTeamID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		delete from AORReleaseResourceTeam
		where AORReleaseResourceTeamID = @AORReleaseResourceTeamID;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
