use [WTS]
go

alter table WORKITEMTYPE
alter column WORKITEMTYPE nvarchar(255);
go

alter table WORKITEMTYPE
alter column [Description] nvarchar(max);
go

alter table WORKITEMTYPE
alter column [PDDTDR_PHASEID] int null;

begin
	declare @date datetime;
	declare @ProgramMGMTID int;
	declare @DeploymentID int;
	declare @ProductionID int;

	set @date = getdate();

	insert into WorkloadAllocation (WorkloadAllocation, [Description], Sort, Archive, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate, Abbreviation)
	select 'Program MGMT', '', 1, 0, 'WTS', @date, 'WTS', @date, 'R'
	union all
	select 'Deployment', '', 2, 0, 'WTS', @date, 'WTS', @date, 'D'
	union all
	select 'Production', '', 3, 0, 'WTS', @date, 'WTS', @date, 'P'
	;

	select @ProgramMGMTID = WorkloadAllocationID
	from WorkloadAllocation
	where WorkloadAllocation = 'Program MGMT';

	select @DeploymentID = WorkloadAllocationID
	from WorkloadAllocation
	where WorkloadAllocation = 'Deployment';

	select @ProductionID = WorkloadAllocationID
	from WorkloadAllocation
	where WorkloadAllocation = 'Production';

	select wal.WorkloadAllocationID as CurrentWorkloadAllocationID,
		wal.WorkloadAllocation as CurrentWorkloadAllocationName,
		wal2.WorkloadAllocationID as NewWorkloadAllocationID,
		wal2.WorkloadAllocation as NewWorkloadAllocationName
	into #WorkloadAllocationMapping
	from WorkloadAllocation wal
	left join WorkloadAllocation wal2
	on (case
		when wal.WorkloadAllocation = 'Program MGMT: TF/CAM Oversight, Compliance, & Mandates' and wal2.WorkloadAllocation = 'Program MGMT' then 1
		when wal.WorkloadAllocation = 'Program MGMT: Contracting Compliance, Qualifications for Partner, etc,' and wal2.WorkloadAllocation = 'Program MGMT' then 1
		when wal.WorkloadAllocation = 'Program MGMT: Internal Support Oversight, Compliance, & Mandates' and wal2.WorkloadAllocation = 'Program MGMT' then 1
		when wal.WorkloadAllocation = 'Program MGMT: ANG Oversight, Compliance, & Mandates' and wal2.WorkloadAllocation = 'Program MGMT' then 1
		when wal.WorkloadAllocation = 'Deployment: TF/CAM Scheduled Sustainment' and wal2.WorkloadAllocation = 'Deployment' then 1
		when wal.WorkloadAllocation = 'Deployment: Contracting Team Scheduled Workload/Deliverable' and wal2.WorkloadAllocation = 'Deployment' then 1
		when wal.WorkloadAllocation = 'Deployment: ANG Configuration Management and Cyclical Process' and wal2.WorkloadAllocation = 'Deployment' then 1
		when wal.WorkloadAllocation = 'Deployment: Internal Sustainment/Scheduled Workload' and wal2.WorkloadAllocation = 'Deployment' then 1
		when wal.WorkloadAllocation = 'Production: TF/CAM Warranty, Emergency, & Unscheduled' and wal2.WorkloadAllocation = 'Production' then 1
		when wal.WorkloadAllocation = 'Production: Internal Support, Emergency, & Unscheduled' and wal2.WorkloadAllocation = 'Production' then 1
		when wal.WorkloadAllocation = 'Production: ANG Warranty, Direct Support, and Travel' and wal2.WorkloadAllocation = 'Production' then 1
		when wal.WorkloadAllocation = 'Production: Contracting Short Suspense, Day-to-Day not tied to Deployment' and wal2.WorkloadAllocation = 'Production' then 1
		else 0 end) = 1
	where wal.WorkloadAllocationID in (1,2,6,7,10,11,12,14,16,17,18,20);

	insert into AORRelease_History(ITEM_UPDATETYPEID, AORReleaseID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
	select 5,
		arl.AORReleaseID,
		'Workload Allocation',
		wam.CurrentWorkloadAllocationName,
		wam.NewWorkloadAllocationName,
		'WTS',
		@date,
		'WTS',
		@date
	from AORRelease arl
	join #WorkloadAllocationMapping wam
	on arl.WorkloadAllocationID = wam.CurrentWorkloadAllocationID;

	update arl
	set WorkloadAllocationID = wam.NewWorkloadAllocationID,
		UPDATEDBY = 'WTS',
		UPDATEDDATE = @date
	from AORRelease arl
	join #WorkloadAllocationMapping wam
	on arl.WorkloadAllocationID = wam.CurrentWorkloadAllocationID;

	update nc
	set WorkloadAllocationID = wam.NewWorkloadAllocationID
	from Narrative_CONTRACT nc
	join #WorkloadAllocationMapping wam
	on nc.WorkloadAllocationID = wam.CurrentWorkloadAllocationID;

	delete from WorkloadAllocation_Contract;

	delete from WorkloadAllocation_Status;

	delete from WorkloadAllocation
	where WorkloadAllocationID in (1,2,6,7,10,11,12,14,16,17,18,20);

	update Narrative
	set Narrative = 'Program MGMT'
	where Narrative like 'Program MGMT:%';

	update Narrative
	set Narrative = 'Deployment'
	where Narrative like 'Deployment:%';

	update Narrative
	set Narrative = 'Production'
	where Narrative like 'Production:%';

	update Narrative
	set Narrative = 'Mission'
	where NarrativeID in (35,36,37);

	delete from Narrative
	where NarrativeID in (11,27,32,33);

	insert into WORKITEMTYPE (WORKITEMTYPE, [DESCRIPTION], SORT_ORDER, ARCHIVE, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE, PDDTDR_PHASEID, WorkloadAllocationID)
	select 'P1 - SR Database', 'Maintain the SR Database: Monthly Status Report reflecting Quantitative SR measurements, project charter and plan, and project release kick off meeting minutes.', 1, 0, 'WTS', @date, 'WTS', @date, 2, @ProgramMGMTID
	union all
	select 'P2A - Project Scope', 'Determine the Scope of the Project (Release Sprints and Unplanned Fix Sprints): A prioritized and approved list of CR/CSRDs. ', 2, 0, 'WTS', @date, 'WTS', @date, 2, @ProgramMGMTID
	union all
	select 'P2B - Estimate', 'Perform Estimates and save documentation in ITI Estimating folder/container', 3, 0, 'WTS', @date, 'WTS', @date, 2, @ProgramMGMTID
	union all
	select 'P3 - RQMT Baseline', 'Establish the Baseline for Functional Requirement Configuration Management: AOR Project Management Tool Reports, RTM, and WTS Reports.', 4, 0, 'WTS', @date, 'WTS', @date, 2, @ProgramMGMTID
	union all
	select 'P4 - Cyber', 'Perform Portfolio Management (Anticipated Cyber Risks and Architecture) Assessments: AOR Project Management Tool Reports and/or WTS indicating cybersecurity risk and architectural assessment outcomes by CR/CSRD.', 5, 0, 'WTS', @date, 'WTS', @date, 2, @ProgramMGMTID
	union all
	select 'P5 - Tools', 'Initiate Project Management Tools: AOR Project Management Tool Reports and WTS indicating CR/CSRD work task estimates, team assignments, and progress measurements; Project Charter & Project Plan are completed and being utilized.', 6, 0, 'WTS', @date, 'WTS', @date, 2, @ProgramMGMTID
	union all
	select 'D1A - DAR', 'Create and Approve Technical Requirements/Design: Technical Designs completed', 7, 0, 'WTS', @date, 'WTS', @date, 3, @DeploymentID
	union all
	select 'D1B - Technical Design', 'Create/Save DAR slide with every Technical Design', 8, 0, 'WTS', @date, 'WTS', @date, 3, @DeploymentID
	union all
	select 'D2 - Customer Design', 'Create, Present and Approve Customer Design: Customer Presentation Completed and Approved', 9, 0, 'WTS', @date, 'WTS', @date, 3, @DeploymentID
	union all
	select 'D3 - Data Model', 'Develop and Approve the Data Model:  Data Model Completed ', 10, 0, 'WTS', @date, 'WTS', @date, 3, @DeploymentID
	union all
	select 'DV1 - Maintain SVN for Code', 'Maintain CAFDEx® Code Configuration Management Practices:  Code has been committed to SVN and prior versions saved in historical archive ', 11, 0, 'WTS', @date, 'WTS', @date, 4, @DeploymentID
	union all
	select 'DV2 - Develop Code', 'Develop Code:  Progressive cyclical Develop and Test processes have been completed and code has been accepted/approved for deployment.  Developer Meeting minutes with measurements containing the number of Internal Verification Test (IVTs)/peer reviews that are required, the number that are not ready to test, and the number that are ready to test.', 12, 0, 'WTS', @date, 'WTS', @date, 4, @DeploymentID
	union all
	select 'T1 - Test Plan', 'Develop a Test Plan:  Test Plan, Test Descriptions, RTM Functional Requirement Management Tool has been maintained in accordance with processes and previous and final Functional Requirement Definition versions are available in the Requirement Traceability Matrix (RTM).', 13, 0, 'WTS', @date, 'WTS', @date, 5, @DeploymentID
	union all
	select 'T2A - IVT/Peer Review', 'Perform Internal Verification/Peer Reviews - CVTs and Code: Management log documenting Peer reviews perfomred, time taken, cert time taken was sufficient, and action taken if required', 14, 0, 'WTS', @date, 'WTS', @date, 5, @DeploymentID
	union all
	select 'T2B - Perform Testing', 'Perform Testing: Current versions of the Customer Validation Test Scripts have been committed to SVN including descriptions of quality, scope and functionality. Previous CVT versions are available in historical archive. ', 15, 0, 'WTS', @date, 'WTS', @date, 5, @DeploymentID
	union all
	select 'T3 - Report Results: IP1, IP2 and IP3', 'Report Results: IP1, IP2 and IP3 Test Reports to include documentation indicating acceptance of tests, Approved Field Readiness Review (FRR) Memo.', 16, 0, 'WTS', @date, 'WTS', @date, 5, @DeploymentID
	union all
	select 'T4 - Maintain RQMT DB', 'Establish Bidirectional Traceability: The RTM Configuration Management Tool contains new requirement definitions as applicable. Functional requirements are linked to CSRDs and CVTs.  ', 17, 0, 'WTS', @date, 'WTS', @date, 5, @DeploymentID
	union all
	select 'DP1 - Implement Sys. Notification and Communication: Go Live checklist', 'Implement System Notification and Communication: CAFDEx Go Live checklist are complete indicating notification and communication activities were performed.', 18, 0, 'WTS', @date, 'WTS', @date, 6, @ProgramMGMTID
	union all
	select 'DP2 - Implement Stage Deployment activities', 'Implement Stage Deployment activities: ITI’s CAFDEx Go Live checklist is complete indicating activities have been performed and are complete.', 19, 0, 'WTS', @date, 'WTS', @date, 6, @ProgramMGMTID
	union all
	select 'DP3 - Go Live checklist complete', 'Deploy: ITI’s CAFDEx Go Live checklist is complete indicating activities have been performed and are complete.', 20, 0, 'WTS', @date, 'WTS', @date, 6, @ProgramMGMTID
	union all
	select 'DP4 - Go-live Testing results (Performance Testing)', 'Test: Golive Testing results (Performance Testing) indicate system is running as anticipated given all issues identified during deployment testing have been resolved; Database, User Interfaces, and Code deployed to live (production) servers matches code approved as committed to SVN.', 21, 0, 'WTS', @date, 'WTS', @date, 6, @ProgramMGMTID
	union all
	select 'DP5 - Initiate Post Deployment Activities', 'Initiate Post Deployment Activities:  ITI’s CAFDEx Go Live checklist is complete indicating all test environments match production and all items are complete. ', 22, 0, 'WTS', @date, 'WTS', @date, 6, @ProgramMGMTID
	union all
	select 'R1 - Initiate Warranty Period', 'Initiate the Warranty Period: Artifact includes all closed WTS items ', 23, 0, 'WTS', @date, 'WTS', @date, 7, @ProgramMGMTID
	union all
	select 'R2 - Incorporate Process Efficiencies', 'Incorporate Process Efficiencies: Artifact: New process guidance incorporating approved efficiencies is saved and available.', 24, 0, 'WTS', @date, 'WTS', @date, 7, @ProgramMGMTID
	union all
	select 'R3 - Close the Project', 'Close the Project:  
	a.)  A final hotlist is generated indicating all CR/CSRDs that were completed.  Discrepancies between the initially approved list and the final list are explained along with a clear indication of who approved the change whether it be adding a new CR/CSRD or pushing a CR/CSRD out to another release
	b.)  ITI’s Standard Process documentation is available identifying/tracking instances in which processes had to be changed/tailored during the project and the tailoring column of the processes clearly articulate what the change was and who approved the change (Tailoring aligned with authority to tailor instructions as articulated in CAFDEx Software Sustainment and Maintenance Handbook or alternatively approved by Project Manager and/or VP for IT Operations).  
	c.)  All project tasks WTS are marked as closed.  Open tasks are reviewed and either closed or pushed to the next development project. 
	d.)  All other tools to include plans and schedules are synched, closed and stored as required.
	e.)  QA closes their QA Audit tool checklist and all other checklists.  Non-compliance are addressed as having been approved and documented as a tailored process by the Project Manager or VP for IT Operations, or having been authorized to remain non-compliant.', 25, 0, 'WTS', @date, 'WTS', @date, 7, @ProgramMGMTID
	union all
	select 'Software Dev - Planning', '', 25, 0, 'WTS', @date, 'WTS', @date, 2, null
	union all
	select 'Software Dev - Design/Prototype', '', 26, 0, 'WTS', @date, 'WTS', @date, 3, null
	union all
	select 'Software Dev - Development', '', 27, 0, 'WTS', @date, 'WTS', @date, 4, null
	union all
	select 'Software Dev - Testing', '', 28, 0, 'WTS', @date, 'WTS', @date, 5, null
	union all
	select 'Software Dev - Review', '', 29, 0, 'WTS', @date, 'WTS', @date, 7, null
	union all
	select 'Business Development', '', 30, 0, 'WTS', @date, 'WTS', @date, null, null
	union all
	select 'Training Development', '', 31, 0, 'WTS', @date, 'WTS', @date, null, null
	union all
	select 'Cyber', '', 32, 0, 'WTS', @date, 'WTS', @date, null, null
	union all
	select 'Database Management', '', 33, 0, 'WTS', @date, 'WTS', @date, null, null
	union all
	select 'System Administration', '', 34, 0, 'WTS', @date, 'WTS', @date, null, null
	union all
	select 'Human Resources or HR', '', 35, 0, 'WTS', @date, 'WTS', @date, null, null
	;

	select wac.WORKITEMTYPEID as CurrentWorkActivityID,
		wac.WORKITEMTYPE as CurrentWorkActivityName,
		wac2.WORKITEMTYPEID as NewWorkActivityID,
		wac2.WORKITEMTYPE as NewWorkActivityName
	into #WorkActivityMapping
	from WORKITEMTYPE wac
	left join WORKITEMTYPE wac2
	on (case
		when wac.WORKITEMTYPE = 'Adoption (Training / Documentation)' and wac2.WORKITEMTYPE = 'Training Development' then 1
		when wac.WORKITEMTYPE = 'Testing (CVT / Release Support)' and wac2.WORKITEMTYPE = 'T1 - Test Plan' then 1
		when wac.WORKITEMTYPE = 'Release MGMT\CMMI RQMT' and wac2.WORKITEMTYPE = 'D1A - DAR' then 1
		when wac.WORKITEMTYPE = 'Business Team Task (Other)' and wac2.WORKITEMTYPE = 'T2B - Perform Testing' then 1
		when wac.WORKITEMTYPE = 'System Coding' and wac2.WORKITEMTYPE = 'DV2 - Develop Code' then 1
		when wac.WORKITEMTYPE = 'SYS Admin\DBA - not CYBER' and wac2.WORKITEMTYPE = 'Database Management' then 1
		when wac.WORKITEMTYPE = 'Cyber RQMT' and wac2.WORKITEMTYPE = 'P4 - Cyber' then 1
		when wac.WORKITEMTYPE = 'Contracting Not Proposals' and wac2.WORKITEMTYPE = 'Business Development' then 1
		else 0 end) = 1
	where wac.WORKITEMTYPEID in (11,15,17,20,21,23,24,27);

	insert into WorkItem_History (ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
	select 5,
		wi.WORKITEMID,
		'Work Activity',
		wam.CurrentWorkActivityName,
		wam.NewWorkActivityName,
		'WTS',
		@date,
		'WTS',
		@date
	from WORKITEM wi
	join #WorkActivityMapping wam
	on wi.WORKITEMTYPEID = wam.CurrentWorkActivityID;

	update wi
	set WORKITEMTYPEID = wam.NewWorkActivityID,
		UPDATEDBY = 'WTS',
		UPDATEDDATE = @date
	from WORKITEM wi
	join #WorkActivityMapping wam
	on wi.WORKITEMTYPEID = wam.CurrentWorkActivityID;
	
	insert into WORKITEM_TASK_HISTORY (ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE)
	select 5,
		wit.WORKITEM_TASKID,
		'Work Activity',
		wam.CurrentWorkActivityName,
		wam.NewWorkActivityName,
		'WTS',
		@date,
		'WTS',
		@date
	from WORKITEM_TASK wit
	join #WorkActivityMapping wam
	on wit.WORKITEMTYPEID = wam.CurrentWorkActivityID;

	update wit
	set WORKITEMTYPEID = wam.NewWorkActivityID,
		UPDATEDBY = 'WTS',
		UPDATEDDATE = @date
	from WORKITEM_TASK wit
	join #WorkActivityMapping wam
	on wit.WORKITEMTYPEID = wam.CurrentWorkActivityID;
	
	update WORKITEMTYPE
	set PDDTDR_PHASEID = null,
		SORT_ORDER = 36
	where WORKITEMTYPEID = 22;

	delete from WTS_SYSTEM_WORKACTIVITY;

	delete from WORKITEMTYPE
	where WORKITEMTYPEID in (11,15,17,20,21,23,24,27);

	drop table #WorkloadAllocationMapping;
	drop table #WorkActivityMapping;
end;
go
