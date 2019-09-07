use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORReleaseBuilder_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORReleaseBuilder_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORReleaseBuilder_Save]
	@CurrentReleaseID int,
	@NewReleaseID int,
	@AssignedToRankIDs nvarchar(50),
	@Additions xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @date datetime;
	declare @AORReleaseID int;
	declare @CRIDs nvarchar(255);
	declare @currentProductVersionID int;
	declare @AORID int;
	declare @AORWorkTypeID int;
	declare @CascadeAOR int;
	declare @NewAORReleaseID int;
	declare @TaskID int;

	set @date = getdate();

	if @Additions.exist('additions/save') > 0
		begin
			declare cur cursor for
			select
				tbl.[save].value('aorreleaseid[1]', 'int') as AORReleaseID,
				tbl.[save].value('crids[1]', 'varchar(255)') as CRIDs
			from @Additions.nodes('additions/save') as tbl([save]);

			open cur;

			fetch next from cur
			into @AORReleaseID,
				@CRIDs;

			while @@fetch_status = 0
			begin
				select @currentProductVersionID = ProductVersionID from AORRelease where AORReleaseID = @AORReleaseID;

				if isnull(@NewReleaseID, 0) != isnull(@currentProductVersionID, 0)
					begin
						select @AORID = AORID from AORRelease where AORReleaseID = @AORReleaseID;

						update AOR
						set UpdatedBy = @UpdatedBy,
							UpdatedDate = @date
						where AORID = @AORID;

						update AORRelease
						set [Current] = 0,
							UpdatedBy = @UpdatedBy,
							UpdatedDate = @date
						where AORID = @AORID;

						insert into AORRelease(AORID, AORName, [Description], Notes,CodingEffortID, TestingEffortID, TrainingSupportEffortID, StagePriority, SourceProductVersionID, ProductVersionID, [Current], CascadeAOR, WorkloadAllocationID, TierID, RankID, IP1StatusID, IP2StatusID, IP3StatusID,
							ROI, CMMIStatusID, CyberID, CyberNarrative, CriticalPathAORTeamID, AORWorkTypeID, AORCustomerFlagship,
							InvestigationStatusID, TechnicalStatusID, CustomerDesignStatusID, CodingStatusID, InternalTestingStatusID, CustomerValidationTestingStatusID, AdoptionStatusID,
							CriticalityID, CustomerValueID, RiskID, LevelOfEffortID, HoursToFix, CyberISMT, PlannedStartDate, PlannedEndDate,
							CreatedBy, UpdatedBy)
						select AORID, AORName, [Description], Notes, CodingEffortID, TestingEffortID, TrainingSupportEffortID, StagePriority, ProductVersionID, @NewReleaseID, 1, CascadeAOR, WorkloadAllocationID, TierID, RankID, IP1StatusID, IP2StatusID, IP3StatusID,
							ROI, CMMIStatusID, CyberID, CyberNarrative, CriticalPathAORTeamID, AORWorkTypeID, AORCustomerFlagship,
							InvestigationStatusID, TechnicalStatusID, CustomerDesignStatusID, CodingStatusID, InternalTestingStatusID, CustomerValidationTestingStatusID, AdoptionStatusID,
							CriticalityID, CustomerValueID, RiskID, LevelOfEffortID, HoursToFix, CyberISMT, PlannedStartDate, PlannedEndDate,
							@UpdatedBy, @UpdatedBy
						from AORRelease
						where AORReleaseID = @AORReleaseID;

						select @NewAORReleaseID = AORReleaseID,
							@AORWorkTypeID = AORWorkTypeID,
							@CascadeAOR = CascadeAOR
						from AORRelease
						where AORID = @AORID and [Current] = 1;

						INSERT INTO AORRelease_History
						(
							ITEM_UPDATETYPEID,
							AORReleaseID,
							FieldChanged,
							OldValue,
							NewValue,
							CREATEDBY,
							CREATEDDATE
						)
						SELECT
							1,
							arl.AORReleaseID,
							'Previous Release',
							(select pv.ProductVersion from ProductVersion pv where arl.SourceProductVersionID = pv.ProductVersionID),
							(select pv.ProductVersion from ProductVersion pv where arl.ProductVersionID = pv.ProductVersionID),
							arl.CreatedBy,
							arl.CreatedDate
						FROM AORRelease arl
						where AORReleaseID = @NewAORReleaseID;

						--insert into AORReleaseAttachment(AORReleaseID, AORAttachmentTypeID, AORReleaseAttachmentName, [FileName], [Description], FileData, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
						--select @NewAORReleaseID,
						--	AORAttachmentTypeID,
						--	AORReleaseAttachmentName,
						--	[FileName],
						--	[Description],
						--	FileData,
						--	Archive,
						--	CreatedBy,
						--	CreatedDate,
						--	UpdatedBy,
						--	UpdatedDate
						--from AORReleaseAttachment
						--where AORReleaseID = @AORReleaseID;

						insert into AORReleaseCR(AORReleaseID, CRID, CreatedBy, UpdatedBy)
						select @NewAORReleaseID,
							CRID,
							@UpdatedBy,
							@UpdatedBy
						from AORReleaseCR
						where AORReleaseID = @AORReleaseID
						and charindex(',' + convert(nvarchar(10), CRID) + ',', ',' + @CRIDs + ',') > 0;

						insert into AORReleaseResourceTeam(AORReleaseID, ResourceID, TeamResourceID, CreatedBy, UpdatedBy)
						select @NewAORReleaseID,
							ResourceID,
							TeamResourceID,
							@UpdatedBy,
							@UpdatedBy
						from AORReleaseResourceTeam
						where AORReleaseID = @AORReleaseID;

						insert into AORReleaseTask(AORReleaseID, WORKITEMID, CascadeAOR, CreatedBy, UpdatedBy)
						select @NewAORReleaseID,
							art.WORKITEMID,
							@CascadeAOR,
							@UpdatedBy,
							@UpdatedBy
						from AORReleaseTask art
						join WORKITEM wi
						on art.WORKITEMID = wi.WORKITEMID
						join [STATUS] s
						on wi.STATUSID = s.STATUSID
						where art.AORReleaseID = @AORReleaseID
						and upper(s.[STATUS]) != 'CLOSED'
						and charindex(',' + convert(nvarchar(10), wi.AssignedToRankID) + ',', ',' + @AssignedToRankIDs + ',') > 0;

						insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, CreatedBy, UpdatedBy)
						select @NewAORReleaseID,
							rst.WORKITEMTASKID,
							@UpdatedBy,
							@UpdatedBy
						from AORReleaseSubTask rst
						join WORKITEM_TASK wit
						on rst.WORKITEMTASKID = wit.WORKITEM_TASKID
						join [STATUS] s
						on wit.STATUSID = s.STATUSID
						where rst.AORReleaseID = @AORReleaseID
						and upper(s.[STATUS]) != 'CLOSED'
						and (@AORWorkTypeID = 2 or charindex(',' + convert(nvarchar(10), wit.AssignedToRankID) + ',', ',' + @AssignedToRankIDs + ',') > 0);
						
						if @AORWorkTypeID = 2 --Release/Deployment MGMT
							begin
								declare curTasks cursor for
								select WORKITEMID
								from AORReleaseTask
								where AORReleaseID = @NewAORReleaseID;

								open curTasks;

								fetch next from curTasks
								into @TaskID;
						
								while @@fetch_status = 0
									begin
										exec AORTaskProductVersion_Save
											@TaskID = @TaskID,
											@Add = 0,
											@UpdatedBy = @UpdatedBy,
											@Saved = null;

										fetch next from curTasks
										into @TaskID;
									end;
								close curTasks;
								deallocate curTasks;
							end;

						insert into AORReleaseSystem(AORReleaseID, WTS_SYSTEMID, [Primary], CreatedBy, UpdatedBy)
						select @NewAORReleaseID,
							WTS_SYSTEMID,
							[Primary],
							@UpdatedBy,
							@UpdatedBy
						from AORReleaseSystem
						where AORReleaseID = @AORReleaseID;

						insert into AORReleaseResource(AORReleaseID, WTS_RESOURCEID, Allocation, CreatedBy, UpdatedBy)
						select @NewAORReleaseID,
							WTS_RESOURCEID,
							Allocation,
							@UpdatedBy,
							@UpdatedBy
						from AORReleaseResource
						where AORReleaseID = @AORReleaseID;
					end;

				fetch next from cur
				into @AORReleaseID,
					@CRIDs;
			end;
			close cur;
			deallocate cur;

			set @Saved = 1;
		end;
end;
