use [WTS]
go

update [PRIORITY]
set [PRIORITY] = '3 - Run the Business',
	[DESCRIPTION] = '3 - Run the Business',
	UPDATEDDATE = getdate()
where [PRIORITY] = '3 - Recurring Workload';

update [PRIORITY]
set [PRIORITY] = '3 – Run the Business',
	[DESCRIPTION] = '3 – Run the Business',
	UPDATEDDATE = getdate()
where [PRIORITY] = '3 – Recurring Workload';

update WorkItem_History
set OldValue = '3 - Run the Business'
where OldValue = '3 - Recurring Workload'
and FieldChanged = 'Assigned To Rank';

update WorkItem_History
set NewValue = '3 - Run the Business'
where NewValue = '3 - Recurring Workload'
and FieldChanged = 'Assigned To Rank';

update WORKITEM_TASK_HISTORY
set OldValue = '3 - Run the Business'
where OldValue = '3 - Recurring Workload'
and FieldChanged = 'Assigned To Rank';

update WORKITEM_TASK_HISTORY
set NewValue = '3 - Run the Business'
where NewValue = '3 - Recurring Workload'
and FieldChanged = 'Assigned To Rank';
