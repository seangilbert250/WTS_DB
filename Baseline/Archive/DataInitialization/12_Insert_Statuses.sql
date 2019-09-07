USE WTS
GO

SET IDENTITY_INSERT [StatusType] ON
GO

INSERT INTO [StatusType](StatusTypeID, StatusType, [DESCRIPTION], SORT_ORDER)
SELECT 1, 'Work', 'Generic Work Status Type', 1 UNION ALL
SELECT 2, 'TD', 'Tech Rqmts/Design', 2 UNION ALL
SELECT 3, 'CD', 'Custom Design Review', 3 UNION ALL
SELECT 4, 'C', 'Coding', 4 UNION ALL
SELECT 5, 'IT', 'Internal Testing', 5 UNION ALL
SELECT 6, 'CVT', 'Customer Verification Testing', 6 UNION ALL
SELECT 7, 'Adopt', 'Adoption', 7 UNION ALL
SELECT 8, 'CR', 'Cyber Review', 8 UNION ALL
SELECT 9, 'Release', 'Release Version status', 9
EXCEPT
SELECT StatusTypeID, StatusType, [DESCRIPTION], SORT_ORDER FROM StatusType
GO

SET IDENTITY_INSERT [StatusType] OFF
GO

--DELETE FROM [STATUS]
--GO

INSERT INTO [STATUS](SORT_ORDER, StatusTypeID, STATUS, [DESCRIPTION])
SELECT 1, 1, 'New', 'New' UNION ALL
SELECT 2, 1, 'Re-Opened', 'Item was sent back for re-work from checked-in, deployed or closed status' UNION ALL
SELECT 3, 1, 'Info Requested', 'Information has been requested to help understanding of workload' UNION ALL
SELECT 4, 1, 'Info Provided', 'Necessary information has been provided' UNION ALL
SELECT 5, 1, 'In Progress', 'Work is in progress' UNION ALL
SELECT 6, 1, 'On Hold', 'Item is awaiting approval to proceed' UNION ALL
SELECT 7, 1, 'Un-Reproducible', 'Un-Reproducible' UNION ALL
SELECT 8, 1, 'Checked In', 'Source code or other work has been checked in' UNION ALL
SELECT 9, 1, 'Deployed', 'Feature is available in target environment' UNION ALL
SELECT 10, 1, 'Closed', 'Work Item/Issue has been completed and verified' UNION ALL
SELECT 11, 1, 'Ready for Review', 'Item is ready to be reviewed' UNION ALL
SELECT 12, 1, 'In Review', 'Item is currently under review' UNION ALL
SELECT 13, 1, 'Review Complete', 'Review of item is complete' UNION ALL
SELECT 14, 1, 'Recurring', 'This is a recurring item' UNION ALL
SELECT 15, 1, 'Complete', 'Work for this item is complete'
UNION ALL --TD (Tech Rqmts/Design) Statuses
SELECT 1, 2, 'D1', 'Investigation' UNION ALL
SELECT 2, 2, 'D2', 'Initial Presentation' UNION ALL
SELECT 3, 2, 'D3', 'Preliminary Dev Accepted' UNION ALL
SELECT 4, 2, 'D4', 'Data Model In Progress' UNION ALL
SELECT 5, 2, 'D5', 'Ready for Review' UNION ALL
SELECT 6, 2, 'D6', 'Tech Design Review Complete'
UNION ALL --CD (Custom Design Review) Statuses
SELECT 1, 3, 'CD1', 'Just Started(Investigation)' UNION ALL
SELECT 2, 3, 'CD2', 'Use Cases' UNION ALL
SELECT 3, 3, 'CD3', 'Ready for Internal Sign Off' UNION ALL
SELECT 4, 3, 'CD4', 'Ready for Customer' UNION ALL
SELECT 5, 3, 'CD5', 'Presentation Delivered' UNION ALL
SELECT 6, 3, 'CD6', 'Complete, Accepted by Customer'
UNION ALL --C (Coding) Statuses
SELECT 1, 4, 'C1', 'Not Ready for Coding(Investigation)' UNION ALL
SELECT 2, 4, 'C2', 'Ready for Coding(Workload Assigned)' UNION ALL
SELECT 3, 4, 'C3', 'Healthy Progress' UNION ALL
SELECT 4, 4, 'C4', 'Almost Done: DEV showcase to Business Team' UNION ALL
SELECT 5, 4, 'C5', 'In Testing' UNION ALL
SELECT 6, 4, 'C6', 'Coding Done'
UNION ALL --IT Statuses
SELECT 1, 5, 'IT1', 'Identify Test Objectives(Investigation)' UNION ALL
SELECT 2, 5, 'IT2', 'Logical Unit Testing: DEV showcase to Business Team' UNION ALL
SELECT 3, 5, 'IT3', 'Development Testing: Build CVTs' UNION ALL
SELECT 4, 5, 'IT4', 'Integration Testing: Execute CVTs' UNION ALL
SELECT 5, 5, 'IT5', 'System Testing: Execute "Use Cases"' UNION ALL
SELECT 6, 5, 'IT6', 'Regression Testing' UNION ALL
SELECT 7, 5, 'IT7', 'Training/Help Files' UNION ALL
SELECT 8, 5, 'IT8', 'Adoption/Sustainment'
UNION ALL --CVT Statuses
SELECT 1, 6, 'NR', 'Not Ready for Testing(Investigation)' UNION ALL
SELECT 2, 6, 'R', 'Ready for Testing' UNION ALL
SELECT 3, 6, 'IP1', 'Identification of CVTs' UNION ALL
SELECT 4, 6, 'IP2', 'Small Test Group; Full CVTs' UNION ALL
SELECT 5, 6, 'IP3', 'Large Test Group; Full CVTs' UNION ALL
SELECT 6, 6, 'IP4', 'Ready for Deploy' UNION ALL
SELECT 7, 6, 'IP5', 'LCMB Sign Off' UNION ALL
SELECT 8, 6, 'IP6', 'Deployed' UNION ALL
SELECT 9, 6, 'IP7', 'Adoption/Sustainment'
UNION ALL --Adopt Statuses
SELECT 1, 7, 'NU', 'Not Used(Needs Adoption Support) Biz Resource Strained' UNION ALL
SELECT 2, 7, 'Min/M-SRs', 'Minor-Use(Minimal SRs): Resource Biz & Dev Predictable' UNION ALL
SELECT 3, 7, 'MAJ/G-SRs', 'Major-Use(Getting SRs): Resource Biz & Dev Strained' UNION ALL
SELECT 4, 7, 'AD', 'Adoption(No SRs): Resources as Necessary' 
UNION ALL --Cyber Review Statuses
SELECT 1, 8, 'CR1', '' UNION ALL
SELECT 2, 8, 'CR2', ''
UNION ALL --Release Version Statuses
SELECT 1, 9, 'Active Dev', 'Active development status for New development' UNION ALL
SELECT 2, 9, 'Warranty', 'Development for deployed release version' UNION ALL
SELECT 3, 9, 'Other', 'Other release status (generally closed)' UNION ALL
SELECT 4, 9, 'Archive', 'Release Version is Archived(no longer in warranty or active development'
EXCEPT
SELECT SORT_ORDER, StatusTypeID, [STATUS], [DESCRIPTION] FROM STATUS
GO
