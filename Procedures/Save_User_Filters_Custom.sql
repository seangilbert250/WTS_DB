USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[Save_User_Filters_Custom]    Script Date: 7/10/2018 4:11:06 PM ******/
DROP PROCEDURE [dbo].[Save_User_Filters_Custom]
GO

/****** Object:  StoredProcedure [dbo].[Save_User_Filters_Custom]    Script Date: 7/10/2018 4:11:06 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[Save_User_Filters_Custom]
	@UserName nvarchar(255)
	, @CollectionName nvarchar(255)
	, @Module nvarchar(255)
	, @DeleteFilter bit
	, @WTS_SYSTEM nvarchar(255) = ''
	, @WTS_SYSTEM_SUITE nvarchar(255) = ''
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
	, @WorkItemSubmittedBy nvarchar(255) = ''
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
	, @PrimaryBusResource nvarchar(255) = ''
	, @PrimaryTechResource nvarchar(255) = ''
	, @PrimaryBusRank nvarchar(255) = ''
	, @PrimaryTechRank nvarchar(255) = ''
	, @AssignedToRank nvarchar(255) = ''
	, @AOR nvarchar(255) = null
	, @TaskCreatedBy nvarchar(255) = ''
	, @RQMTType nvarchar(255) = ''
	, @RQMTDescriptionType nvarchar(255) = ''
	, @Complexity nvarchar(255) = ''
	, @RQMTStatus nvarchar(255) = ''
	, @RQMTStage nvarchar(255) = ''
	, @Criticality nvarchar(255) = ''
	, @RQMTAccepted nvarchar(255) = ''
	, @saved bit output
AS
BEGIN
	SET @saved = 0;
	DECLARE @count int = 0;
	DECLARE @date datetime = getdate();

	DELETE FROM User_Filter_Custom
	WHERE
		UserName = @UserName
		AND CollectionName = @CollectionName
		AND Module = @Module;

	IF @DeleteFilter = 0
		BEGIN
			IF isnull(@WTS_SYSTEM,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'System(Task)', WTS_SYSTEMID, WTS_SYSTEM, @UserName, @date, @UserName, @date
				FROM WTS_SYSTEM
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_SYSTEMID) + ',', ',' + @WTS_SYSTEM + ',') > 0
				ORDER BY WTS_SYSTEM;
			END;

			IF isnull(@WTS_SYSTEM_SUITE,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'System Suite', WTS_SYSTEM_SUITEID, WTS_SYSTEM_SUITE, @UserName, @date, @UserName, @date
				FROM WTS_SYSTEM_SUITE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_SYSTEM_SUITEID) + ',', ',' + @WTS_SYSTEM_SUITE + ',') > 0
				ORDER BY WTS_SYSTEM_SUITE;
			END;

			IF isnull(@AllocationGroup,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Allocation Group', ALLOCATIONGROUPID, ALLOCATIONGROUP, @UserName, @date, @UserName, @date
				FROM AllocationGroup
				WHERE CHARINDEX(',' + convert(nvarchar(10), ALLOCATIONGROUPID) + ',', ',' + @AllocationGroup + ',') > 0
				ORDER BY ALLOCATIONGROUP;
			END;

			IF isnull(@DailyMeeting,'') <> ''
			BEGIN
				IF CHARINDEX(',0,', ',' + @DailyMeeting + ',') > 0
				BEGIN
					INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
					VALUES (@UserName, @CollectionName, @Module, 'Daily Meeting', 0, 'No', @UserName, @date, @UserName, @date);
				END;

				IF CHARINDEX(',1,', ',' + @DailyMeeting + ',') > 0
				BEGIN
					INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
					VALUES (@UserName, @CollectionName, @Module, 'Daily Meeting', 1, 'Yes', @UserName, @date, @UserName, @date);
				END;
			END;

			IF isnull(@Allocation,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Allocation Assignment', ALLOCATIONID, ALLOCATION, @UserName, @date, @UserName, @date
				FROM ALLOCATION
				WHERE CHARINDEX(',' + convert(nvarchar(10), ALLOCATIONID) + ',', ',' + @Allocation + ',') > 0
				ORDER BY ALLOCATION;
			END;

			IF isnull(@WorkType,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Resource Group', WorkTypeID, WorkType, @UserName, @date, @UserName, @date
				FROM WorkType
				WHERE CHARINDEX(',' + convert(nvarchar(10), WorkTypeID) + ',', ',' + @WorkType + ',') > 0
				ORDER BY WorkType;
			END;

			IF isnull(@WorkItemType,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Work Activity', WORKITEMTYPEID, WORKITEMTYPE, @UserName, @date, @UserName, @date
				FROM WORKITEMTYPE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WORKITEMTYPEID) + ',', ',' + @WorkItemType + ',') > 0
				ORDER BY WORKITEMTYPE;
			END;

			IF isnull(@WorkloadGroup,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Workload Group', WorkloadGroupID, WorkloadGroup, @UserName, @date, @UserName, @date
				FROM WorkloadGroup
				WHERE CHARINDEX(',' + convert(nvarchar(10), WorkloadGroupID) + ',', ',' + @WorkloadGroup + ',') > 0
				ORDER BY WorkloadGroup;
			END;

			IF isnull(@WorkArea,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Work Area', WorkAreaID, WorkArea, @UserName, @date, @UserName, @date
				FROM WorkArea
				WHERE CHARINDEX(',' + convert(nvarchar(10), WorkAreaID) + ',', ',' + @WorkArea + ',') > 0
				ORDER BY WorkArea;
			END;

			IF isnull(@ProductVersion,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Release Version', ProductVersionID, ProductVersion, @UserName, @date, @UserName, @date
				FROM ProductVersion
				WHERE CHARINDEX(',' + convert(nvarchar(10), ProductVersionID) + ',', ',' + @ProductVersion + ',') > 0
				ORDER BY ProductVersion;
			END;

			IF isnull(@ProductionStatus,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Production Status', STATUSID, [STATUS], @UserName, @date, @UserName, @date
				FROM [STATUS]
				WHERE CHARINDEX(',' + convert(nvarchar(10), STATUSID) + ',', ',' + @ProductionStatus + ',') > 0
				ORDER BY [STATUS];
			END;

			IF isnull(@Priority,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Workload Priority', PRIORITYID, [PRIORITY], @UserName, @date, @UserName, @date
				FROM [PRIORITY]
				WHERE CHARINDEX(',' + convert(nvarchar(10), PRIORITYID) + ',', ',' + @Priority + ',') > 0
				ORDER BY [PRIORITY];
			END;

			IF isnull(@WorkItemSubmittedBy,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Workload Submitted By', WTS_RESOURCEID, USERNAME, @UserName, @date, @UserName, @date
				FROM WTS_RESOURCE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @WorkItemSubmittedBy + ',') > 0
				ORDER BY USERNAME;
			END;

			IF isnull(@Affiliated,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Affiliated', WTS_RESOURCEID, USERNAME, @UserName, @date, @UserName, @date
				FROM WTS_RESOURCE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @Affiliated + ',') > 0
				ORDER BY USERNAME;
			END;

			IF isnull(@AssignedResource,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Workload Assigned To', WTS_RESOURCEID, USERNAME, @UserName, @date, @UserName, @date
				FROM WTS_RESOURCE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @AssignedResource + ',') > 0
				ORDER BY USERNAME;
			END;

			IF isnull(@AssignedOrganization,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Workload Assigned To (Organization)', ORGANIZATIONID, ORGANIZATION, @UserName, @date, @UserName, @date
				FROM ORGANIZATION
				WHERE CHARINDEX(',' + convert(nvarchar(10), ORGANIZATIONID) + ',', ',' + @AssignedOrganization + ',') > 0
				ORDER BY ORGANIZATION;
			END;

			IF isnull(@PrimaryResource,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Developer', WTS_RESOURCEID, USERNAME, @UserName, @date, @UserName, @date
				FROM WTS_RESOURCE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @PrimaryResource + ',') > 0
				ORDER BY USERNAME;
			END;

			IF isnull(@Workload_Status,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Workload Status', STATUSID, [STATUS], @UserName, @date, @UserName, @date
				FROM [STATUS]
				WHERE CHARINDEX(',' + convert(nvarchar(10), STATUSID) + ',', ',' + @Workload_Status + ',') > 0
				ORDER BY [STATUS];
			END;

			IF isnull(@WorkRequest,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'WorkRequest', WORKREQUESTID, TITLE + ' (' + WORKREQUESTID + ')', @UserName, @date, @UserName, @date
				FROM WORKREQUEST
				WHERE CHARINDEX(',' + convert(nvarchar(10), WORKREQUESTID) + ',', ',' + @WorkRequest + ',') > 0
				ORDER BY TITLE + ' (' + WORKREQUESTID + ')';
			END;

			IF isnull(@RequestGroup,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Request Group', RequestGroupID, RequestGroup, @UserName, @date, @UserName, @date
				FROM RequestGroup
				WHERE CHARINDEX(',' + convert(nvarchar(10), RequestGroupID) + ',', ',' + @RequestGroup + ',') > 0
				ORDER BY RequestGroup;
			END;

			IF isnull(@Contract,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Contract', CONTRACTID, [CONTRACT], @UserName, @date, @UserName, @date
				FROM [CONTRACT]
				WHERE CHARINDEX(',' + convert(nvarchar(10), CONTRACTID) + ',', ',' + @Contract + ',') > 0
				ORDER BY [CONTRACT];
			END;

			IF isnull(@Organization,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Organization', ORGANIZATIONID, ORGANIZATION, @UserName, @date, @UserName, @date
				FROM ORGANIZATION
				WHERE CHARINDEX(',' + convert(nvarchar(10), ORGANIZATIONID) + ',', ',' + @Organization + ',') > 0
				ORDER BY ORGANIZATION;
			END;

			IF isnull(@RequestType,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Request Type', REQUESTTYPEID, REQUESTTYPE, @UserName, @date, @UserName, @date
				FROM REQUESTTYPE
				WHERE CHARINDEX(',' + convert(nvarchar(10), REQUESTTYPEID) + ',', ',' + @RequestType + ',') > 0
				ORDER BY REQUESTTYPE;
			END;

			IF isnull(@Scope,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Scope', WTS_SCOPEID, SCOPE, @UserName, @date, @UserName, @date
				FROM WTS_SCOPE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_SCOPEID) + ',', ',' + @Scope + ',') > 0
				ORDER BY SCOPE;
			END;

			IF isnull(@RequestPriority,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Request Priority', PRIORITYID, [PRIORITY], @UserName, @date, @UserName, @date
				FROM [PRIORITY]
				WHERE CHARINDEX(',' + convert(nvarchar(10), PRIORITYID) + ',', ',' + @RequestPriority + ',') > 0
				ORDER BY [PRIORITY];
			END;

			IF isnull(@SME,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'SME', WTS_RESOURCEID, USERNAME, @UserName, @date, @UserName, @date
				FROM WTS_RESOURCE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @SME + ',') > 0
				ORDER BY USERNAME;
			END;

			IF isnull(@LEAD_IA_TW,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Lead Tech Writer', WTS_RESOURCEID, USERNAME, @UserName, @date, @UserName, @date
				FROM WTS_RESOURCE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @LEAD_IA_TW + ',') > 0
				ORDER BY USERNAME;
			END;

			IF isnull(@LEAD_RESOURCE,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Lead Resource', WTS_RESOURCEID, USERNAME, @UserName, @date, @UserName, @date
				FROM WTS_RESOURCE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @LEAD_RESOURCE + ',') > 0
				ORDER BY USERNAME;
			END;

			IF isnull(@PDDTDR_PHASE,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'PDDTDR Phase', PDDTDR_PHASEID, PDDTDR_PHASE, @UserName, @date, @UserName, @date
				FROM PDDTDR_PHASE
				WHERE CHARINDEX(',' + convert(nvarchar(10), PDDTDR_PHASEID) + ',', ',' + @PDDTDR_PHASE + ',') > 0
				ORDER BY PDDTDR_PHASE;
			END;

			IF isnull(@SUBMITTEDBY,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Request Submitted By', WTS_RESOURCEID, USERNAME, @UserName, @date, @UserName, @date
				FROM WTS_RESOURCE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @SUBMITTEDBY + ',') > 0
				ORDER BY USERNAME;
			END;
			
			IF isnull(@TaskNumber_Search,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'TASK NUMBER Contains', 0, Data, @UserName, @date, @UserName, @date
				FROM Split(@TaskNumber_Search, ',')
				ORDER BY Data;
			END;

			IF isnull(@RequestNumber_Search,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'REQUEST NUMBER Contains', 0, Data, @UserName, @date, @UserName, @date
				FROM Split(@RequestNumber_Search, ',')
				ORDER BY Data;
			END;

			IF isnull(@ItemTitleDescription_Search,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'ITEM TITLE/DESCRIPTION Contains', 0, Data, @UserName, @date, @UserName, @date
				FROM Split(@ItemTitleDescription_Search, ',')
				ORDER BY Data;
			END;

			IF isnull(@Request_Search,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'REQUEST Contains', 0, Data, @UserName, @date, @UserName, @date
				FROM Split(@Request_Search, ',')
				ORDER BY Data;
			END;

			IF isnull(@RequestGroup_Search,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'REQUEST GROUP Contains', 0, Data, @UserName, @date, @UserName, @date
				FROM Split(@RequestGroup_Search, ',')
				ORDER BY Data;
			END;

			IF isnull(@SRNumber_Search,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'SR NUMBER Contains', Data as FilterName, Data, @UserName, @date, @UserName, @date
				FROM Split(@SRNumber_Search, ',')
				ORDER BY Data;
			END;

			IF isnull(@SRNumber,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'SR Number', Data as FilterName, Data, @UserName, @date, @UserName, @date
				FROM Split(@SRNumber, ',')
				ORDER BY Data;
			END;

			IF isnull(@PrimaryBusResource,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Primary Bus Resource', WTS_RESOURCEID, USERNAME, @UserName, @date, @UserName, @date
				FROM WTS_RESOURCE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @PrimaryBusResource + ',') > 0
				ORDER BY USERNAME;
			END;

			IF isnull(@PrimaryTechResource,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Primary Resource', WTS_RESOURCEID, USERNAME, @UserName, @date, @UserName, @date
				FROM WTS_RESOURCE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @PrimaryTechResource + ',') > 0
				ORDER BY USERNAME;
			END;

			IF isnull(@PrimaryBusRank,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				VALUES (@UserName, @CollectionName, @Module, 'Bus Rank', @PrimaryBusRank, @PrimaryBusRank, @UserName, @date, @UserName, @date);
			END;

			IF isnull(@PrimaryTechRank,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				VALUES (@UserName, @CollectionName, @Module, 'Tech Rank', @PrimaryTechRank, @PrimaryTechRank, @UserName, @date, @UserName, @date);
			END;

			IF isnull(@PrimaryBusRank,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				VALUES (@UserName, @CollectionName, @Module, 'Customer Rank', @PrimaryBusRank, @PrimaryBusRank, @UserName, @date, @UserName, @date);
			END;

			IF isnull(@AssignedToRank,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Assigned To Rank', PRIORITYID, [PRIORITY], @UserName, @date, @UserName, @date
				FROM [PRIORITY]
				WHERE CHARINDEX(',' + convert(nvarchar(10), PRIORITYID) + ',', ',' + @AssignedToRank + ',') > 0
				ORDER BY [PRIORITY];
			END;

			IF isnull(@TaskCreatedBy,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Task Created By', WTS_RESOURCEID, USERNAME, @UserName, @date, @UserName, @date
				FROM WTS_RESOURCE
				WHERE CHARINDEX(',' + convert(nvarchar(10), WTS_RESOURCEID) + ',', ',' + @TaskCreatedBy + ',') > 0
				ORDER BY USERNAME;
			END;

			IF isnull(@AOR,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'AOR', AORID, AORName, @UserName, @date, @UserName, @date
				FROM AOR
				WHERE CHARINDEX(',' + convert(nvarchar(10), AORID) + ',', ',' + @AOR + ',') > 0
				UNION ALL
				SELECT @UserName, @CollectionName, @Module, 'AOR', 0, 'Unassigned AOR', @UserName, @date, @UserName, @date
				WHERE CHARINDEX(',0,', ',' + @AOR + ',') > 0
				ORDER BY AORName;
			END;

			IF isnull(@RQMTType,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Purpose', RQMTTypeID, RQMTType, @UserName, @date, @UserName, @date
				FROM RQMTType
				WHERE CHARINDEX(',' + convert(nvarchar(10), RQMTTypeID) + ',', ',' + @RQMTType + ',') > 0
				ORDER BY RQMTType;
			END;

			IF isnull(@RQMTDescriptionType,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'RQMT Description Type', RQMTDescriptionTypeID, RQMTDescriptionType, @UserName, @date, @UserName, @date
				FROM RQMTDescriptionType
				WHERE CHARINDEX(',' + convert(nvarchar(10), RQMTDescriptionTypeID) + ',', ',' + @RQMTDescriptionType + ',') > 0
				ORDER BY RQMTDescriptionType;
			END;

			IF isnull(@Complexity,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Complexity', RQMTComplexityID, RQMTComplexity, @UserName, @date, @UserName, @date
				FROM RQMTComplexity
				WHERE CHARINDEX(',' + convert(nvarchar(10), RQMTComplexityID) + ',', ',' + @Complexity + ',') > 0
				ORDER BY RQMTComplexity;
			END;

			IF isnull(@RQMTStatus,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'RQMT Status', RQMTAttributeID, RQMTAttribute, @UserName, @date, @UserName, @date
				FROM RQMTAttribute
				WHERE CHARINDEX(',' + convert(nvarchar(10), RQMTAttributeID) + ',', ',' + @RQMTStatus + ',') > 0
				ORDER BY RQMTAttribute;
			END;

			IF isnull(@RQMTStage,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'RQMT Stage', RQMTAttributeID, RQMTAttribute, @UserName, @date, @UserName, @date
				FROM RQMTAttribute
				WHERE CHARINDEX(',' + convert(nvarchar(10), RQMTAttributeID) + ',', ',' + @RQMTStage + ',') > 0
				ORDER BY RQMTAttribute;
			END;

			IF isnull(@Criticality,'') <> ''
			BEGIN
				INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
				SELECT @UserName, @CollectionName, @Module, 'Criticality', RQMTAttributeID, RQMTAttribute, @UserName, @date, @UserName, @date
				FROM RQMTAttribute
				WHERE CHARINDEX(',' + convert(nvarchar(10), RQMTAttributeID) + ',', ',' + @Criticality + ',') > 0
				ORDER BY RQMTAttribute;
			END;

			IF isnull(@RQMTAccepted,'') <> ''
			BEGIN
				IF CHARINDEX(',0,', ',' + @RQMTAccepted + ',') > 0
				BEGIN
					INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
					VALUES (@UserName, @CollectionName, @Module, 'RQMT Accepted', 0, 'No', @UserName, @date, @UserName, @date);
				END;

				IF CHARINDEX(',1,', ',' + @DailyMeeting + ',') > 0
				BEGIN
					INSERT INTO User_Filter_Custom (UserName, CollectionName, Module, FilterName, FilterID, FilterText, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
					VALUES (@UserName, @CollectionName, @Module, 'RQMT Accepted', 1, 'Yes', @UserName, @date, @UserName, @date);
				END;
			END;

		END;

	SELECT @count = COUNT(*) 
	FROM User_Filter_Custom
	WHERE 
		UserName = @UserName
		AND CollectionName = @CollectionName
		AND Module = @Module;

	IF (ISNULL(@count,0) > 0 AND @DeleteFilter = 0) OR (ISNULL(@count,0) = 0 AND @DeleteFilter = 1)
		SET @saved = 1;
END;






GO


