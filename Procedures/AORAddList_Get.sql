USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORAddList_Get]    Script Date: 7/23/2018 3:34:36 PM ******/
DROP PROCEDURE [dbo].[AORAddList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORAddList_Get]    Script Date: 7/23/2018 3:34:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







create procedure [dbo].[AORAddList_Get]
	@AORID int,
	@AORReleaseID int,
	@SRID int,
	@CRID int,
	@DeliverableID int,
	@Type nvarchar(50),
	@CRStatus nvarchar(255) = '',
	@CRContract nvarchar(255) = '',
	@TaskID nvarchar(255) = '',
	@AORWorkTypeID int = 0,
	@QFSystem nvarchar(255) = '',
	@QFRelease nvarchar(255) = '',
	@QFName nvarchar(255) = '',
	@QFDeployment nvarchar(255) = '',
	@WTS_SYSTEM nvarchar(255) = '',
	@AllocationGroup nvarchar(255) = '',
	@DailyMeeting nvarchar(255) = '',
	@Allocation nvarchar(255) = '',
	@WorkType nvarchar(255) = '',
	@WorkItemType nvarchar(255) = '',
	@WorkloadGroup nvarchar(255) = '',
	@WorkArea nvarchar(255) = '',
	@ProductVersion nvarchar(255) = '',
	@ProductionStatus nvarchar(255) = '',
	@Priority nvarchar(255) = '',
	@WorkItemSubmittedBy nvarchar(255) = '',
	@Affiliated nvarchar(255) = '',
	@AssignedResource nvarchar(255) = '',
	@AssignedOrganization nvarchar(255) = '',
	@PrimaryResource nvarchar(255) = '',
	@Workload_Status nvarchar(255) = '',
	@WorkRequest nvarchar(255) = '',
	@RequestGroup nvarchar(255) = '',
	@Contract nvarchar(255) = '',
	@Organization nvarchar(255) = '',
	@RequestType nvarchar(255) = '',
	@Scope nvarchar(255) = '',
	@RequestPriority nvarchar(255) = '',
	@SME nvarchar(255) = '',
	@LEAD_IA_TW nvarchar(255) = '',
	@LEAD_RESOURCE nvarchar(255) = '',
	@PDDTDR_PHASE nvarchar(255) = '',
	@SUBMITTEDBY nvarchar(255) = '',
	@TaskNumber_Search nvarchar(255) = '',
	@RequestNumber_Search nvarchar(255) = '',
	@ItemTitleDescription_Search nvarchar(255) = '',
	@Request_Search nvarchar(255) = '',
	@RequestGroup_Search nvarchar(255) = '',
	@SRNumber_Search nvarchar(max) = '',
	@SRNumber nvarchar(max) = '',
	@PrimaryBusResource nvarchar(255) = null,
	@PrimaryTechResource nvarchar(255) = null,
	@PrimaryBusRank nvarchar(255) = null,
	@PrimaryTechRank nvarchar(255) = null,
	@AOR nvarchar(255) = null,
	@AssignedToRank nvarchar(255) = null,
	@TaskCreatedBy nvarchar(255) = null, -- NOT USED, BUT NEEDED FOR FILTERING BOX
	@WTS_SYSTEM_SUITE nvarchar(255) = null, -- NOT USED, BUT NEEDED FOR FILTERING BOX
	@GetColumns bit = 0
