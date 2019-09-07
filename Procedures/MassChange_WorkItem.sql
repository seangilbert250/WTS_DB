USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[MassChange_WorkItem]    Script Date: 10/17/2017 9:06:30 AM ******/
DROP PROCEDURE [dbo].[MassChange_WorkItem]
GO

/****** Object:  StoredProcedure [dbo].[MassChange_WorkItem]    Script Date: 10/17/2017 9:06:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[MassChange_WorkItem]
	@FieldName nvarchar(50)
	, @FromValue nvarchar(50) = ''
	, @ToValue nvarchar(50)
	, @UpdatedBy nvarchar(255) = 'WTS_ADMIN'
	, @IncludeArchived bit = 0
	--Filters
	, @WTS_SYSTEM nvarchar(255) = ''
	, @AllocationGroup nvarchar(255) = ''
	, @DailyMeeting nvarchar(255) = ''
	, @Allocation nvarchar(255) = ''
	, @WorkType nvarchar(255) = ''
	, @WorkItemType nvarchar(255) = ''
	, @WorkloadGroup nvarchar(255) = ''
	, @WorkArea nvarchar(255) = ''
	, @ProductVersion nvarchar(255) = ''
	, @ProductionStatus nvarchar(255) = ''
	, @Priority nvarchar(255) = ''
	, @WorkItemSubmittedBy nvarchar(255) = null
	, @Affiliated nvarchar(255) = ''
	, @AssignedResource nvarchar(255) = ''
	, @AssignedOrganization nvarchar(255) = ''
	, @PrimaryResource nvarchar(255) = ''
	, @Workload_Status nvarchar(255) = ''
	, @WorkRequest nvarchar(255) = ''
	, @RequestGroup nvarchar(255) = ''
	, @Contract nvarchar(255) = ''
	, @Organization nvarchar(255) = ''
	, @RequestType nvarchar(255) = ''
	, @Scope nvarchar(255) = ''
	, @RequestPriority nvarchar(255) = ''
	, @SME nvarchar(255) = ''
	, @LEAD_IA_TW nvarchar(255) = ''
	, @LEAD_RESOURCE nvarchar(255) = ''
	, @PDDTDR_PHASE nvarchar(255) = ''
	, @SUBMITTEDBY nvarchar(255) = ''
	, @TaskNumber_Search nvarchar(255) = ''
	, @RequestNumber_Search nvarchar(255) = ''
	, @ItemTitleDescription_Search nvarchar(255) = ''
	, @Request_Search nvarchar(255) = ''
	, @RequestGroup_Search nvarchar(255) = ''
	, @SRNumber_Search nvarchar(255) = ''
	, @SRNumber nvarchar(255) = ''
	, @PrimaryBusResource nvarchar(255) = null
	, @PrimaryTechResource nvarchar(255) = null
	, @PrimaryBusRank nvarchar(255) = null
	, @PrimaryTechRank nvarchar(255) = null
	, @AOR nvarchar(255) = null
	, @AssignedToRank nvarchar(255) = null
	, @OwnedBy int = null
	--Rows affected
	, @RowsUpdated int output
AS
BEGIN
	
	DECLARE @date datetime = GETDATE();

	CREATE TABLE #WorkItem_Filtered(
		WORKITEMID int
	);

	select distinct TeamResourceID, ResourceID
	into #AssignedResourceTeamUser
	from AORReleaseResourceTeam rrt
	join AORRelease arl
	on rrt.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and charindex(',' + convert(nvarchar(10), rrt.ResourceID) + ',', ',' + @AssignedResource + ',') > 0;

	create nonclustered index idx_AssignedResourceTeamUser ON #AssignedResourceTeamUser (TeamResourceID, ResourceID);
	create nonclustered index idx_AssignedResourceTeamUser2 ON #AssignedResourceTeamUser (ResourceID, TeamResourceID);

	select distinct TeamResourceID, ResourceID
	into #AffiliatedResourceTeamUser
	from AORReleaseResourceTeam rrt
	join AORRelease arl
	on rrt.AORReleaseID = arl.AORReleaseID
	where arl.[Current] = 1
	and charindex(',' + convert(nvarchar(10), rrt.ResourceID) + ',', ',' + @Affiliated + ',') > 0;

	create nonclustered index idx_AffiliatedResourceTeamUser ON #AffiliatedResourceTeamUser (TeamResourceID, ResourceID);
	create nonclustered index idx_AffiliatedResourceTeamUser2 ON #AffiliatedResourceTeamUser (ResourceID, TeamResourceID);

	WITH
	w_AssignedOrganization
	AS
	(
		SELECT WTS_RESOURCEID
		FROM WTS_RESOURCE
		WHERE CHARINDEX(',' + convert(nvarchar(10), ORGANIZATIONID) + ',', ',' + @AssignedOrganization + ',') > 0
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
		where charindex(',' + convert(nvarchar(10), arr.WTS_RESOURCEID) + ',', ',' + @Affiliated + ',' + convert(nvarchar(10), @OwnedBy) + ',') > 0
		and arl.[Current] = 1
		and AOR.Archive = 0
	),
	w_system as (
		select wsy.BusWorkloadManagerID as WTS_RESOURCEID,
			wi.WORKITEMID
		from WTS_SYSTEM wsy
		join WORKITEM wi
		on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
		where charindex(',' + convert(nvarchar(10), wsy.BusWorkloadManagerID) + ',', ',' + @Affiliated + ',' + convert(nvarchar(10), @OwnedBy) + ',') > 0
		union all
		select wsy.DevWorkloadManagerID as WTS_RESOURCEID,
			wi.WORKITEMID
		from WTS_SYSTEM wsy
		join WORKITEM wi
		on wsy.WTS_SYSTEMID = wi.WTS_SYSTEMID
		where charindex(',' + convert(nvarchar(10), wsy.DevWorkloadManagerID) + ',', ',' + @Affiliated + ',' + convert(nvarchar(10), @OwnedBy) + ',') > 0
		union all
		select wsr.WTS_RESOURCEID,
			wi.WORKITEMID
		from WTS_SYSTEM_RESOURCE wsr
		join WORKITEM wi
		on wsr.WTS_SYSTEMID = wi.WTS_SYSTEMID and wsr.ProductVersionID = wi.ProductVersionID
		where charindex(',' + convert(nvarchar(10), wsr.WTS_RESOURCEID) + ',', ',' + @Affiliated + ',' + convert(nvarchar(10), @OwnedBy) + ',') > 0
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
	)
	INSERT INTO #WorkItem_Filtered(WORKITEMID)
	SELECT DISTINCT
		wi.WORKITEMID
	FROM
		WORKITEM wi
			LEFT JOIN WORKREQUEST wr ON wi.WORKREQUESTID = wr.WORKREQUESTID
			LEFT JOIN RequestGroup rg ON wr.RequestGroupID = rg.RequestGroupID
			LEFT JOIN ALLOCATION a ON wi.ALLOCATIONID = a.ALLOCATIONID
			LEFT JOIN AllocationGroup ag ON a.ALLOCATIONGROUPID = ag.ALLOCATIONGROUPID
			LEFT JOIN w_aor_current arc on wi.WORKITEMID = arc.WORKITEMID
		join WTS_RESOURCE wre
		on wi.ASSIGNEDRESOURCEID = wre.WTS_RESOURCEID
	WHERE
		(isnull(@WTS_SYSTEM,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEM + ',') > 0)
		AND (isnull(@AllocationGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ag.ALLOCATIONGROUPID) + ',', ',' + @AllocationGroup + ',') > 0)
		AND (isnull(@DailyMeeting,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), ag.DAILYMEETINGS) + ',', ',' + @DailyMeeting + ',') > 0)
		AND (isnull(@Allocation,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ALLOCATIONID) + ',', ',' + @Allocation + ',') > 0)
		AND (isnull(@WorkType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WorkTypeID) + ',', ',' + @WorkType + ',') > 0)
		AND (isnull(@WorkItemType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WORKITEMTYPEID) + ',', ',' + @WorkItemType + ',') > 0)
		AND (isnull(@WorkloadGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WorkloadGroupID) + ',', ',' + @WorkloadGroup + ',') > 0)
		AND (isnull(@WorkArea,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WorkAreaID) + ',', ',' + @WorkArea + ',') > 0)
		AND (isnull(@ProductVersion,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ProductVersionID) + ',', ',' + @ProductVersion + ',') > 0)
		AND (isnull(@ProductionStatus,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.ProductionStatusID) + ',', ',' + @ProductionStatus + ',') > 0)
		AND (isnull(@Priority,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PRIORITYID) + ',', ',' + @Priority + ',') > 0)
		AND (isnull(@PrimaryResource,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @PrimaryResource + ',') > 0)
		AND (isnull(@Affiliated,'') = '' OR (
			CHARINDEX(',' + convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 OR
			CHARINDEX(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @Affiliated + ',') > 0 OR
			exists (
				select 1
				from w_aor aor
				join w_system wsy
				on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID
				where aor.WORKITEMID = wi.WORKITEMID
				and charindex(',' + convert(nvarchar(10), aor.WTS_RESOURCEID) + ',', ',' + @Affiliated + ',') > 0
			))
			or exists (
				select 1
				from #AffiliatedResourceTeamUser artu
				join WorkType_WTS_RESOURCE rgr
				on artu.ResourceID = rgr.WTS_RESOURCEID
				where artu.TeamResourceID = wi.ASSIGNEDRESOURCEID
				and rgr.WorkTypeID = wi.WorkTypeID
			)
		)
		AND (isnull(@AssignedResource,'') = '' OR (
			CHARINDEX(',' + convert(nvarchar(10), wi.ASSIGNEDRESOURCEID) + ',', ',' + @AssignedResource + ',') > 0
			or exists (
				select 1
				from #AssignedResourceTeamUser artu
				join WorkType_WTS_RESOURCE rgr
				on artu.ResourceID = rgr.WTS_RESOURCEID
				where artu.TeamResourceID = wi.ASSIGNEDRESOURCEID
				and rgr.WorkTypeID = wi.WorkTypeID
			)
		))
		AND (isnull(@AssignedOrganization,'') = '' OR wi.ASSIGNEDRESOURCEID IN (SELECT WTS_RESOURCEID FROM w_AssignedOrganization))
		AND (isnull(@Workload_Status,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.STATUSID) + ',', ',' + @Workload_Status + ',') > 0)
		AND (isnull(@WorkRequest,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WORKREQUESTID) + ',', ',' + @WorkRequest + ',') > 0)
		AND (isnull(@RequestGroup,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.RequestGroupID) + ',', ',' + @RequestGroup + ',') > 0)
		AND (isnull(@Contract,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.CONTRACTID) + ',', ',' + @Contract + ',') > 0)
		AND (isnull(@Organization,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.ORGANIZATIONID) + ',', ',' + @Organization + ',') > 0)
		AND (isnull(@RequestType,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.REQUESTTYPEID) + ',', ',' + @RequestType + ',') > 0)
		AND (isnull(@Scope,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.WTS_SCOPEID) + ',', ',' + @Scope + ',') > 0)
		AND (isnull(@RequestPriority,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.OP_PRIORITYID) + ',', ',' + @RequestPriority + ',') > 0)
		AND (isnull(@SME,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.SMEID) + ',', ',' + @SME + ',') > 0)
		AND (isnull(@LEAD_IA_TW,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.LEAD_IA_TWID) + ',', ',' + @LEAD_IA_TW + ',') > 0)
		AND (isnull(@LEAD_RESOURCE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.LEAD_RESOURCEID) + ',', ',' + @LEAD_RESOURCE + ',') > 0)
		AND (isnull(@PDDTDR_PHASE,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.PDDTDR_PHASEID) + ',', ',' + @PDDTDR_PHASE + ',') > 0)
		AND (isnull(@SUBMITTEDBY,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wr.SUBMITTEDBY) + ',', ',' + @SUBMITTEDBY + ',') > 0)
		AND (isnull(@TaskNumber_Search,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @TaskNumber_Search + ',') > 0)
		AND (isnull(@RequestNumber_Search,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.WORKREQUESTID) + ',', ',' + @RequestNumber_Search + ',') > 0)
		AND (isnull(@ItemTitleDescription_Search,'') = '' OR (CHARINDEX(UPPER(@ItemTitleDescription_Search), UPPER(wi.TITLE)) > 0 OR CHARINDEX(UPPER(@ItemTitleDescription_Search), UPPER(wi.DESCRIPTION)) > 0))
		AND (isnull(@Request_Search,'') = '' OR (CHARINDEX(UPPER(@Request_Search), UPPER(wr.TITLE)) > 0 OR CHARINDEX(UPPER(@Request_Search), UPPER(wr.DESCRIPTION)) > 0))
		AND (isnull(@RequestGroup_Search,'') = '' OR CHARINDEX(UPPER(@RequestGroup_Search), UPPER(rg.RequestGroup)) > 0)
		AND (isnull(@SRNumber_Search,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.SR_Number) + ',', ',' + @SRNumber_Search + ',') > 0)
		AND (isnull(@SRNumber,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), wi.SR_Number) + ',', ',' + @SRNumber + ',') > 0)
		and (isnull(@PrimaryBusResource,'') = '' or charindex(',' + convert(nvarchar(10), wi.PrimaryBusinessResourceID) + ',', ',' + @PrimaryBusResource + ',') > 0)
		and (isnull(@PrimaryTechResource,'') = '' or charindex(',' + convert(nvarchar(10), wi.PRIMARYRESOURCEID) + ',', ',' + @PrimaryTechResource + ',') > 0)
		and (isnull(@PrimaryBusRank,'') = '' or charindex(',' + convert(nvarchar(10), wi.PrimaryBusinessRank) + ',', ',' + @PrimaryBusRank + ',') > 0)
		and (isnull(@PrimaryTechRank,'') = '' or charindex(',' + convert(nvarchar(10), wi.RESOURCEPRIORITYRANK) + ',', ',' + @PrimaryTechRank + ',') > 0)
		and (isnull(@AssignedToRank,'') = '' or charindex(',' + convert(nvarchar(10), wi.AssignedToRankID) + ',', ',' + @AssignedToRank + ',') > 0)
		AND (ISNULL(@OwnedBy,0) = 0 OR 
				(wi.ASSIGNEDRESOURCEID = @OwnedBy
				OR wi.PRIMARYRESOURCEID =  @OwnedBy
				OR exists (
					select 1
					from w_aor aor
					join w_system wsy
					on aor.WTS_RESOURCEID = wsy.WTS_RESOURCEID and aor.WORKITEMID = wsy.WORKITEMID
					where aor.WORKITEMID = wi.WORKITEMID
					and aor.WTS_RESOURCEID = @OwnedBy
				)
				or (wre.AORResourceTeam = 1 and exists (
					select 1
					from AORReleaseResourceTeam rrt
					join AORRelease arl
					on rrt.AORReleaseID = arl.AORReleaseID
					join WorkType_WTS_RESOURCE rgr
					on rrt.ResourceID = rgr.WTS_RESOURCEID
					where arl.[Current] = 1
					and rrt.TeamResourceID = wre.WTS_RESOURCEID
					and rgr.WorkTypeID = wi.WorkTypeID
					and rrt.ResourceID = @OwnedBy
				))
				)
			)
		AND (isnull(@AOR,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), isnull(arc.AORID, 0)) + ',', ',' + @AOR + ',') > 0)
		AND CASE WHEN @IncludeArchived = 1 THEN 0 ELSE wi.Archive END = 0
	;
	
	IF @FieldName = 'WORKREQUEST'
	BEGIN
		UPDATE WORKITEM
		SET
			WORKREQUESTID = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				ISNULL(wi.WORKREQUESTID,0) = ISNULL(CONVERT(int, @FromValue),0)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'WORKITEMTYPE'
	BEGIN
		UPDATE WORKITEM
		SET
			WORKITEMTYPEID = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				wi.WORKITEMTYPEID = CONVERT(int, @FromValue)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'WorkType'
	BEGIN
		UPDATE WORKITEM
		SET
			WorkTypeID = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				wi.WorkTypeID = CONVERT(int, @FromValue)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'Websystem'
	BEGIN
		UPDATE WORKITEM
		SET
			WTS_SYSTEMID = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				wi.WTS_SYSTEMID = CONVERT(int, @FromValue)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'ALLOCATION'
	BEGIN
		UPDATE WORKITEM
		SET
			ALLOCATIONID = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				ISNULL(wi.ALLOCATIONID,0) = ISNULL(CONVERT(int, @FromValue),0)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'Production'
	BEGIN
		UPDATE WORKITEM
		SET
			Production = CONVERT(bit, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				wi.Production = CONVERT(bit, @FromValue)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'Version'
	BEGIN
		UPDATE WORKITEM
		SET
			ProductVersionID = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				wi.ProductVersionID = CONVERT(int, @FromValue)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'PRIORITY'
	BEGIN
		UPDATE WORKITEM
		SET
			PRIORITYID = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				wi.PRIORITYID = CONVERT(int, @FromValue)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'STATUS'
	BEGIN
		UPDATE WORKITEM
		SET
			STATUSID = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				wi.STATUSID = CONVERT(int, @FromValue)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'Assigned'
	BEGIN
		UPDATE WORKITEM
		SET
			ASSIGNEDRESOURCEID = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				wi.ASSIGNEDRESOURCEID = CONVERT(int, @FromValue)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'Primary_Developer'
	BEGIN
		UPDATE WORKITEM
		SET
			PRIMARYRESOURCEID = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				wi.PRIMARYRESOURCEID = CONVERT(int, @FromValue)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'Secondary_Developer'
	BEGIN
		UPDATE WORKITEM
		SET
			SECONDARYRESOURCEID = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				wi.SECONDARYRESOURCEID = CONVERT(int, @FromValue)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END
	ELSE IF @FieldName = 'PROGRESS'
	BEGIN
		UPDATE WORKITEM
		SET
			COMPLETIONPERCENT = CONVERT(int, @ToValue)
			, UPDATEDBY = @UpdatedBy
			, UPDATEDDATE = @date
		WHERE WORKITEMID IN (
			SELECT wi.WORKITEMID
			FROM 
				WORKITEM wi
					JOIN #WorkItem_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
			WHERE
				wi.COMPLETIONPERCENT = CONVERT(int, @FromValue)
		);

		SET @RowsUpdated = @@ROWCOUNT;
	END

	drop table #AssignedResourceTeamUser;
	drop table #AffiliatedResourceTeamUser;
END;


GO

