USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AOR_Resource_Save]    Script Date: 7/5/2018 3:21:27 PM ******/
DROP PROCEDURE [dbo].[AOR_Resource_Save]
GO

/****** Object:  StoredProcedure [dbo].[AOR_Resource_Save]    Script Date: 7/5/2018 3:21:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[AOR_Resource_Save]
	@AORID int,
	@Resources xml,
	@ActionTeam xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output
as
begin
	set nocount on;

	declare @updatedByID int;
	declare @date datetime;
	declare @count int;
	declare @currentProductVersionID int;
	declare @oldAORReleaseID int;
	declare @aorReleaseID int;
	declare @TaskID int;
	declare @itemUpdateTypeID int;
	declare @OldText varchar(max) = null;
	declare @NewText varchar(max) = null;

	select @updatedByID = WTS_RESOURCEID
	from WTS_RESOURCE
	where upper(USERNAME) = upper(@UpdatedBy);

	set @date = getdate();

	select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

	if @AORID > 0
		begin
			select @aorReleaseID = AORReleaseID from AORRelease where AORID = @AORID and [Current] = 1;
			begin try
				SELECT @OldText = STUFF((SELECT DISTINCT ', ' + wr.FIRST_NAME + ' ' + wr.LAST_NAME from AORReleaseResource arr left join WTS_RESOURCE wr on arr.WTS_RESOURCEID = wr.WTS_RESOURCEID WHERE arr.AORReleaseID = @aorReleaseID FOR XML PATH('')), 1, 2, '');
				if @Resources.exist('resources/save') > 0
					begin
						with
						w_resources as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID,
								tbl.[save].value('allocation[1]', 'int') as Allocation,
								tbl.[save].value('aorroleid[1]', 'int') as AORRoleID
							from @Resources.nodes('resources/save') as tbl([save])
						)
						delete from AORReleaseResource
						where AORReleaseResource.AORReleaseID = @aorReleaseID
						and not exists (
							select 1
							from w_resources wrs
							where wrs.AORReleaseID = AORReleaseResource.AORReleaseID
							and wrs.WTS_RESOURCEID = AORReleaseResource.WTS_RESOURCEID
							and wrs.AORRoleID = AORReleaseResource.AORRoleID
						);

						with
						w_resources as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID,
								tbl.[save].value('allocation[1]', 'int') as Allocation,
								tbl.[save].value('aorroleid[1]', 'int') as AORRoleID
							from @Resources.nodes('resources/save') as tbl([save])
						)
						insert into AORReleaseResource(AORReleaseID, WTS_RESOURCEID, Allocation, CreatedBy, UpdatedBy, AORRoleID)
						select wrs.AORReleaseID,
							wrs.WTS_RESOURCEID,
							wrs.Allocation,
							@UpdatedBy,
							@UpdatedBy,
							CASE WHEN wrs.AORRoleID = 0 THEN NULL ELSE wrs.AORRoleID END
						from w_resources wrs
						where not exists (
							select 1
							from AORReleaseResource arr
							where arr.AORReleaseID = wrs.AORReleaseID
							and arr.WTS_RESOURCEID = wrs.WTS_RESOURCEID
							and arr.AORRoleID = wrs.AORRoleID
						);

						with
						w_resources as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID,
								tbl.[save].value('allocation[1]', 'int') as Allocation,
								tbl.[save].value('aorroleid[1]', 'int') as AORRoleID
							from @Resources.nodes('resources/save') as tbl([save])
						)
						update AORReleaseResource
						set AORReleaseResource.Allocation = wrs.Allocation,
							AORReleaseResource.UpdatedBy = @UpdatedBy,
							AORReleaseResource.UpdatedDate = @date,
							AORReleaseResource.AORRoleID = CASE WHEN wrs.AORRoleID = 0 THEN NULL ELSE wrs.AORRoleID END
						from w_resources wrs
						where AORReleaseResource.AORReleaseID = wrs.AORReleaseID
						and AORReleaseResource.WTS_RESOURCEID = wrs.WTS_RESOURCEID
						and AORReleaseResource.AORRoleID = wrs.AORRoleID
						and AORReleaseResource.Allocation != wrs.Allocation;

						SELECT @NewText = STUFF((SELECT DISTINCT ', ' + wr.FIRST_NAME + ' ' + wr.LAST_NAME from AORReleaseResource arr left join WTS_RESOURCE wr on arr.WTS_RESOURCEID = wr.WTS_RESOURCEID WHERE arr.AORReleaseID = @aorReleaseID FOR XML PATH('')), 1, 2, '');

						IF ISNULL(@OldText,0) != ISNULL(@NewText,0)
							BEGIN
								EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Resources', @OldValue = @OldText, @NewValue = @NewText, @CreatedBy = @UpdatedBy, @newID = null
							END;
					end;
				else
					begin
						delete from AORReleaseResource
						where AORReleaseID = @aorReleaseID

						IF LEN(@OldText) > 0
							BEGIN
								EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'Resources', @OldValue = @OldText, @NewValue = null, @CreatedBy = @UpdatedBy, @newID = null
							END;
					end;

				if @ActionTeam.exist('actionteam/save') > 0
					begin
						--get existing AOR Resource Team, if it exists
						declare @TeamResourceID int;
						declare @strAORID nvarchar(10) = convert(nvarchar(10), @AORID);

						select @TeamResourceID = WTS_RESOURCEID
						from WTS_RESOURCE
						where AORResourceTeam = 1
						and USERNAME = 'AOR # ' + @strAORID + ' Action Team';

						with
						w_actionTeam as (
							select
								@aorReleaseID as AORReleaseID,
								tbl.[save].value('resourceid[1]', 'int') as WTS_RESOURCEID
							from @ActionTeam.nodes('actionteam/save') as tbl([save])
						)
						delete from AORReleaseResourceTeam
						where AORReleaseResourceTeam.AORReleaseID = @aorReleaseID
						and not exists (
							select 1
							from w_actionTeam wat
							where wat.AORReleaseID = AORReleaseResourceTeam.AORReleaseID
							and wat.WTS_RESOURCEID = AORReleaseResourceTeam.ResourceID
						);

						if @TeamResourceID is null
							begin
								insert into WTS_RESOURCE (ORGANIZATIONID, USERNAME, FIRST_NAME, LAST_NAME, ARCHIVE, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE, AORResourceTeam)
								values ((select ORGANIZATIONID from ORGANIZATION where ORGANIZATION = 'View'), 'AOR # ' + @strAORID + ' Action Team', 'AOR # ' + @strAORID, 'Action Team', 0, @UpdatedBy, @date, @UpdatedBy, @date, 1);

								set @TeamResourceID = scope_identity();
							end;
			
						with
						w_actionTeam as (
							select
								tbl.[save].value('resourceid[1]', 'int') as ResourceID
							from @ActionTeam.nodes('actionteam/save') as tbl([save])
						)
						insert into AORReleaseResourceTeam(AORReleaseID, ResourceID, TeamResourceID, CreatedBy, UpdatedBy)
						select @aorReleaseID,
							wat.ResourceID,
							@TeamResourceID,
							@UpdatedBy,
							@UpdatedBy
						from w_actionTeam wat
						where wat.ResourceID not in (
							select ResourceID
							from AORReleaseResourceTeam arrt
							where @aorReleaseID = arrt.AORReleaseID
							and wat.ResourceID = arrt.ResourceID
							and @TeamResourceID = arrt.TeamResourceID
						);
					end;
				else if @ActionTeam.exist('empty') = 0
					begin
						delete from AORReleaseResourceTeam
						where AORReleaseID = @aorReleaseID;
					end;
				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
end;
GO

