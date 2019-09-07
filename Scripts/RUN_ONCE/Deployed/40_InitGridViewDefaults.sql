USE WTS
GO
GO

UPDATE GridView
SET 
	DefaultSelection = 1
WHERE
	GridViewID IN (
		SELECT GridViewID FROM GridView WHERE ViewName = 'Default' OR ViewName = 'Workload' OR ViewName = 'My Data'
	);
	
GO

UPDATE GridView
SET 
	DefaultSelection = 0
WHERE
	GridViewID NOT IN (
		SELECT GridViewID FROM GridView WHERE ViewName = 'Default' OR ViewName = 'Workload' OR ViewName = 'My Data'
	);
	
GO

UPDATE GridView
SET
	Tier1Columns = 'AllocationAssignment'
	, Tier1ColumnOrder = 'X|X|true|false||True~Allocation_Sort|Allocation Rank|true|true||True~AllocationID|AllocationID|false|false||False~Allocation|Allocation Assignment|true|true||True~Total_Items|# Tasks|true|false||True~Open_Items|Open|true|false||True~OnHold_Items|On Hold|true|false|On Hold|True~InfoRequested_Items|Info Requested|true|false|On Hold|True~New_Items|New|true|false|Open|True~InProgress_Items|In Progress|true|false|Open|True~ReOpened_Items|Re-Opened|true|false|Open|True~InfoProvided_Items|Info Provided|true|false|Open|True~UnReproducible_Items|Un- Reproducible|true|false|Open|True~CheckedIn_Items|Checked In|true|false|Awaiting Closure|True~Deployed_Items|Deployed|true|false|Awaiting Closure|True~Closed_Items|Closed|true|false|Closed|True~Percent_OnHold_Items|% On Hold|true|true||True~Percent_Open_Items|% Open|true|true||True~Percent_Closed_Items|% Closed|true|true||True~Y|Y|true|false||True'
	, Tier1SortOrder = null
	, Tier1RollupGroup = 'Status'
	, Tier2Columns = 'PrimaryTech. Rank,PrimaryBus. Rank,AssignedTo,PrimaryDeveloper,WorkArea,Functionality,Status,Progress,System,TaskNumber,Description'
	, Tier2ColumnOrder = 'X|X|true~WORKREQUESTID|Request #|false~WORKREQUEST|Request|false~RequestPhaseID|RequestPhaseID|false~RequestPhase|RequestPhase|false~RESOURCEPRIORITYRANK|Primary Tech. Rank|true~PrimaryBusinessRank|Primary Bus. Rank|true~Assigned|Assigned To|true~Primary_Developer|Primary Developer|true~PrimaryBusinessResource|Primary Bus. Resource|false~WORKITEMTYPEID|WORKITEMTYPEID|false~WorkTypeID|WorkTypeID|false~WTS_SYSTEMID|WTS_SYSTEMID|false~WorkArea|Work Area|true~WorkloadGroup|Functionality|true~STATUSID|STATUSID|false~Task_Count|Task Count|false~CREATEDDATE|CREATEDDATE|false~STATUS|Status|true~Progress|Progress|true~Websystem|System|true~ItemID|Task Number|true~TITLE|Title|true~IVTRequired|Requires IVT|false~ALLOCATIONID|ALLOCATIONID|false~WorkAreaID|WorkAreaID|false~Version|Version|false~WORKITEMTYPE|Item Type|false~WorkType|Work Type|false~ProductVersionID|ProductVersionID|false~NEEDDATE|Date Needed|false~DESCRIPTION|DESCRIPTION|false~Production|Production|false~SR_Number|SR Number|false~PRIORITYID|PRIORITYID|false~WorkloadGroupID|WorkloadGroupID|false~PRIORITY|Priority|false~SMEID|SMEID|false~Primary_Analyst|Primary_Analyst|false~PRIMARYRESOURCEID|PRIMARYRESOURCEID|false~ASSIGNEDRESOURCEID|ASSIGNEDRESOURCEID|false~PrimaryBusinessResourceID|PrimaryBusinessResourceID|false~SECONDARYRESOURCEID|SECONDARYRESOURCEID|false~SECONDARYRESOURCE|SECONDARYRESOURCE|false~CREATEDBY|CREATEDBY|false~CREATEDDATE1|CREATEDDATE1|false~SubmittedByID|SubmittedByID|false~SubmittedBy|Submitted By|false~Status_Sort|Status_Sort|false~ARCHIVE|ARCHIVE|false~ReOpenedCount|Times Re-Opened|false~StatusUpdatedDate|Status Updated Date|false~Y|Y|true'
	, Tier2SortOrder = null
	, Tier2RollupGroup = null
	, DefaultSelection = 1
WHERE
	GridNameID = (SELECT GridNameID FROM GridName WHERE GridName = 'Workload Crosswalk')
	AND ViewName = 'Default'
	AND ISNULL(WTS_RESOURCEID,0) = 0
;