as
begin
	if @GetColumns = 1
		begin
			select
				0 as Task_ID,
				0 as [Work Task],
				'myTitle' as [Title],
				'myTask' as [System(Task)],
				'myPri' as [Product Version],
				'myStatus' as [Production Status],
				null as [Priority],
				null as [SR Number],
				--ato.USERNAME as [Assigned To],
				--ptr.USERNAME as [Primary Tech. Resource],
				--str.USERNAME as [Secondary Tech. Resource],
				--pbr.USERNAME as [Primary Bus. Resource],
				--sbr.USERNAME as [Secondary Bus. Resource],
				null as [Status],
				null as [Percent Complete]
		end;
	else
		begin
		if @Type = 'Attachment'
			begin
				select AORAttachmentTypeID,
					AORAttachmentTypeName
				from AORAttachmentType
				order by Sort, upper(AORAttachmentTypeName);
			end;
		if @Type = 'Previous Attachment'
			begin
				select null as X,
					AOR.AORID as AOR_ID,
					arl.AORName as [AOR Name],
					arl.AORReleaseID as AORRelease_ID,
					art.AORReleaseAttachmentID as AORReleaseAttachment_ID,
					arl.ProductVersionID as ProductVersion_ID,
					pv.ProductVersion as Release,
					aat.AORAttachmentTypeID as AORAttachmentType_ID,
					aat.AORAttachmentTypeName as [Type],
					art.AORReleaseAttachmentName as [Attachment Name],
					art.[Description],
					art.[FileName] as [File],
					wre.USERNAME,
					art.Approved,
					art.ApprovedByID,
					art.ApprovedDate,
					art.CreatedBy as [Added By],
					art.CreatedDate as [Added Date],
					art.UpdatedBy as [Updated By],
					art.UpdatedDate as [Updated Date]
				from AOR
				join AORRelease arl
				on AOR.AORID = arl.AORID
				join AORReleaseAttachment art
				on arl.AORReleaseID = art.AORReleaseID
				join AORAttachmentType aat
				on art.AORAttachmentTypeID = aat.AORAttachmentTypeID
				left join WTS_RESOURCE wre
				on art.ApprovedByID = wre.WTS_RESOURCEID
				left join ProductVersion pv
				on arl.ProductVersionID = pv.ProductVersionID
				where (@AORID = 0 or AOR.AORID = @AORID)
				and arl.[Current] = 0
				order by pv.ProductVersion desc, upper(aat.AORAttachmentTypeName), upper(art.AORReleaseAttachmentName);
			end;
		else if @Type in ('CR', 'AORWizardCR')
			begin
				-- note: outer select is needed because when performing select distinct, the "order by upper(cr customer title)" clause fails because all order by columns must be in
				-- the original select results when using select distinct; in this case, but adding the column to the result set causes issues with code that is dumping the data table
				-- directly; so we do the query and then select FROM that query and order by after the distinct results have already been processed
				select X, CR_ID, [CR Customer Title], [CR Internal Title], [CR Contract], [Related Release], [CR Coordination] from
				(
					select distinct null as X,
						acr.CRID as CR_ID,
						acr.CRName as [CR Customer Title],
						acr.Title as [CR Internal Title],
						c.[CONTRACT] as [CR Contract],
						acr.RelatedRelease as [Related Release],
						s.[STATUS] as [CR Coordination]
					from AORCR acr
						left join [STATUS] s
						on acr.StatusID = s.STATUSID
						left join AORReleaseCR aorrelcr
						on acr.CRID = aorrelcr.CRID
						left join AORRelease aorrel
						on aorrelcr.AORReleaseID = aorrel.AORReleaseID
						left join AORReleaseSystem aorrelsys
						on aorrel.AORReleaseID = aorrelsys.AORReleaseID
						left join WTS_SYSTEM wsy
						on wsy.WTS_SYSTEMID = aorrelsys.WTS_SYSTEMID
						left join [CONTRACT] c
						on acr.ContractID = c.CONTRACTID
					where not exists (
						select 1
						from AORReleaseCR arc
						join AORRelease arl
						on arc.AORReleaseID = arl.AORReleaseID
						where arc.CRID = acr.CRID
						and arl.AORID = @AORID
						and arl.[Current] = 1
						and @Type = 'CR'
					)
					and ((isnull(@CRStatus, '') = '' and upper(isnull(s.[STATUS], '')) != 'RESOLVED') or charindex(',' + convert(nvarchar(10), isnull(acr.StatusID, 0)) + ',', ',' + @CRStatus + ',') > 0)
					and (isnull(@QFSystem, '') = '' or charindex(',' + convert(nvarchar(10), isnull(wsy.WTS_SYSTEMID, 0)) + ',', ',' + @QFSystem + ',') > 0)
					and (isnull(@QFRelease, '') = '' or charindex(',' + convert(nvarchar(10), isnull(aorrel.ProductVersionID, 0)) + ',', ',' + @QFRelease + ',') > 0)
					and (isnull(@QFName, '') = '' or charindex(@QFName, acr.CRName) > 0 or charindex(@QFName, acr.Title) > 0)
					and (isnull(@CRContract, '') = '' or charindex(',' + convert(nvarchar(10), isnull(acr.ContractID, 0)) + ',', ',' + @CRContract + ',') > 0)
				) tbl
				order by upper([CR Customer Title])
			end;
		else if @Type in ('Task', 'MoveSubTask', 'SR Task', 'AORWizardTask', 'Task List')
			begin
				declare @AORType int = 1;

				if (isnull(@AORWorkTypeID, 0) = 0)
					begin
						select @AORType = awt.AORWorkTypeID
						from AORRelease arl
						left join AORWorkType awt
						on arl.AORWorkTypeID = awt.AORWorkTypeID
						where (isnull(@AORID, 0) = 0 or arl.AORID = @AORID)
						and arl.[Current] = 1;
					end;
				else
					begin
						set @AORType = @AORWorkTypeID;
					end;

				with w_AssignedOrganization as (
					select WTS_RESOURCEID
					from WTS_RESOURCE
					where charindex(',' + convert(nvarchar(10), ORGANIZATIONID) + ',', ',' + @AssignedOrganization + ',') > 0
				),
				w_aor as (
					select arr.WTS_RESOURCEID,
						art.WORKITEMID
					from AORReleaseTask art
					join AORReleaseResource arr
					on art.AORReleaseID = arr.AORReleaseID
					join AORRelease arl
					on art.AORReleaseID = arl.AORReleaseID
					join AOR
					on arl.AORID = AOR.AORID
					where charindex(',' + convert(nvarchar(10), arr.WTS_RESOURCEID) + ',', ',' + @Affiliated + ',') > 0
					and arl.[Current] = 1
					and AOR.Archive = 0
				),
				w_system as (
					select wsy.BusWorkloadManagerID as WTS_RESOURCEID,
						wi.WORKITEMID
					from WTS_SYSTEM wsy
					join WORKITEM wi
					on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
					where charindex(',' + convert(nvarchar(10), wsy.BusWorkloadManagerID) + ',', ',' + @Affiliated + ',') > 0
					union all
					select wsy.DevWorkloadManagerID as WTS_RESOURCEID,
						wi.WORKITEMID
					from WTS_SYSTEM wsy
					join WORKITEM wi
					on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
					where charindex(',' + convert(nvarchar(10), wsy.DevWorkloadManagerID) + ',', ',' + @Affiliated + ',') > 0
					union all
					select wsr.WTS_RESOURCEID,
						wi.WORKITEMID
					from WTS_SYSTEM_RESOURCE wsr
					join WORKITEM wi
					on wsr.WTS_SYSTEMID = wi.WTS_SYSTEMID and wsr.ProductVersionID = wi.ProductVersionID
					where charindex(',' + convert(nvarchar(10), wsr.WTS_RESOURCEID) + ',', ',' + @Affiliated + ',') > 0
				),
				w_aor_current as (
					select art.WORKITEMID,
						AOR.AORID,
						arl.AORName
					from AORReleaseTask art
					join AORRelease arl
					on art.AORReleaseID = arl.AORReleaseID
					join AOR
					on arl.AORID = aor.AORID
					where arl.[Current] = 1
					and aor.Archive = 0
				),
				w_aor_current_sub as (
					select art.WORKITEMTASKID,
						AOR.AORID,
						arl.AORName
					from AORReleaseSubTask art
					join AORRelease arl
					on art.AORReleaseID = arl.AORReleaseID
					join AOR
					on arl.AORID = aor.AORID
					where arl.[Current] = 1
					and aor.Archive = 0
				),
				w_Filtered as (
					select wi.WORKITEMID as FilterID,
						 1 as FilterTypeID
					from WORKITEM wi
					left join WORKREQUEST wr
					on wi.WORKREQUESTID = wr.WORKREQUESTID
					left join ALLOCATION a
					on wi.ALLOCATIONID = a.ALLOCATIONID
					left join AllocationGroup ag
					on a.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
					left join w_aor_current arc
					on wi.WORKITEMID = arc.WORKITEMID
					where (isnull(@TaskID,'') = '' or charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @TaskID + ',') > 0)
					and (isnull(@Affiliated,'') = '' or (
							charindex(',' + convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 or
							charindex(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 or
							exists (
								select 1
								from w_aor aor
								join w_system wsy
								on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID
								where aor.WORKITEMID = wi.WORKITEMID
							)
						)
					)
					and (isnull(@PrimaryResource,'') = '' or charindex(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @PrimaryResource + ',') > 0)
					and (isnull(@AssignedResource,'') = '' or charindex(',' + convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) + ',', ',' + @AssignedResource + ',') > 0)
					and (isnull(@AssignedOrganization,'') = '' or wi.ASSIGNEDRESOURCEID in (select WTS_RESOURCEID from w_AssignedOrganization))
					and (isnull(@PrimaryBusResource,'') = '' or charindex(',' + convert(nvarchar(10), wi.PrimaryBusinessResourceID) + ',', ',' + @PrimaryBusResource + ',') > 0)
					and (isnull(@PrimaryTechResource,'') = '' or charindex(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @PrimaryTechResource + ',') > 0)
					and (isnull(@WTS_SYSTEM,'') = '' or charindex(',' + convert(nvarchar(10), wi.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEM + ',') > 0)
					and (isnull(@AllocationGroup,'') = '' or charindex(',' + convert(nvarchar(10), ag.ALLOCATIONGROUPID) + ',', ',' + @AllocationGroup + ',') > 0)
					and (isnull(@DailyMeeting,'') = '' or charindex(',' + convert(nvarchar(10), ag.DAILYMEETINGS) + ',', ',' + @DailyMeeting + ',') > 0)
					and (isnull(@Allocation,'') = '' or charindex(',' + convert(nvarchar(10), wi.ALLOCATIONID) + ',', ',' + @Allocation + ',') > 0)
					and (isnull(@WorkType,'') = '' or charindex(',' + convert(nvarchar(10), wi.WorkTypeID) + ',', ',' + @WorkType + ',') > 0)
					and (isnull(@WorkItemType,'') = '' or charindex(',' + convert(nvarchar(10), wi.WORKITEMTYPEID) + ',', ',' + @WorkItemType + ',') > 0)
					and (isnull(@WorkloadGroup,'') = '' or charindex(',' + convert(nvarchar(10), wi.WorkloadGroupID) + ',', ',' + @WorkloadGroup + ',') > 0)
					and (isnull(@WorkArea,'') = '' or charindex(',' + convert(nvarchar(10), wi.WorkAreaID) + ',', ',' + @WorkArea + ',') > 0)
					and (isnull(@ProductVersion,'') = '' or charindex(',' + convert(nvarchar(10), wi.ProductVersionID) + ',', ',' + @ProductVersion + ',') > 0)
					and (isnull(@ProductionStatus,'') = '' or charindex(',' + convert(nvarchar(10), wi.ProductionStatusID) + ',', ',' + @ProductionStatus + ',') > 0)
					and (isnull(@Priority,'') = '' or charindex(',' + convert(nvarchar(10), wi.PRIORITYID) + ',', ',' + @Priority + ',') > 0)
					and (isnull(@WorkItemSubmittedBy,'') = '' or charindex(',' + convert(nvarchar(10), wi.SubmittedByID) + ',', ',' + @WorkItemSubmittedBy + ',') > 0)
					and (isnull(@Workload_Status,'') = '' or charindex(',' + convert(nvarchar(10), wi.STATUSID) + ',', ',' + @Workload_Status + ',') > 0)
					and (isnull(@WorkRequest,'') = '' or charindex(',' + convert(nvarchar(10), wi.WORKREQUESTID) + ',', ',' + @WorkRequest + ',') > 0)
					and (isnull(@RequestGroup,'') = '' or charindex(',' + convert(nvarchar(10), wr.RequestGroupID) + ',', ',' + @RequestGroup + ',') > 0)
					and (isnull(@Contract,'') = '' or charindex(',' + convert(nvarchar(10), wr.CONTRACTID) + ',', ',' + @Contract + ',') > 0)
					and (isnull(@Organization,'') = '' or charindex(',' + convert(nvarchar(10), wr.ORGANIZATIONID) + ',', ',' + @Organization + ',') > 0)
					and (isnull(@RequestType,'') = '' or charindex(',' + convert(nvarchar(10), wr.REQUESTTYPEID) + ',', ',' + @RequestType + ',') > 0)
					and (isnull(@Scope,'') = '' or charindex(',' + convert(nvarchar(10), wr.WTS_SCOPEID) + ',', ',' + @Scope + ',') > 0)
					and (isnull(@RequestPriority,'') = '' or charindex(',' + convert(nvarchar(10), wr.OP_PRIORITYID) + ',', ',' + @RequestPriority + ',') > 0)
					and (isnull(@SME,'') = '' or charindex(',' + convert(nvarchar(10), wr.SMEID) + ',', ',' + @SME + ',') > 0)
					and (isnull(@LEAD_IA_TW,'') = '' or charindex(',' + convert(nvarchar(10), wr.LEAD_IA_TWID) + ',', ',' + @LEAD_IA_TW + ',') > 0)
					and (isnull(@LEAD_RESOURCE,'') = '' or charindex(',' + convert(nvarchar(10), wr.LEAD_RESOURCEID) + ',', ',' + @LEAD_RESOURCE + ',') > 0)
					and (isnull(@PDDTDR_PHASE,'') = '' or charindex(',' + convert(nvarchar(10), wi.PDDTDR_PHASEID) + ',', ',' + @PDDTDR_PHASE + ',') > 0)
					and (isnull(@SUBMITTEDBY,'') = '' or charindex(',' + convert(nvarchar(10), wr.SUBMITTEDBY) + ',', ',' + @SUBMITTEDBY + ',') > 0)
					and (isnull(@PrimaryBusRank,'') = '' or charindex(',' + convert(nvarchar(10), wi.PrimaryBusinessRank) + ',', ',' + @PrimaryBusRank + ',') > 0)
					and (isnull(@PrimaryTechRank,'') = '' or charindex(',' + convert(nvarchar(10), wi.RESOURCEPRIORITYRANK) + ',', ',' + @PrimaryTechRank + ',') > 0)
					and (isnull(@SRNumber_Search,'') = '' or charindex(',' + convert(nvarchar(10), wi.SR_Number) + ',', ',' + @SRNumber_Search + ',') > 0)
					and (isnull(@AssignedToRank,'') = '' or charindex(',' + convert(nvarchar(10), wi.AssignedToRankID) + ',', ',' + @AssignedToRank + ',') > 0)
					and (isnull(@AOR,'') = '' or charindex(',' + convert(nvarchar(10), isnull(arc.AORID, 0)) + ',', ',' + @AOR + ',') > 0)
				)
				, w_Filtered_Sub as (
					select wit.WORKITEM_TASKID as FilterID,
						4 as FilterTypeID
					from WORKITEM_TASK wit
					join WORKITEM wi
					on wit.WORKITEMID = wi.WORKITEMID
					left join WORKREQUEST wr
					on wi.WORKREQUESTID = wr.WORKREQUESTID
					left join ALLOCATION a
					on wi.ALLOCATIONID = a.ALLOCATIONID
					left join AllocationGroup ag
					on a.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
					left join w_aor_current_sub arc
					on wit.WORKITEM_TASKID = arc.WORKITEMTASKID
					where (isnull(@TaskID,'') = '' or charindex(',' + convert(nvarchar(10), wit.WORKITEMID) + '-' + convert(nvarchar(10), wit.TASK_NUMBER) + ',', ',' + @TaskID + ',') > 0 or charindex(',' + convert(nvarchar(10), wit.WORKITEMID) + ',', ',' + @TaskID + ',') > 0)
					and (isnull(@WTS_SYSTEM,'') = '' or charindex(',' + convert(nvarchar(10), wi.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEM + ',') > 0)
					and (isnull(@AllocationGroup,'') = '' or charindex(',' + convert(nvarchar(10), ag.ALLOCATIONGROUPID) + ',', ',' + @AllocationGroup + ',') > 0)
					and (isnull(@DailyMeeting,'') = '' or charindex(',' + convert(nvarchar(10), ag.DAILYMEETINGS) + ',', ',' + @DailyMeeting + ',') > 0)
					and (isnull(@Allocation,'') = '' or charindex(',' + convert(nvarchar(10), wi.ALLOCATIONID) + ',', ',' + @Allocation + ',') > 0)
					and (isnull(@WorkType,'') = '' or charindex(',' + convert(nvarchar(10), wi.WorkTypeID) + ',', ',' + @WorkType + ',') > 0)
					and (isnull(@WorkItemType,'') = '' or charindex(',' + convert(nvarchar(10), wi.WORKITEMTYPEID) + ',', ',' + @WorkItemType + ',') > 0)
					and (isnull(@WorkloadGroup,'') = '' or charindex(',' + convert(nvarchar(10), wi.WorkloadGroupID) + ',', ',' + @WorkloadGroup + ',') > 0)
					and (isnull(@WorkArea,'') = '' or charindex(',' + convert(nvarchar(10), wi.WorkAreaID) + ',', ',' + @WorkArea + ',') > 0)
					and (isnull(@ProductVersion,'') = '' or charindex(',' + convert(nvarchar(10), wit.ProductVersionID) + ',', ',' + @ProductVersion + ',') > 0)
					and (isnull(@ProductionStatus,'') = '' or charindex(',' + convert(nvarchar(10), wi.ProductionStatusID) + ',', ',' + @ProductionStatus + ',') > 0)
					and (isnull(@Priority,'') = '' or charindex(',' + convert(nvarchar(10), wi.PRIORITYID) + ',', ',' + @Priority + ',') > 0)
					and (isnull(@WorkItemSubmittedBy,'') = '' or charindex(',' + convert(nvarchar(10), wit.SubmittedByID) + ',', ',' + @WorkItemSubmittedBy + ',') > 0)
					and (isnull(@PrimaryBusRank,'') = '' or charindex(',' + convert(nvarchar(10), wit.BusinessRank) + ',', ',' + @PrimaryBusRank + ',') > 0)
					and (isnull(@PrimaryTechRank,'') = '' or charindex(',' + convert(nvarchar(10), wit.SORT_ORDER) + ',', ',' + @PrimaryTechRank + ',') > 0)
					and (isnull(@PrimaryBusResource,'') = '' or charindex(',' + convert(nvarchar(10), wit.PRIMARYBUSRESOURCEID) + ',', ',' + @PrimaryBusResource + ',') > 0)
					and	(isnull(@PrimaryTechResource,'') = '' or charindex(',' + convert(nvarchar(10), wit.PrimaryResourceID) + ',', ',' + @PrimaryTechResource + ',') > 0)
					and (isnull(@PrimaryResource,'') = '' or charindex(',' + convert(nvarchar(10), wit.PrimaryResourceID) + ',', ',' + @PrimaryResource + ',') > 0)
					and (isnull(@AssignedResource,'') = '' or charindex(',' + convert(nvarchar(10), wit.ASSIGNEDRESOURCEID) + ',', ',' + @AssignedResource + ',') > 0)
					and (isnull(@AssignedOrganization,'') = '' or wit.ASSIGNEDRESOURCEID in (select WTS_RESOURCEID from w_AssignedOrganization))
					and (isnull(@Affiliated,'') = '' or (
						charindex(',' + convert(nvarchar(10), wit.ASSIGNEDRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 or
						charindex(',' + convert(nvarchar(10), wit.PrimaryResourceID) + ',', ',' + @Affiliated + ',') > 0 or
						exists (
							select 1
							from w_aor aor
							join w_system wsy
							on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID
							where aor.WORKITEMID = wit.WORKITEMID
						))
						or (
							charindex(',' + convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 or
							charindex(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 or
							exists (
								select 1
								from w_aor aor
								join w_system wsy
								on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID
								where aor.WORKITEMID = wi.WORKITEMID
							)
						)
					)
					and (isnull(@Workload_Status,'') = '' or charindex(',' + convert(nvarchar(10), wit.STATUSID) + ',', ',' + @Workload_Status + ',') > 0)
					and (isnull(@WorkRequest,'') = '' or charindex(',' + convert(nvarchar(10), wi.WORKREQUESTID) + ',', ',' + @WorkRequest + ',') > 0)
					and (isnull(@RequestGroup,'') = '' or charindex(',' + convert(nvarchar(10), wr.RequestGroupID) + ',', ',' + @RequestGroup + ',') > 0)
					and (isnull(@Contract,'') = '' or charindex(',' + convert(nvarchar(10), wr.CONTRACTID) + ',', ',' + @Contract + ',') > 0)
					and (isnull(@Organization,'') = '' or charindex(',' + convert(nvarchar(10), wr.ORGANIZATIONID) + ',', ',' + @Organization + ',') > 0)
					and (isnull(@RequestType,'') = '' or charindex(',' + convert(nvarchar(10), wr.REQUESTTYPEID) + ',', ',' + @RequestType + ',') > 0)
					and (isnull(@Scope,'') = '' or charindex(',' + convert(nvarchar(10), wr.WTS_SCOPEID) + ',', ',' + @Scope + ',') > 0)
					and (isnull(@RequestPriority,'') = '' or charindex(',' + convert(nvarchar(10), wr.OP_PRIORITYID) + ',', ',' + @RequestPriority + ',') > 0)
					and (isnull(@SME,'') = '' or charindex(',' + convert(nvarchar(10), wr.SMEID) + ',', ',' + @SME + ',') > 0)
					and (isnull(@LEAD_IA_TW,'') = '' or charindex(',' + convert(nvarchar(10), wr.LEAD_IA_TWID) + ',', ',' + @LEAD_IA_TW + ',') > 0)
					and (isnull(@LEAD_RESOURCE,'') = '' or charindex(',' + convert(nvarchar(10), wr.LEAD_RESOURCEID) + ',', ',' + @LEAD_RESOURCE + ',') > 0)
					and (isnull(@PDDTDR_PHASE,'') = '' or charindex(',' + convert(nvarchar(10), wi.PDDTDR_PHASEID) + ',', ',' + @PDDTDR_PHASE + ',') > 0)
					and (isnull(@SUBMITTEDBY,'') = '' or charindex(',' + convert(nvarchar(10), wr.SUBMITTEDBY) + ',', ',' + @SUBMITTEDBY + ',') > 0)
					and (isnull(@SRNumber_Search,'') = '' or charindex(',' + convert(nvarchar(10), wi.SR_Number) + ',', ',' + @SRNumber_Search + ',') > 0)
					and (isnull(@AOR,'') = '' or charindex(',' + convert(nvarchar(10), isnull(arc.AORID, 0)) + ',', ',' + @AOR + ',') > 0)
					and (isnull(@AssignedToRank,'') = '' or charindex(',' + convert(nvarchar(10), wit.AssignedToRankID) + ',', ',' + @AssignedToRank + ',') > 0)
				)
				select *
				from(
				select distinct null as X,
					wi.WORKITEMID as Task_ID,
					convert(nvarchar(10),wi.WORKITEMID) as [Work Task],
					wi.TITLE as [Title],
					ws.WTS_SYSTEM as [System(Task)],
					pv.ProductVersion as [Product Version],
					ps.[STATUS] as [Production Status],
					p.[PRIORITY] as [Priority],
					wi.SR_Number as [SR Number],
					--ato.USERNAME as [Assigned To],
					--ptr.USERNAME as [Primary Tech. Resource],
					--str.USERNAME as [Secondary Tech. Resource],
					--pbr.USERNAME as [Primary Bus. Resource],
					--sbr.USERNAME as [Secondary Bus. Resource],
					s.[STATUS] as [Status],
					wi.COMPLETIONPERCENT as [Percent Complete]
				from WORKITEM wi
				join WTS_SYSTEM ws
				on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				left join ProductVersion pv
				on wi.ProductVersionID = pv.ProductVersionID
				left join [STATUS] ps
				on wi.ProductionStatusID = ps.STATUSID
				join [PRIORITY] p
				on wi.PRIORITYID = p.PRIORITYID
				join WTS_RESOURCE ato
				on wi.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
				left join WTS_RESOURCE ptr
				on wi.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID
				left join WTS_RESOURCE str
				on wi.SECONDARYRESOURCEID = str.WTS_RESOURCEID
				left join WTS_RESOURCE pbr
				on wi.PrimaryBusinessResourceID = pbr.WTS_RESOURCEID
				left join WTS_RESOURCE sbr
				on wi.SecondaryBusinessResourceID = sbr.WTS_RESOURCEID
				join [STATUS] s
				on wi.STATUSID = s.STATUSID
				join w_Filtered wfi
				on wi.WORKITEMID = wfi.FilterID
				and not exists (
					select 1
					from AORReleaseTask art
					join AORRelease arl
					on art.AORReleaseID = arl.AORReleaseID
					where art.WORKITEMID = wi.WORKITEMID
					and arl.AORID = @AORID
					and arl.[Current] = 1
					and (@Type = 'Task' or @Type = 'Task List')
				)
				--Release/Deployment MGMT AOR cannot be associated with Cyber_Servers_Tech Stack, Travel, Production Support tasks
				--and (case when @Type = 'Task' and @AORType = 2 and ps.[STATUS] in ('Cyber, Servers, Tech Stack', 'Travel', 'Production Support') then 0 else 1 end) = 1
				and not exists (
					select 1
					from WORKITEM
					where WORKITEMID = wi.WORKITEMID
					and (SR_Number = @SRID or SR_Number is not null)
					and @Type = 'SR Task'
				)
				Union
				select distinct null as X,
					wit.WORKITEM_TASKID as Task_ID,
					convert(nvarchar(10),wit.WORKITEMID) + ' - ' + convert(nvarchar(10),wit.TASK_NUMBER) as [Work Task],
					wit.TITLE as [Title],
					ws.WTS_SYSTEM as [System(Task)],
					pv.ProductVersion as [Product Version],
					ps.[STATUS] as [Production Status],
					p.[PRIORITY] as [Priority],
					wit.SRNumber as [SR Number],
					s.[STATUS] as [Status],
					wit.COMPLETIONPERCENT as [Percent Complete]
				from WORKITEM_TASK wit
				join WORKITEM wi
				on wit.WORKITEMID = wi.WORKITEMID
				join WTS_SYSTEM ws
				on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				left join ProductVersion pv
				on wit.ProductVersionID = pv.ProductVersionID
				left join [STATUS] ps
				on wi.ProductionStatusID = ps.STATUSID
				join [PRIORITY] p
				on wit.PRIORITYID = p.PRIORITYID
				join WTS_RESOURCE ato
				on wit.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
				left join WTS_RESOURCE ptr
				on wit.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID
				left join WTS_RESOURCE str
				on wit.SECONDARYRESOURCEID = str.WTS_RESOURCEID
				join [STATUS] s
				on wit.STATUSID = s.STATUSID
				join w_Filtered_Sub wfi
				on wit.WORKITEM_TASKID = wfi.FilterID
				and not exists (
					select 1
					from AORReleaseSubTask art
					join AORRelease arl
					on art.AORReleaseID = arl.AORReleaseID
					where art.WORKITEMTASKID = wit.WORKITEM_TASKID
					and arl.AORID = @AORID
					and arl.[Current] = 1
					and (@Type = 'Task' or @Type = 'Task List')
				)
				and not exists (
					select 1
					from AORReleaseTask art
					join AORRelease arl
					on art.AORReleaseID = arl.AORReleaseID
					where art.WORKITEMID = wi.WORKITEMID
					and arl.AORID = @AORID
					and arl.[Current] = 1
					and art.CascadeAOR = 1
					and (@Type = 'Task' or @Type = 'Task List')
				)
				and not exists (
					select 1
					from WORKITEM_TASK
					where WORKITEM_TASKID = wit.WORKITEM_TASKID
					and (SRNumber = @SRID or SRNumber is not null)
					and @Type = 'SR Task'
				)
				where @AORType != 2
				and @Type != 'MoveSubTask'
				) a
				order by a.Task_ID desc;
			end;
		else if @Type = 'MoveWorkTask'
			begin
				Select * from
		(
		select 
			null as X,
			AOR.AORID as AOR_ID,
			rta.AORReleaseTaskID as AORReleaseTask_ID,
			wi.WORKITEMID as Task_ID,
			convert(nvarchar(10),wi.WORKITEMID) as [Work Task],
			wi.TITLE as [Title],
			ws.WTS_SYSTEMID as WTS_SYSTEM_ID,
			ws.WTS_SYSTEM as [System(Task)],
			pv.ProductVersionID as ProductVersion_ID,
			pv.ProductVersion as [Product Version],
			ps.STATUSID as ProductionStatus_ID,
			ps.[STATUS] as [Production Status],
			p.PRIORITYID as PRIORITY_ID,
			p.[PRIORITY] as [Priority],
			wi.SR_Number as [SR Number],
			ato.WTS_RESOURCEID as AssignedTo_ID,
			ato.USERNAME as [Assigned To],
			ptr.WTS_RESOURCEID as PrimaryTechResource_ID,
			ptr.USERNAME as [Primary Resource],
			s.STATUSID as STATUS_ID,
			s.[STATUS] as [Status],
			wi.COMPLETIONPERCENT as [Percent Complete],
			0 as CascadeAOR_ID
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		join AORReleaseTask rta
		on arl.AORReleaseID = rta.AORReleaseID
		join WORKITEM wi
		on rta.WORKITEMID = wi.WORKITEMID
		left join WORKITEM_TASK wit
		on wi.WORKITEMID = wit.WORKITEMID
		join WTS_SYSTEM ws
		on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
		left join ProductVersion pv
		on wi.ProductVersionID = pv.ProductVersionID
		left join [STATUS] ps
		on wi.ProductionStatusID = ps.STATUSID
		join [PRIORITY] p
		on wi.PRIORITYID = p.PRIORITYID
		join WTS_RESOURCE ato
		on wi.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
		left join WTS_RESOURCE ptr
		on wi.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID
		left join WTS_RESOURCE str
		on wi.SECONDARYRESOURCEID = str.WTS_RESOURCEID
		left join WTS_RESOURCE pbr
		on wi.PrimaryBusinessResourceID = pbr.WTS_RESOURCEID
		left join WTS_RESOURCE sbr
		on wi.SecondaryBusinessResourceID = sbr.WTS_RESOURCEID
		join [STATUS] s
		on wi.STATUSID = s.STATUSID
		where (@AORID = 0 or AOR.AORID = @AORID)
		and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
		group by AOR.AORID,
			rta.AORReleaseTaskID,
			wi.WORKITEMID,
			wi.WORKITEMID,
			wi.TITLE,
			ws.WTS_SYSTEMID,
			ws.WTS_SYSTEM,
			pv.ProductVersionID,
			pv.ProductVersion,
			ps.STATUSID,
			ps.[STATUS],
			p.PRIORITYID,
			p.[PRIORITY],
			wi.SR_Number,
			ato.WTS_RESOURCEID,
			ato.USERNAME,
			ptr.WTS_RESOURCEID,
			ptr.USERNAME,
			s.STATUSID,
			s.[STATUS],
			wi.COMPLETIONPERCENT
		Union
		select null as X,
			AOR.AORID as AOR_ID,
			rsta.AORReleaseSubTaskID as AORReleaseTask_ID,
			wit.WORKITEM_TASKID as Task_ID,
			convert(nvarchar(10),wit.WORKITEMID) + ' - ' + convert(nvarchar(10),wit.TASK_NUMBER) as [Work Task],
			wit.TITLE as [Title],
			ws.WTS_SYSTEMID as WTS_SYSTEM_ID,
			ws.WTS_SYSTEM as [System(Task)],
			pv.ProductVersionID as ProductVersion_ID,
			pv.ProductVersion as [Product Version],
			ps.STATUSID as ProductionStatus_ID,
			ps.[STATUS] as [Production Status],
			p.PRIORITYID as PRIORITY_ID,
			p.[PRIORITY] as [Priority],
			wit.SRNumber as [SR Number],
			ato.WTS_RESOURCEID as AssignedTo_ID,
			ato.USERNAME as [Assigned To],
			ptr.WTS_RESOURCEID as PrimaryTechResource_ID,
			ptr.USERNAME as [Primary Resource],
			s.STATUSID as STATUS_ID,
			s.[STATUS] as [Status],
			wit.COMPLETIONPERCENT as [Percent Complete],
			rta.CascadeAOR as CascadeAOR_ID
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		join AORReleaseSubTask rsta
		on arl.AORReleaseID = rsta.AORReleaseID
		join WORKITEM_TASK wit
		on rsta.WORKITEMTASKID = wit.WORKITEM_TASKID
		join WORKITEM wi
		on wit.WORKITEMID = wi.WORKITEMID
		left join AORReleaseTask rta
		on arl.AORReleaseID = rta.AORReleaseID
		and wi.WORKITEMID = rta.WORKITEMID
		join WTS_SYSTEM ws
		on wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
		left join ProductVersion pv
		on wit.ProductVersionID = pv.ProductVersionID
		left join [STATUS] ps
		on wi.ProductionStatusID = ps.STATUSID
		join [PRIORITY] p
		on wit.PRIORITYID = p.PRIORITYID
		join WTS_RESOURCE ato
		on wit.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
		left join WTS_RESOURCE ptr
		on wit.PRIMARYRESOURCEID = ptr.WTS_RESOURCEID
		left join WTS_RESOURCE str
		on wit.SECONDARYRESOURCEID = str.WTS_RESOURCEID
		join [STATUS] s
		on wit.STATUSID = s.STATUSID
		where (@AORID = 0 or AOR.AORID = @AORID)
		and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
		group by AOR.AORID,
			rsta.AORReleaseSubTaskID,
			wit.WORKITEM_TASKID,
			convert(nvarchar(10),wit.WORKITEMID) + ' - ' + convert(nvarchar(10),wit.TASK_NUMBER),
			wit.TITLE,
			ws.WTS_SYSTEMID,
			ws.WTS_SYSTEM,
			pv.ProductVersionID,
			pv.ProductVersion,
			ps.STATUSID,
			ps.[STATUS],
			p.PRIORITYID,
			p.[PRIORITY],
			wit.SRNumber,
			ato.WTS_RESOURCEID,
			ato.USERNAME,
			ptr.WTS_RESOURCEID,
			ptr.USERNAME,
			s.STATUSID,
			s.[STATUS],
			wit.COMPLETIONPERCENT,
			rta.CascadeAOR
			) a 
		order by a.[Work Task] desc;
			end;
		else if @Type = 'CR AOR'
			begin
				select null as X,
					AOR.AORID as [AOR #],
					arl.AORName as [AOR Name],
					arl.AORReleaseID as AORRelease_ID,
					pv.ProductVersionID as ProductVersion_ID,
					pv.ProductVersion as [Release],
					wsy.WTS_SYSTEMID as WTS_SYSTEM_ID,
					wsy.WTS_SYSTEM as [System]
				from AOR
				join AORRelease arl
				on AOR.AORID = arl.AORID
				left join ProductVersion pv
				on arl.ProductVersionID = pv.ProductVersionID
				left join AORReleaseSystem ars
				on arl.AORReleaseID = ars.AORReleaseID
				left join WTS_SYSTEM wsy
				on ars.WTS_SYSTEMID = wsy.WTS_SYSTEMID
				where AOR.Archive = 0
				and arl.[Current] = 1
				and not exists (
					select 1
					from AORReleaseCR arc
					where arc.AORReleaseID = arl.AORReleaseID
					and arc.CRID = @CRID
				)
				and (isnull(@QFSystem, '') = '' or charindex(',' + convert(nvarchar(10), isnull(wsy.WTS_SYSTEMID, 0)) + ',', ',' + @QFSystem + ',') > 0)
				and (isnull(@QFRelease, '') = '' or charindex(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @QFRelease + ',') > 0)
				and (isnull(@QFName, '') = '' or charindex(@QFName, arl.AORName) > 0)
				order by upper(wsy.WTS_SYSTEM), upper(pv.ProductVersion), upper(arl.AORName);
			end;
		else if @Type = 'Release Schedule AOR'
			begin
				select null as X,
					AOR.AORID as [AOR #],
					arl.AORName as [AOR Name],
					arl.AORReleaseID as AORRelease_ID,
					pv.ProductVersionID as ProductVersion_ID,
					pv.ProductVersion as [Release],
					wsy.WTS_SYSTEMID as WTS_SYSTEM_ID,
					wsy.WTS_SYSTEM as [System]
				from AOR
				join AORRelease arl
				on AOR.AORID = arl.AORID
				left join ProductVersion pv
				on arl.ProductVersionID = pv.ProductVersionID
				left join AORReleaseSystem ars
				on arl.AORReleaseID = ars.AORReleaseID
				left join WTS_SYSTEM wsy
				on ars.WTS_SYSTEMID = wsy.WTS_SYSTEMID
				where AOR.Archive = 0
				and arl.[Current] = 1
				and not exists (
					select 1
					from AORReleaseDeliverable ars
					where ars.AORReleaseID = arl.AORReleaseID
					and ars.DeliverableID = @DeliverableID
				)
				and (isnull(@QFSystem, '') = '' or charindex(',' + convert(nvarchar(10), isnull(wsy.WTS_SYSTEMID, 0)) + ',', ',' + @QFSystem + ',') > 0)
				and (isnull(@QFRelease, '') = '' or charindex(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @QFRelease + ',') > 0)
				and (isnull(@QFName, '') = '' or charindex(@QFName, arl.AORName) > 0)
				order by upper(wsy.WTS_SYSTEM), upper(pv.ProductVersion), upper(arl.AORName);
			end;
		else if @Type = 'Add/Move Deployment AOR'
			begin
				select null as X,
					AOR.AORID as [AOR #],
					arl.AORName as [AOR Name],
					arl.AORReleaseID as AORRelease_ID,
					pv.ProductVersionID as ProductVersion_ID,
					pv.ProductVersion as [Release],
					wsy.WTS_SYSTEMID as WTS_SYSTEM_ID,
					wsy.WTS_SYSTEM as [System],
					ard.DeliverableID as Deployment_ID,
					rs.ReleaseScheduleDeliverable as Deployment,
					ard.[Weight] as [Weight],
					null as Y
				from AOR
				join AORRelease arl
				on AOR.AORID = arl.AORID
				left join AORReleaseDeliverable ard
				on ard.AORReleaseID = arl.AORReleaseID
				left join ReleaseSchedule rs
				on ard.DeliverableID = rs.ReleaseScheduleID
				left join ProductVersion pv
				on arl.ProductVersionID = pv.ProductVersionID
				left join AORReleaseSystem ars
				on arl.AORReleaseID = ars.AORReleaseID
				left join WTS_SYSTEM wsy
				on ars.WTS_SYSTEMID = wsy.WTS_SYSTEMID
				where AOR.Archive = 0
				and arl.[Current] = 1
				and (isnull(@QFSystem, '') = '' or charindex(',' + convert(nvarchar(10), isnull(wsy.WTS_SYSTEMID, 0)) + ',', ',' + @QFSystem + ',') > 0)
				and (isnull(@QFRelease, '') = '' or charindex(',' + convert(nvarchar(10), isnull(arl.ProductVersionID, 0)) + ',', ',' + @QFRelease + ',') > 0)
				and (isnull(@QFName, '') = '' or charindex(@QFName, arl.AORName) > 0)
				and (isnull(@QFDeployment, '') = '' or charindex(',' + convert(nvarchar(10), isnull(rs.ReleaseScheduleID, 0)) + ',', ',' + @QFDeployment + ',') > 0)
				order by upper(wsy.WTS_SYSTEM), upper(pv.ProductVersion), upper(arl.AORName);
			end;
		else if @Type = 'Action Team'
			begin
				select null as X,
					wre.WTS_RESOURCEID as WTS_RESOURCE_ID,
					wre.USERNAME as [Resource]
				from WTS_RESOURCE wre
				left join WTS_RESOURCE_TYPE wrt
				on wre.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
				where wre.ARCHIVE = 0
				and wre.AORResourceTeam = 0
				and isnull(wrt.WTS_RESOURCE_TYPE, '') != 'Not People'
				and not exists (
					select 1
					from AORReleaseResourceTeam rrt
					join AORRelease arl
					on rrt.AORReleaseID = arl.AORReleaseID
					join AOR
					on AOR.AORID = arl.AORID
					where AOR.AORID = @AORID
					and arl.[Current] = 1
					and rrt.ResourceID = wre.WTS_RESOURCEID
				)
				order by upper(wre.USERNAME);
			end;
		else if @Type = 'Deployment'
			begin
				select null as X,
					rs.ReleaseScheduleID as Deployment_ID,
					rs.ReleaseScheduleDeliverable as Deployment,
					rs.Description,
					format(rs.PlannedDevTestStart, 'd') as [Planned Start],
					format(rs.PlannedEnd, 'd') as [Planned End]
				from ReleaseSchedule rs	
				where (isnull(@QFRelease, '') = '' or charindex(',' + convert(nvarchar(10), isnull(rs.ProductVersionID, 0)) + ',', ',' + @QFRelease + ',') > 0)
				and not exists (
					select 1
					from ReleaseAssessment_Deployment rad
					where rad.ReleaseScheduleID = rs.ReleaseScheduleID
				)
			end;
	end;
end;

GO


