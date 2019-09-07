USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[Get_Updates]    Script Date: 8/17/2018 11:26:19 AM ******/
DROP FUNCTION [dbo].[Get_Updates]
GO

/****** Object:  UserDefinedFunction [dbo].[Get_Updates]    Script Date: 8/17/2018 11:26:19 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE function [dbo].[Get_Updates]
(
	@ItemID nvarchar(10),
	@BlnSubTask nvarchar(10),
	@Field nvarchar(100),
	@Value nvarchar(MAX),
	@Type nvarchar(100),
	@ExtData nvarchar(MAX), -- this parameter is a catch all for specific updates to pass in data (for ex, the rqmt area passes in systemid, workareaid, rqmttypeid, rqmtid, rqmtsetid)
	@UpdatedBy nvarchar(255)
)
returns nvarchar(MAX)
as
begin
	declare @date nvarchar(30);
	declare @fieldName nvarchar(100);
	declare @typeName nvarchar(100);
	declare @itemUpdateTypeID nvarchar(10);
	declare @updates nvarchar(MAX);
	declare @updatedByID nvarchar(10);
	declare @AORWorkTypeID nvarchar(10);

	set @date = convert(nvarchar(30), getdate());
	set @fieldName = upper(@Field);
	set @typeName = upper(@Type);
	select @itemUpdateTypeID = convert(nvarchar(10), ITEM_UPDATETYPEID) from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';
	select @updatedByID = convert(nvarchar(10), WTS_RESOURCEID) from WTS_RESOURCE where upper(USERNAME) = replace(@UpdatedBy,'''''','''');

	if @fieldName = 'Workload MGMT' set @AORWorkTypeID = '1';
		
	if @fieldName = 'Release/Deployment MGMT' set @AORWorkTypeID = '2';

	set @UpdatedBy = replace(@UpdatedBy, '''', '''''');

	if @typeName = 'AOR'
		begin
			set @updates =
				case when @fieldName = 'AOR NAME' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''AOR Name'', (select AORName from AORRelease where AORReleaseID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else '''' + replace(@Value, '''', '''''') + '''' end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set AORName = ''' + replace(@Value, '''', '''''') + ''', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'DESCRIPTION' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Description'', (select [Description] from AORRelease where AORReleaseID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else '''' + replace(@Value, '''', '''''') + '''' end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set [Description] = ''' + replace(@Value, '''', '''''') + ''', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'SORT' then 
					'update AOR set Sort = ' + case when @Value = '' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORID = ' + @ItemID + ';'
				when @fieldName = 'PRIORITY' then 
					'update AORRelease set StagePriority = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'TIER' then 
					'update AORRelease set TierID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'RANK' then 
					'update AORRelease set RankID = ' + case when @Value = '' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'CODING ESTIMATED EFFORT' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Estimated Effort - Coding'', (select es.EffortSize from AORRelease arl join EffortSize es on arl.CodingEffortID = es.EffortSizeID where AORReleaseID = ' + @ItemID + '), (select es.EffortSize from EffortSize es where es.EffortSizeID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set CodingEffortID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'TESTING ESTIMATED EFFORT' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Estimated Effort - Testing'', (select es.EffortSize from AORRelease arl join EffortSize es on arl.TestingEffortID = es.EffortSizeID where AORReleaseID = ' + @ItemID + '), (select es.EffortSize from EffortSize es where es.EffortSizeID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set TestingEffortID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'TRAINING/SUPPORT ESTIMATED EFFORT' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Estimated Effort - Training/Support'', (select es.EffortSize from AORRelease arl join EffortSize es on arl.TrainingSupportEffortID = es.EffortSizeID where AORReleaseID = ' + @ItemID + '), (select es.EffortSize from EffortSize es where es.EffortSizeID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set TrainingSupportEffortID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'WORKLOAD ALLOCATION' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Workload Allocation'', (select wa.WorkloadAllocation from AORRelease arl join WorkloadAllocation wa on arl.WorkloadAllocationID = wa.WorkloadAllocationID where arl.AORReleaseID = ' + @ItemID + '), (select wa.WorkloadAllocation from WorkloadAllocation wa where wa.WorkloadAllocationID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set WorkloadAllocationID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'CRITICAL PATH TEAM' then 
					'update AORRelease set CriticalPathAORTeamID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'APPROVED' then 
					'update AOR set Approved = ' + @Value + ', ApprovedByID = ' + (case when @Value = '1' then '(case when ' + @Value + ' != Approved then ' + @updatedByID + ' else ApprovedByID end)' else 'null' end) + ', ApprovedDate = ' + (case when @Value = '1' then '(case when ' + @Value + ' != Approved then ''' + @date + ''' else ApprovedDate end)' else 'null' end) + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORID = ' + @ItemID + ';'
				when @fieldName = 'VISIBLE TO CUSTOMER' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Visible To Customer'', (select case when AORCustomerFlagship = 1 then ''Yes'' else ''No'' end from AORRelease arl where AORReleaseID = ' + @ItemID + '), (case when ' + @Value + ' = 1 then ''Yes'' else ''No'' end ), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set AORCustomerFlagship = ' + @Value + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'IP1' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''IP1'', (select s.STATUS from AORRelease arl join STATUS s on arl.IP1StatusID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select s.STATUS from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set IP1StatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'IP2' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''IP2'', (select s.STATUS from AORRelease arl join STATUS s on arl.IP2StatusID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select s.STATUS from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set IP2StatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'IP3' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''IP3'', (select s.STATUS from AORRelease arl join STATUS s on arl.IP3StatusID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select s.STATUS from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set IP3StatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'INV' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Investigation (Inv)'', (select s.STATUS + '' - '' + s.DESCRIPTION from AORRelease arl join STATUS s on arl.InvestigationStatusID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select s.STATUS + '' - '' + s.DESCRIPTION from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set InvestigationStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'TD' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Technical (TD)'', (select s.STATUS + '' - '' + s.DESCRIPTION from AORRelease arl join STATUS s on arl.TechnicalStatusID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select s.STATUS + '' - '' + s.DESCRIPTION from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set TechnicalStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'CD' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Customer Design (CD)'', (select s.STATUS + '' - '' + s.DESCRIPTION from AORRelease arl join STATUS s on arl.CustomerDesignStatusID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select s.STATUS + '' - '' + s.DESCRIPTION from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set CustomerDesignStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'C' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Coding (C)'', (select s.STATUS + '' - '' + s.DESCRIPTION from AORRelease arl join STATUS s on arl.CodingStatusID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select s.STATUS + '' - '' + s.DESCRIPTION from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set CodingStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'IT' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Internal Testing (IT)'', (select s.STATUS + '' - '' + s.DESCRIPTION from AORRelease arl join STATUS s on arl.InternalTestingStatusID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select s.STATUS + '' - '' + s.DESCRIPTION from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set InternalTestingStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'CVT' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Customer Validation Testing (CVT)'', (select s.STATUS + '' - '' + s.DESCRIPTION from AORRelease arl join STATUS s on arl.CustomerValidationTestingStatusID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select s.STATUS + '' - '' + s.DESCRIPTION from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set CustomerValidationTestingStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'ADOPT' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Adoption (Adopt)'', (select s.STATUS + '' - '' + s.DESCRIPTION from AORRelease arl join STATUS s on arl.AdoptionStatusID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select s.STATUS + '' - '' + s.DESCRIPTION from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set AdoptionStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'CMMI' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''CMMI'', (select s.STATUS + '' ('' + s.DESCRIPTION + '')'' from AORRelease arl join STATUS s on arl.CMMIStatusID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select s.STATUS + '' ('' + s.DESCRIPTION + '')'' from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set CMMIStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				when @fieldName = 'CYBER REVIEW' then 
					'insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
					values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Cyber Review'', (select CONVERT(varchar(10), s.SORT_ORDER) + '' - '' + s.STATUS + '' ('' + s.DESCRIPTION + '')'' from AORRelease arl join STATUS s on arl.CyberID = s.StatusID where AORReleaseID = ' + @ItemID + '), (select CONVERT(varchar(10), s.SORT_ORDER) + '' - '' + s.STATUS + '' ('' + s.DESCRIPTION + '')'' from STATUS s where s.StatusID = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
					update AORRelease set CyberID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseID = ' + @ItemID + ';'
				else '' end;
		end;
	else if @typeName = 'AOR ATTACHMENT'
		begin
			set @updates =
				case when @fieldName = 'AOR ATTACHMENT NAME' then 'update AORReleaseAttachment set AORReleaseAttachmentName = ''' + replace(@Value, '''', '''''') + ''', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseAttachmentID = ' + @ItemID + ';'
				when @fieldName = 'DESCRIPTION' then 'update AORReleaseAttachment set [Description] = ''' + replace(@Value, '''', '''''') + ''', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseAttachmentID = ' + @ItemID + ';'
				when @fieldName = 'INV' then 'update AORReleaseAttachment set InvestigationStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseAttachmentID = ' + @ItemID + ';'
				when @fieldName = 'TD' then 'update AORReleaseAttachment set TechnicalStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseAttachmentID = ' + @ItemID + ';'
				when @fieldName = 'CD' then 'update AORReleaseAttachment set CustomerDesignStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseAttachmentID = ' + @ItemID + ';'
				when @fieldName = 'C' then 'update AORReleaseAttachment set CodingStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseAttachmentID = ' + @ItemID + ';'
				when @fieldName = 'IT' then 'update AORReleaseAttachment set InternalTestingStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseAttachmentID = ' + @ItemID + ';'
				when @fieldName = 'CVT' then 'update AORReleaseAttachment set CustomerValidationTestingStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseAttachmentID = ' + @ItemID + ';'
				when @fieldName = 'ADOPT' then 'update AORReleaseAttachment set AdoptionStatusID = ' + case when @Value = '0' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseAttachmentID = ' + @ItemID + ';'
				else '' end;
		end;
	else if @typeName = 'AOR MEETING'
		begin
			set @updates =
				case when @fieldName = 'AOR MEETING NAME' then 'update AORMeeting set AORMeetingName = ''' + replace(@Value, '''', '''''') + ''', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORMeetingID = ' + @ItemID + ';'
				when @fieldName = 'DESCRIPTION' then 'update AORMeeting set [Description] = ''' + replace(@Value, '''', '''''') + ''', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORMeetingID = ' + @ItemID + ';'
				when @fieldName = 'SORT' then 'update AORMeeting set Sort = ' + case when @Value = '' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORMeetingID = ' + @ItemID + ';'
				else '' end;
		end;
	else if @typeName = 'AOR MEETING INSTANCE'
		begin
			set @updates =
				case when @fieldName = 'MEETING INSTANCE NAME' then 'update AORMeetingInstance set AORMeetingInstanceName = ''' + replace(@Value, '''', '''''') + ''', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORMeetingInstanceID = ' + @ItemID + ';'
				when @fieldName = 'SORT' then 'update AORMeetingInstance set Sort = ' + case when @Value = '' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORMeetingInstanceID = ' + @ItemID + ';'
				else '' end;
		end;
	else if @typeName = 'CR'
		begin
			set @updates =
				case when @fieldName = 'CR CUSTOMER TITLE' then 'update AORCR set CRName = ''' + replace(@Value, '''', '''''') + ''', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where CRID = ' + @ItemID + ';'
				when @fieldName = 'CR INTERNAL TITLE' then 'update AORCR set Title = ''' + replace(@Value, '''', '''''') + ''', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where CRID = ' + @ItemID + ';'
				when @fieldName = 'SORT' then 'update AORCR set Sort = ' + case when @Value = '' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where CRID = ' + @ItemID + ';'
				when @fieldName = 'CYBER/ISMT' then 'update AORCR set CyberISMT = ' + case when @Value = '' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where CRID = ' + @ItemID + ';'
				else '' end;
		end;
	else if @typeName = 'CROSSWALK'
		begin
			set @updates =
				case when @fieldName = 'PERCENT COMPLETE' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Percent Complete'', (select COMPLETIONPERCENT from WORKITEM where WORKITEMID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else @Value end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set COMPLETIONPERCENT = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Percent Complete'', (select COMPLETIONPERCENT from WORKITEM_TASK where WORKITEM_TASKID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else @Value end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set COMPLETIONPERCENT = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'CUSTOMER RANK' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Customer Rank'', (select PrimaryBusinessRank from WORKITEM where WORKITEMID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else @Value end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set PrimaryBusinessRank = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Customer Rank'', (select BusinessRank from WORKITEM_TASK where WORKITEM_TASKID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else @Value end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set BusinessRank = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'TECH. RANK' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Tech. Rank'', (select RESOURCEPRIORITYRANK from WORKITEM where WORKITEMID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else @Value end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set RESOURCEPRIORITYRANK = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Tech. Rank'', (select SORT_ORDER from WORKITEM_TASK where WORKITEM_TASKID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else @Value end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set SORT_ORDER = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'Title' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Title'', (select Title from WORKITEM where WORKITEMID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else '''' + replace(@Value, '''', '''''') + '''' end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set Title = ' + case when @Value = '' then 'null' else '''' + replace(@Value, '''', '''''') + '''' end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Title'', (select Title from WORKITEM_TASK where WORKITEM_TASKID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else '''' + replace(@Value, '''', '''''') + '''' end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set Title = ' + case when @Value = '' then 'null' else '''' + replace(@Value, '''', '''''') + '''' end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'SR NUMBER' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''SR Number'', (select SR_NUMBER from WORKITEM where WORKITEMID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else @Value end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set SR_NUMBER = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''SR Number'', (select SRNUMBER from WORKITEM_TASK where WORKITEM_TASKID = ' + @ItemID + '), ' + case when @Value = '' then 'null' else @Value end + ', ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set SRNUMBER = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'Assigned Resource' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Assigned To'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM wi join WTS_RESOURCE wr on wi.ASSIGNEDRESOURCEID = wr.WTS_RESOURCEID where wi.WORKITEMID = ' + @ItemID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set ASSIGNEDRESOURCEID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Assigned To'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM_TASK wit join WTS_RESOURCE wr on wit.ASSIGNEDRESOURCEID = wr.WTS_RESOURCEID where wit.WORKITEM_TASKID = ' + @ItemID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set ASSIGNEDRESOURCEID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'Primary Bus Resource' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Primary Bus. Resource'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM wi join WTS_RESOURCE wr on wi.PrimaryBusinessResourceID = wr.WTS_RESOURCEID where wi.WORKITEMID = ' + @ItemID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set PrimaryBusinessResourceID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Primary Bus. Resource'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM_TASK wit join WTS_RESOURCE wr on wit.PRIMARYBUSRESOURCEID = wr.WTS_RESOURCEID where wit.WORKITEM_TASKID = ' + @ItemID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set PRIMARYBUSRESOURCEID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'Primary Resource' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Primary Resource'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM wi join WTS_RESOURCE wr on wi.PRIMARYRESOURCEID = wr.WTS_RESOURCEID where wi.WORKITEMID = ' + @ItemID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set PRIMARYRESOURCEID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Primary Resource'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM_TASK wit join WTS_RESOURCE wr on wit.PrimaryResourceID = wr.WTS_RESOURCEID where wit.WORKITEM_TASKID = ' + @ItemID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set PrimaryResourceID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'Secondary Bus Resource' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Secondary Bus. Resource'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM wi join WTS_RESOURCE wr on wi.SecondaryBusinessResourceID = wr.WTS_RESOURCEID where wi.WORKITEMID = ' + @ItemID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set SecondaryBusinessResourceID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Secondary Bus. Resource'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM_TASK wit join WTS_RESOURCE wr on wit.SECONDARYBUSRESOURCEID = wr.WTS_RESOURCEID where wit.WORKITEM_TASKID = ' + @ItemID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set SECONDARYBUSRESOURCEID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'Secondary Tech Resource' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Secondary Tech. Resource'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM wi join WTS_RESOURCE wr on wi.SECONDARYRESOURCEID = wr.WTS_RESOURCEID where wi.WORKITEMID = ' + @ItemID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set SECONDARYRESOURCEID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Secondary Tech. Resource'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM_TASK wit join WTS_RESOURCE wr on wit.SecondaryResourceID = wr.WTS_RESOURCEID where wit.WORKITEM_TASKID = ' + @ItemID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set SecondaryResourceID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'ALLOCATION ASSIGNMENT' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Contract Allocation Assignment'', (select a.ALLOCATION from WORKITEM wi join ALLOCATION a on wi.ALLOCATIONID = a.ALLOCATIONID where wi.WORKITEMID = ' + @ItemID + '), (select a.ALLOCATION from ALLOCATION a WHERE a.ALLOCATIONID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set ALLOCATIONID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'Status' then
					case when @BlnSubTask = '0' then
						'
						select @Old_StatusID = wi.STATUSID from WORKITEM wi where wi.WORKITEMID = ' + @ItemID + ';
						select @SRNumber = wi.SR_Number from WORKITEM wi where wi.WORKITEMID = ' + @ItemID + ';
						select @AssignedToRankID = wi.AssignedToRankID from WORKITEM wi where wi.WORKITEMID = ' + @ItemID + ';
						select @BusinessRank = wi.PrimaryBusinessRank from WORKITEM wi where wi.WORKITEMID = ' + @ItemID + ';

						insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Status'', (select s.[STATUS] from WORKITEM wi join [STATUS] s on wi.STATUSID = s.STATUSID where s.StatusTypeID = 1 AND wi.WORKITEMID = ' + @ItemID + '), (select s.[STATUS] from [STATUS] s WHERE s.StatusTypeID = 1 AND s.STATUSID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set STATUSID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
						+
						' if ' + @Value + ' = 2 and @Old_StatusID = 10 --re-opened from closed
							begin
								--try to get previous assigned to rank and customer rank if not changed by user
								if @BusinessRank = 99
									begin try
										select @BusinessRank = isnull(convert(int, max(t.OldValue)), 3)
										from (
											select OldValue,
												row_number() over(partition by WORKITEMID order by CREATEDDATE desc) as rn
											from WORKITEM_HISTORY
											where WORKITEMID = ' + @ItemID + '
											and ITEM_UPDATETYPEID = 5
											and FieldChanged = ''Customer Rank''
											and NewValue = ''99''
										) t
										where t.rn = 1;

										if @BusinessRank = 99
											begin
												set @BusinessRank = 3;
											end;

										insert into WORKITEM_HISTORY(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
										values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Customer Rank'', (select PrimaryBusinessRank from WORKITEM where WORKITEMID = ' + @ItemID + '), @BusinessRank, ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
										update WORKITEM set PrimaryBusinessRank = @BusinessRank, UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';
									end try
									begin catch
										set @BusinessRank = 3;
										insert into WORKITEM_HISTORY(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
										values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Customer Rank'', (select PrimaryBusinessRank from WORKITEM where WORKITEMID = ' + @ItemID + '), @BusinessRank, ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
										update WORKITEM set PrimaryBusinessRank = @BusinessRank, UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';
									end catch;

								if @AssignedToRankID = 31 --6-closed
									begin try
										select @AssignedToRankID = isnull(max(p.PRIORITYID), 29)
										from (
											select OldValue,
												row_number() over(partition by WORKITEMID order by CREATEDDATE desc) as rn
											from WORKITEM_HISTORY
											where WORKITEMID = ' + @ItemID + '
											and ITEM_UPDATETYPEID = 5
											and FieldChanged = ''Assigned To Rank''
											and NewValue = ''6 - Closed Workload''
										) t
										join [PRIORITY] p
										on t.OldValue = p.[PRIORITY]
										where t.rn = 1

										if @AssignedToRankID = 31
											begin
												set @AssignedToRankID = 29
											end;

										insert into WORKITEM_HISTORY(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
										values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Assigned To Rank'', (select p.[PRIORITY] from WORKITEM wi join [PRIORITY] p on wi.AssignedToRankID = p.PRIORITYID where wi.WORKITEMID = ' + @ItemID + '), (select p.[PRIORITY] from [PRIORITY] p WHERE p.PRIORITYID  = @AssignedToRankID), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
										update WORKITEM set AssignedToRankID = @AssignedToRankID, UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';
									end try
									begin catch
										set @AssignedToRankID = 29 --4-staged
										insert into WORKITEM_HISTORY(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
										values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Assigned To Rank'', (select p.[PRIORITY] from WORKITEM wi join [PRIORITY] p on wi.AssignedToRankID = p.PRIORITYID where wi.WORKITEMID = ' + @ItemID + '), (select p.[PRIORITY] from [PRIORITY] p WHERE p.PRIORITYID  = @AssignedToRankID), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
										update WORKITEM set AssignedToRankID = @AssignedToRankID, UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';
									end catch;
							end;' +
						'
						begin
							if ' + @Value + ' != 10 and @Old_StatusID = 10 --Anything from closed
								select @CurAORRelease = ''<aors><save><aorreleaseid>'' + convert(nvarchar(10),isnull(arl.AORReleaseID,0)) + ''</aorreleaseid><aorworktypeid>2</aorworktypeid></save></aors>'' 
								from AORRelease arl
								where arl.[Current] = 1
								and arl.AORWorkTypeID = 2
								and exists (select 1
											from AORReleaseTask art2
											join AORRelease arl2
											on art2.AORReleaseID = arl2.AORReleaseID
											where arl2.AORID = arl.AORID 
											and arl2.AORWorkTypeID = 2
											and art2.WORKITEMID = ' + @ItemID + '
											)
								;

								exec [dbo].AORTask_Save
									@TaskID = ' + @ItemID + ',
									@AORs = @CurAORRelease,
									@CascadeAOR = 0,
									@Add = 0,
									@UpdatedBy = ''' + @UpdatedBy + '''
									;
							end;'
							+
							'
							begin
								IF ' + @Value + ' = 10 AND @Old_StatusID != 10 AND @SRNumber > 0 AND 
									(select count(wi.SR_Number)
									from WORKITEM wi
									where @SRNumber = wi.SR_Number
									and wi.WORKITEMID = ' + @ItemID + ') - (select count(wi.SR_Number)
									from WORKITEM wi
									where @SRNumber = wi.SR_Number
									and wi.STATUSID = 10
									and wi.WORKITEMID = ' + @ItemID + ') = 0
									BEGIN
										UPDATE SR
										set Closed = 1,
											UpdatedBy = ''' + @UpdatedBy + ''',
											UpdatedDate = ''' + @date + '''
										where SRID = @SRNumber
									END;
							end;'
					when @BlnSubTask = '1' then
						'
						select @Old_StatusID = wit.STATUSID from WORKITEM_TASK wit where wit.WORKITEM_TASKID = ' + @ItemID + ';
						select @SRNumber = wit.SRNumber from WORKITEM_TASK wit where wit.WORKITEM_TASKID = ' + @ItemID + ';
						select @AssignedToRankID = wit.AssignedToRankID from WORKITEM_TASK wit where wit.WORKITEM_TASKID = ' + @ItemID + ';
						select @BusinessRank = wit.BusinessRank from WORKITEM_TASK wit where wit.WORKITEM_TASKID = ' + @ItemID + ';

						insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Status'', (select s.[STATUS] from WORKITEM_TASK wit join [STATUS] s on wit.STATUSID = s.STATUSID where s.StatusTypeID = 1 AND wit.WORKITEM_TASKID = ' + @ItemID + '), (select s.[STATUS] from [STATUS] s WHERE s.StatusTypeID = 1 AND  s.STATUSID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set STATUSID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
						+
						' if ' + @Value + ' = 2 and @Old_StatusID = 10 --re-opened from closed
							begin
								--try to get previous assigned to rank and customer rank if not changed by user
								if @BusinessRank = 99
									begin try
										select @BusinessRank = isnull(convert(int, max(t.OldValue)), 3)
										from (
											select OldValue,
												row_number() over(partition by WORKITEM_TASKID order by CREATEDDATE desc) as rn
											from WORKITEM_TASK_HISTORY
											where WORKITEM_TASKID = ' + @ItemID + '
											and ITEM_UPDATETYPEID = 5
											and FieldChanged = ''Customer Rank''
											and NewValue = ''99''
										) t
										where t.rn = 1;

										if @BusinessRank = 99
											begin
												set @BusinessRank = 3;
											end;

										insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
										values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Customer Rank'', (select BusinessRank from WORKITEM_TASK where WORKITEM_TASKID = ' + @ItemID + '), @BusinessRank, ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
										update WORKITEM_TASK set BusinessRank = @BusinessRank, UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';
									end try
									begin catch
										set @BusinessRank = 3;
										insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
										values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Customer Rank'', (select BusinessRank from WORKITEM_TASK where WORKITEM_TASKID = ' + @ItemID + '), @BusinessRank, ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
										update WORKITEM_TASK set BusinessRank = @BusinessRank, UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';
									end catch;

								if @AssignedToRankID = 31 --6-closed
									begin try
										select @AssignedToRankID = isnull(max(p.PRIORITYID), 29)
										from (
											select OldValue,
												row_number() over(partition by WORKITEM_TASKID order by CREATEDDATE desc) as rn
											from WORKITEM_TASK_HISTORY
											where WORKITEM_TASKID = ' + @ItemID + '
											and ITEM_UPDATETYPEID = 5
											and FieldChanged = ''Assigned To Rank''
											and NewValue = ''6 - Closed Workload''
										) t
										join [PRIORITY] p
										on t.OldValue = p.[PRIORITY]
										where t.rn = 1

										if @AssignedToRankID = 31
											begin
												set @AssignedToRankID = 29
											end;

										insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
										values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Assigned To Rank'', (select p.[PRIORITY] from WORKITEM_TASK wit join [PRIORITY] p on wit.AssignedToRankID = p.PRIORITYID where wit.WORKITEM_TASKID = ' + @ItemID + '), (select p.[PRIORITY] from [PRIORITY] p WHERE p.PRIORITYID  = @AssignedToRankID), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
										update WORKITEM_TASK set AssignedToRankID = @AssignedToRankID, UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';
									end try
									begin catch
										set @AssignedToRankID = 29 --4-staged
										insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
										values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Assigned To Rank'', (select p.[PRIORITY] from WORKITEM_TASK wit join [PRIORITY] p on wit.AssignedToRankID = p.PRIORITYID where wit.WORKITEM_TASKID = ' + @ItemID + '), (select p.[PRIORITY] from [PRIORITY] p WHERE p.PRIORITYID  = @AssignedToRankID), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
										update WORKITEM_TASK set AssignedToRankID = @AssignedToRankID, UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';
									end catch;
							end;' +
						'
						begin
							if ' + @Value + ' != 10 and @Old_StatusID = 10 --Anything from closed
								begin
									exec AORSubTaskReleaseMGMTProductVersion_Save
										@SubTaskID =  ' + @ItemID + ',
										@Add = 0,
										@UpdatedBy = ''' + @UpdatedBy + ''',
										@Saved = null;
								end;
						end;'
						+
						'
						begin
							IF ' + @Value + ' = 10 AND @Old_StatusID != 10 AND @SRNumber > 0 AND 
								(select count(wit.SRNumber)
								from WORKITEM_TASK wit
								where @SRNumber = wit.SRNumber
								and wit.WORKITEM_TASKID = ' + @ItemID + ') - (select count(wit.SRNumber)
								from WORKITEM_TASK wit
								where @SRNumber = wit.SRNumber
								and wit.STATUSID = 10
								and wit.WORKITEM_TASKID = ' + @ItemID + ') = 0
								BEGIN
									UPDATE SR
									set Closed = 1,
										UpdatedBy = ''' + @UpdatedBy + ''',
										UpdatedDate = ''' + @date + '''
									where SRID = @SRNumber
								END;
						end;'
					else '' end
				when @fieldName = 'Priority' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Priority'', (select p.[PRIORITY] from WORKITEM wi join [PRIORITY] p on wi.PRIORITYID = p.PRIORITYID where wi.WORKITEMID = ' + @ItemID + '), (select p.[PRIORITY] from [PRIORITY] p WHERE p.PRIORITYID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set PRIORITYID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Priority'', (select p.[PRIORITY] from WORKITEM_TASK wit join [PRIORITY] p on wit.PRIORITYID = p.PRIORITYID where wit.WORKITEM_TASKID = ' + @ItemID + '), (select p.[PRIORITY] from [PRIORITY] p WHERE p.PRIORITYID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set PRIORITYID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'WORK REQUEST' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Work Request'', (select wr.TITLE from WORKITEM wi join WORKREQUEST wr on wi.WORKREQUESTID = wr.WORKREQUESTID where wi.WORKITEMID = ' + @ItemID + '), (select wr.TITLE from WORKREQUEST wr WHERE wr.WORKREQUESTID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set WORKREQUESTID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'RESOURCE GROUP' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Resource Group'', (select wt.WorkType from WORKITEM wi join WorkType wt on wi.WorkTypeID = wt.WorkTypeID where wi.WORKITEMID = ' + @ItemID + '), (select wt.WorkType from WorkType wt WHERE wt.WorkTypeID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set WorkTypeID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'WORK AREA' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Work Area'', (select wa.WorkArea from WORKITEM wi join WorkArea wa on wi.WorkAreaID = wa.WorkAreaID where wi.WORKITEMID = ' + @ItemID + '), (select wa.WorkArea from WorkArea wa WHERE wa.WorkAreaID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set WorkAreaID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'SYSTEM(TASK)' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''System(Task)'', (select ws.WTS_SYSTEM from WORKITEM wi join WTS_SYSTEM ws on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID where wi.WORKITEMID = ' + @ItemID + '), (select ws.WTS_SYSTEM from WTS_SYSTEM ws WHERE ws.WTS_SYSTEMID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set WTS_SYSTEMID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'PRODUCTION STATUS' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Production Status'', (select s.[STATUS] from WORKITEM wi join [STATUS] s on wi.ProductionStatusID = s.STATUSID JOIN StatusType st ON s.StatusTypeID = st.StatusTypeID where UPPER(st.StatusType) = ''PRODUCTION'' AND wi.WORKITEMID = ' + @ItemID + '), (select s.[STATUS] from [STATUS] s JOIN StatusType st ON s.StatusTypeID = st.StatusTypeID where UPPER(st.StatusType) = ''PRODUCTION'' AND s.STATUSID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set ProductionStatusID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'PRODUCT VERSION' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Product Version'', (select pv.ProductVersion from WORKITEM wi join ProductVersion pv on wi.ProductVersionID = pv.ProductVersionID where wi.WORKITEMID = ' + @ItemID + '), (select pv.ProductVersion from ProductVersion pv WHERE pv.ProductVersionID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set ProductVersionID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'PDD TDR' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''PD2TDR Phase'', (select pp.PDDTDR_PHASE from WORKITEM wi join PDDTDR_PHASE pp on wi.PDDTDR_PHASEID = pp.PDDTDR_PHASEID where wi.WORKITEMID = ' + @ItemID + '), (select pp.PDDTDR_PHASE from PDDTDR_PHASE pp WHERE pp.PDDTDR_PHASEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set PDDTDR_PHASEID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'WORK ACTIVITY' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Work Activity'', (select it.WORKITEMTYPE from WORKITEM wi join WORKITEMTYPE it on wi.WORKITEMTYPEID = it.WORKITEMTYPEID where wi.WORKITEMID = ' + @ItemID + '), (select it.WORKITEMTYPE from WORKITEMTYPE it WHERE it.WORKITEMTYPEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set WORKITEMTYPEID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					else 'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Work Activity'', (select it.WORKITEMTYPE from WORKITEM_TASK wit join WORKITEMTYPE it on wit.WORKITEMTYPEID = it.WORKITEMTYPEID where wit.WORKITEM_TASKID = ' + @ItemID + '), (select it.WORKITEMTYPE from WORKITEMTYPE it WHERE it.WORKITEMTYPEID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set WORKITEMTYPEID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					end
				when @fieldName = 'FUNCTIONALITY' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Functionality'', (select wg.WorkloadGroup from WORKITEM wi join WorkloadGroup wg on wi.WorkloadGroupID = wg.WorkloadGroupID where wi.WORKITEMID = ' + @ItemID + '), (select wg.WorkloadGroup from WorkloadGroup wg WHERE wg.WorkloadGroupID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set WorkloadGroupID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'Assigned To Rank' then
					case when @BlnSubTask = '0' then
						'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Assigned To Rank'', (select p.[PRIORITY] from WORKITEM wi join [PRIORITY] p on wi.AssignedToRankID = p.PRIORITYID where wi.WORKITEMID = ' + @ItemID + '), (select p.[PRIORITY] from [PRIORITY] p WHERE p.PRIORITYID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM set AssignedToRankID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
					when @BlnSubTask = '1' then
						'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
						values(' + @itemUpdateTypeID + ', ' + @ItemID + ', ''Assigned To Rank'', (select p.[PRIORITY] from WORKITEM_TASK wit join [PRIORITY] p on wit.AssignedToRankID = p.PRIORITYID where wit.WORKITEM_TASKID = ' + @ItemID + '), (select p.[PRIORITY] from [PRIORITY] p WHERE p.PRIORITYID  = ' + @Value + '), ''' + @UpdatedBy + ''', ''' + @UpdatedBy + ''');
						update WORKITEM_TASK set AssignedToRankID = ' + case when @Value = '' then 'null' else @Value end + ', UPDATEDBY = ''' + @UpdatedBy + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @ItemID + ';'
					else '' end
				when @fieldName = 'Workload MGMT' or @fieldName = 'Release/Deployment MGMT' then
					case when @BlnSubTask = '0' then
						'	begin
								set @Cascade = (select distinct isnull(rta.CascadeAOR,0)
								from AOR
								join AORRelease arl
								on AOR.AORID = arl.AORID
								join AORReleaseTask rta
								on arl.AORReleaseID = rta.AORReleaseID
								join WORKITEM wi
								on rta.WORKITEMID = wi.WORKITEMID
								where arl.[Current] = 1
								and AOR.Archive = 0
								and rta.WORKITEMID = ' + @ItemID + ');

								exec [dbo].AORTask_Save
										@TaskID = ' + @ItemID + ',
										@AORs = ''<aors><save><aorreleaseid>' + @Value + '</aorreleaseid><aorworktypeid>' + @AORWorkTypeID + '</aorworktypeid></save></aors>'',
										@CascadeAOR = @Cascade,
										@Add = 0,
										@UpdatedBy = ''' + @UpdatedBy + '''
										;

								--if @Cascade = 1
								--	begin
								--		declare cur CURSOR LOCAL for
								--			select wit.WORKITEM_TASKID
								--			from WORKITEM_TASK wit
								--			join WORKITEM wi ON wit.WORKITEMID = wi.WORKITEMID
								--			WHERE wi.WORKITEMID = ' + @ItemID + ';

								--		open cur
								--		fetch next from cur into @field1
								--		while @@FETCH_STATUS = 0 BEGIN

								--			exec [dbo].AORSubTask_Save
								--					@SubTaskID = @field1,
								--					@AORs = ''<aors><save><aorreleaseid>' + @Value + '</aorreleaseid></save></aors>'',
								--					@CascadeAOR = @Cascade,
								--					@Add = 0,
								--					@UpdatedBy = ''' + @UpdatedBy + '''
								--				;

								--			fetch next from cur into @field1
								--		END

								--		close cur
								--		deallocate cur
								--	end;
							end;'
					when @BlnSubTask = '1' then
						'begin
							set @Cascade = (select distinct isnull(rta.CascadeAOR,0)
								from AOR
								join AORRelease arl
								on AOR.AORID = arl.AORID
								join AORReleaseTask rta
								on arl.AORReleaseID = rta.AORReleaseID
								join WORKITEM wi
								on rta.WORKITEMID = wi.WORKITEMID
								join WORKITEM_TASK wit
								on wi.WORKITEMID = wit.WORKITEMID
								join AORReleaseSubTask rsta
								on arl.AORReleaseID = rsta.AORReleaseID
								and wit.WORKITEM_TASKID = rsta.WORKITEMTASKID
								where arl.[Current] = 1
								and AOR.Archive = 0
								and wit.WORKITEM_TASKID = ' + @ItemID + ');

							exec [dbo].AORSubTask_Save
									@SubTaskID = ' + @ItemID + ',
									@AORs = ''<aors><save><aorreleaseid>' + @Value + '</aorreleaseid></save></aors>'',
									@CascadeAOR = @Cascade,
									@Add = 0,
									@UpdatedBy = ''' + @UpdatedBy + '''
									;
						end;'
					else '' end
				else '' end;
		end;
	else if @typeName = 'SYSTEM RESOURCE'
		begin
			set @updates =
				case when @fieldName = 'ALLOCATION %' then 'update WTS_SYSTEM_RESOURCE set Allocation = ' + @Value + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where WTS_SYSTEM_RESOURCEID = ' + @ItemID + ';'
				else '' end;
		end;
	else if @typeName = 'RQMT'
		begin
			-- @ExtData = rqmtID,systemID,workareaID,rqmttypeID,rqmtsetID
			declare @idx1 int = charindex(',', @ExtData, 1)
			declare @idx2 int = charindex(',', @ExtData, @idx1 + 1)
			declare @idx3 int = charindex(',', @ExtData, @idx2 + 1)
			declare @idx4 int = charindex(',', @ExtData, @idx3 + 1)

			declare @rqmtID nvarchar(100) = substring(@ExtData, 1, @idx1 - 1)
			declare @systemID nvarchar(100) = substring(@ExtData, @idx1 + 1, @idx2 - (@idx1 + 1))
			declare @workareaID nvarchar(100) = substring(@ExtData, @idx2 + 1, @idx3 - (@idx2 + 1))
			declare @rqmttypeID nvarchar(100) = substring(@ExtData, @idx3 + 1, @idx4 - (@idx3 + 1))
			declare @rqmtsetIDStr nvarchar(100) = substring(@ExtData, @idx4 + 1, (len(@ExtData) - @idx4))

			declare @RQMTSystemID INT = 0
			declare @RQMTSystemIDSTR VARCHAR(10)
			declare @RQMTSet_RQMTSystemID INT = 0
			declare @RQMTSetID INT = 0
			declare @RQMTSet_RQMTSystem_UsageID INT = 0
			declare @RQMTSet_RQMTSystemIDSTR VARCHAR(100)

			if (@rqmtsetIDStr is not null) set @RQMTSetID = convert(int, @rqmtsetIDStr)
			if (isnull(@rqmtID, 0) <> 0 and @systemID is not null) set @RQMTSystemID = (select RQMTSystemID from RQMTSystem where RQMTID = @rqmtID and WTS_SYSTEMID = @systemID)
			if (@RQMTSetID > 0 AND @RQMTSystemID > 0) set @RQMTSet_RQMTSystemID = (select RQMTSet_RQMTSystemID from RQMTSet_RQMTSystem rsrs WHERE rsrs.RQMTSystemID = @RQMTSystemID and rsrs.RQMTSetID = @RQMTSetID)
			if (@RQMTSet_RQMTSystemID > 0) set @RQMTSet_RQMTSystem_UsageID = (select RQMTSet_RQMTSystem_UsageID from RQMTSet_RQMTSystem_Usage where RQMTSet_RQMTSystemID = @RQMTSet_RQMTSystemID)
			set @RQMTSystemIDSTR = CONVERT(VARCHAR(10), @RQMTSystemID)
			set @RQMTSet_RQMTSystemIDSTR = CONVERT(VARCHAR(10), @RQMTSet_RQMTSystemID)

			-- note that in some cases we have to declare variables in these blocks; because there could be updates to multiple rqmts at once, we have to give these variables unique
			-- names so they don't throw errors for having been previously declared
			
			set @updates =
				case when @fieldName = 'RQMT Status' then 
					'DECLARE @RQMTStatusID_OLD_' + @RQMTSystemIDSTR + ' VARCHAR(10) = (SELECT RQMTStatusID FROM RQMTSystem WHERE RQMTSystemID = ' + @RQMTSystemIDSTR + ');' +
					'EXEC dbo.AuditLog_Save ' + @RQMTSystemIDSTR + ', ' + @rqmtID + ', 7, 5, ''RQMTStatus'', @RQMTStatusID_OLD_' + @RQMTSystemIDSTR + ', ' + (CASE WHEN @value <= 0 THEN 'NULL' ELSE @value END) + ', ''' + @date + ''', ''' + @UpdatedBy + ''';' +
					'update RQMTSystem set RQMTStatusID = ' + (CASE WHEN @value <= 0 THEN 'NULL' ELSE @value END) + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where RQMTSystemID = ' + @RQMTSystemIDSTR + ';'
				when @fieldName = 'Criticality' then 
					'DECLARE @RQMTCriticalityID_OLD_' + @RQMTSystemIDSTR + ' VARCHAR(10) = (SELECT CriticalityID FROM RQMTSystem WHERE RQMTSystemID = ' + @RQMTSystemIDSTR + ');' +
					'EXEC dbo.AuditLog_Save ' + @RQMTSystemIDSTR + ', ' + @rqmtID + ', 7, 5, ''RQMTCriticality'', @RQMTCriticalityID_OLD_' + @RQMTSystemIDSTR + ', ' + (CASE WHEN @value <= 0 THEN 'NULL' ELSE @value END) + ', ''' + @date + ''', ''' + @UpdatedBy + ''';' +
					'update RQMTSystem set CriticalityID = ' + (CASE WHEN @value <= 0 THEN 'NULL' ELSE @value END) + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where RQMTSystemID = ' + @RQMTSystemIDSTR + ';'
				when @fieldName = 'RQMT Stage' then 
					'DECLARE @RQMTStageID_OLD_' + @RQMTSystemIDSTR + ' VARCHAR(10) = (SELECT RQMTStageID FROM RQMTSystem WHERE RQMTSystemID = ' + @RQMTSystemIDSTR + ');' +
					'EXEC dbo.AuditLog_Save ' + @RQMTSystemIDSTR + ', ' + @rqmtID + ', 7, 5, ''RQMTStage'', @RQMTStageID_OLD_' + @RQMTSystemIDSTR + ', ' + (CASE WHEN @value <= 0 THEN 'NULL' ELSE @value END) + ', ''' + @date + ''', ''' + @UpdatedBy + ''';' +
					'update RQMTSystem set RQMTStageID = ' + (CASE WHEN @value <= 0 THEN 'NULL' ELSE @value END) + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where RQMTSystemID = ' + @RQMTSystemIDSTR + ';'					
				when @fieldName = 'RQMT Accepted' then 
					'DECLARE @RQMTAccepted_OLD_' + @RQMTSystemIDSTR + ' VARCHAR(10) = (SELECT RQMTAccepted FROM RQMTSystem WHERE RQMTSystemID = ' + @RQMTSystemIDSTR + ');' +
					'EXEC dbo.AuditLog_Save ' + @RQMTSystemIDSTR + ', ' + @rqmtID + ', 7, 5, ''RQMTAccepted'', @RQMTAccepted_OLD_' + @RQMTSystemIDSTR + ', ' + (CASE WHEN @value = 'true' THEN '1' ELSE '0' END) + ', ''' + @date + ''', ''' + @UpdatedBy + ''';' +
					'update RQMTSystem set RQMTAccepted = ' + (case when @value = 'true' then '1' else '0' end) + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where RQMTSystemID = ' + @RQMTSystemIDSTR + ';'
				when @fieldName like 'Month_%' then -- this block is trickier because the usage row may not exist (if it's never been set), so we sometimes have to accomodate the insert by creating a new row first and then updating it
					-- get old value
					'DECLARE @RQMTSet_RQMTSystemUsage_OLD_' + @fieldName + '_' + @RQMTSet_RQMTSystemIDSTR + ' VARCHAR(10) = ' + (CASE WHEN @RQMTSet_RQMTSystem_UsageID IS NULL THEN '0' ELSE '(SELECT ' + @fieldName + ' FROM RQMTSet_RQMTSystem_Usage WHERE RQMTSet_RQMTSystem_UsageID = ' + convert(varchar(10), @RQMTSet_RQMTSystem_UsageID) + ')' END) + ';' +
					-- if nothing exists insert it
					(CASE WHEN @RQMTSet_RQMTSystem_UsageID IS NULL THEN 'INSERT INTO RQMTSet_RQMTSystem_Usage VALUES (' + @RQMTSet_RQMTSystemIDSTR + ', 0,0,0,0,0,0,0,0,0,0,0,0);' ELSE '' END) +
					-- update the row (by rsrs id not usage id because we don't have it if it is a new insert - we COULD do scope identity if we wanted)
					'update RQMTSet_RQMTSystem_Usage set ' + @fieldName + ' = ' + (case when @value = 'true' then '1' else '0' end) + ' where RQMTSet_RQMTSystemID = ' + @RQMTSet_RQMTSystemIDSTR + ';' +
					-- declare a new usageid variable so we can find out what the id is of the existing or the newly inserted row
					'DECLARE @RQMTSet_RQMTSystemUsageID_' + @fieldName + '_' + @RQMTSet_RQMTSystemIDSTR + ' varchar(10) = (select RQMTSet_RQMTSystem_UsageID FROM RQMTSet_RQMTSystem_Usage where RQMTSet_RQMTSystemID = ' + @RQMTSet_RQMTSystemIDSTR + ');' +
					-- use the usageid variable to update the usage audit log
					'EXEC dbo.AuditLog_Save @RQMTSet_RQMTSystemUsageID_' + @fieldName + '_' + @RQMTSet_RQMTSystemIDSTR + ', ' + @RQMTSet_RQMTSystemIDSTR + ', 6, 5, ''RQMT Set Usage'', @RQMTSet_RQMTSystemUsage_OLD_' + @fieldName + '_' + @RQMTSet_RQMTSystemIDSTR  + ', ' + (CASE WHEN @value = 'true' THEN '1' ELSE '0' END) + ', ''' + @date + ''', ''' + @UpdatedBy + ''';'
				when @fieldName = 'RQMTSetComplexity' then 
					'declare @RQMTSet_ComplexityID_OLD_' + @rqmtsetIDStr + ' varchar(10) = (select RQMTComplexityID from RQMTSet where RQMTSetID = ' + @rqmtsetIDStr + ');' +
					'update RQMTSet set RQMTComplexityID = ' + @value+ ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where RQMTSetID = ' + @rqmtsetIDStr + ';' + 
					'exec dbo.AuditLog_Save ' + @rqmtsetIDStr + ', NULL, 2, 5, ''RQMTComplexity'', @RQMTSet_ComplexityID_OLD_' + @rqmtsetIDStr + ', ' + @value + ', ''' + @date + ''', ''' + @UpdatedBy + ''';'
				when @fieldName = 'RQMTSetJustification' then 
					'declare @RQMTSet_Justification_OLD_' + @rqmtsetIDStr + ' varchar(1000) = (select Justification from RQMTSet where RQMTSetID = ' + @rqmtsetIDStr + ');' +
					'update RQMTSet set Justification = ''' + REPLACE(@value,'''','''''') + ''', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where RQMTSetID = ' + @rqmtsetIDStr + ';' +
					'exec dbo.AuditLog_Save ' + @rqmtsetIDStr + ', NULL, 2, 5, ''Justification'', @RQMTSet_Justification_OLD_' + @rqmtsetIDStr + ', ' + @value + ', ''' + @date + ''', ''' + @UpdatedBy + ''';'
				else '' end			
		end;
	else if @typeName = 'RQMT DESCRIPTION'
		begin
			set @updates =
				case when @fieldName = 'RQMT DESCRIPTION TYPE' then 'update RQMTDescription set RQMTDescriptionTypeID = ' + @Value + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where RQMTDescriptionID = ' + @ItemID + ';'
				when @fieldName = 'RQMT DESCRIPTION' then 'update RQMTDescription set RQMTDescription = ''' + replace(@Value, '''', '''''') + ''', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where RQMTDescriptionID = ' + @ItemID + ';'
				when @fieldName = 'SORT' then 'update RQMTDescription set Sort = ' + case when @Value = '' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where RQMTDescriptionID = ' + @ItemID + ';'
				else '' end;
		end;
	else if @typeName = 'SR'
		begin
			set @updates =
				case when @fieldName = 'STATUS' AND @Value != 125 then 'update SR set STATUSID = ' + @Value + ', Closed = 0, UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where SRID = ' + @ItemID + ';'
				when @fieldName = 'STATUS' AND @Value = 125 then 'update SR set Closed = 1, UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where SRID = ' + @ItemID + ';'
				when @fieldName = 'REASONING' then 'update SR set SRTypeID = ' + @Value + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where SRID = ' + @ItemID + ';'
				when @fieldName = 'USER''S PRIORITY' then 'update SR set PRIORITYID = ' + @Value + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where SRID = ' + @ItemID + ';'
				when @fieldName = 'Investigation Priority' then 'update SR set INVPriorityID = ' + @Value + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where SRID = ' + @ItemID + ';'
				when @fieldName = 'SRRankID' AND @Value != 44 then 'update SR set SRRankID = ' + @Value + ', Closed = 0, UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where SRID = ' + @ItemID + ';'
				when @fieldName = 'SRRankID' AND @Value = 44 then 'update SR set Closed = 1, UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where SRID = ' + @ItemID + ';'
				when @fieldName = 'SORT' then 'update SR set Sort = ' + case when @Value = '' then 'null' else @Value end + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where SRID = ' + @ItemID + ';'
				else '' end;
		end;
	else if @typeName = 'AOR RELEASE RESOURCE'
		begin
			set @updates =
				case when @fieldName = 'ALLOCATION %' then 'update AORReleaseResource set Allocation = ' + @Value + ', UpdatedBy = ''' + @UpdatedBy + ''', UpdatedDate = ''' + @date + ''' where AORReleaseResourceID = ' + @ItemID + ';'
				else '' end;
		end;
	else
		begin
			set @updates = '';
		end;

	return @updates;
end;




GO


