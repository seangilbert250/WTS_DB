USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Save_User_Filters]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Save_User_Filters]

GO
USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[Save_User_Filters]    Script Date: 6/8/2016 3:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[Save_User_Filters]    Script Date: 6/27/2016 8:14:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[Save_User_Filters]    Script Date: 7/5/2016 9:28:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Save_User_Filters]
	@SessionID nvarchar(100)
	, @UserName nvarchar(255)
	, @FilterTypeID int
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
	, @SRNumber_Search nvarchar(MAX) = ''
	, @SRNumber nvarchar(MAX) = ''
	, @saved bit output
AS
BEGIN
	DECLARE @filterType nvarchar = '';
	SELECT @filterType = FilterType FROM FilterType WHERE FilterTypeID = @FilterTypeID;
	
	DELETE FROM User_Filter
	WHERE
		SessionID = @SessionID
		AND UserName = @UserName
		AND FilterTypeID = @FilterTypeID;

	IF @filterType = 'WorkItem'
		BEGIN
			EXEC WTS.dbo.Save_User_Filters_WorkItem
				@SessionID = @SessionID
				, @UserName = @UserName
				, @FilterTypeID = @FilterTypeID
				, @WTS_SYSTEM = @WTS_SYSTEM
				, @AllocationGroup = @AllocationGroup
				, @DailyMeeting = @DailyMeeting
				, @Allocation = @Allocation
				, @WorkType = @WorkType
				, @WorkItemType = @WorkItemType
				, @WorkloadGroup = @WorkloadGroup
				, @WorkArea = @WorkArea
				, @ProductVersion = @ProductVersion
				, @ProductionStatus = @ProductionStatus
				, @Priority = @Priority
				, @WorkItemSubmittedBy = @WorkItemSubmittedBy
				, @Affiliated = @Affiliated
				, @AssignedResource = @AssignedResource
				, @AssignedOrganization = @AssignedOrganization
				, @PrimaryResource = @PrimaryResource
				, @Workload_Status = @Workload_Status
				, @WorkRequest = @WorkRequest
				, @RequestGroup = @RequestGroup
				, @Contract = @Contract
				, @Organization = @Organization
				, @RequestType = @RequestType
				, @Scope = @Scope
				, @RequestPriority = @RequestPriority
				, @SME = @SME
				, @LEAD_IA_TW = @LEAD_IA_TW
				, @LEAD_RESOURCE = @LEAD_RESOURCE
				, @PDDTDR_PHASE = @PDDTDR_PHASE
				, @SUBMITTEDBY = @SUBMITTEDBY
				, @TaskNumber_Search = @TaskNumber_Search
				, @RequestNumber_Search = @RequestNumber_Search
				, @ItemTitleDescription_Search = @ItemTitleDescription_Search
				, @Request_Search = @Request_Search
				, @RequestGroup_Search = @RequestGroup_Search
				, @SRNumber_Search = @SRNumber_Search
				, @SRNumber = @SRNumber
				, @saved = @saved
			;
		END
	--ELSE IF @filterType = 'WorkRequest'
	--	BEGIN
	--		--todo:
	--	END
	--ELSE IF @filterType = 'RequestGroup'
	--	BEGIN
	--		--todo:
	--	END;
END;



