use [WTS]
go

update WorkItem_History
set OldValue = case
					when OldValue = '3 - Staged Workload' then '4 - Staged Workload'
					when OldValue = '4 - Unprioritized Workload' then '5 - Unprioritized Workload'
					when OldValue = '5 - Closed Workload' then '6 - Closed Workload'
					else OldValue
				end
where OldValue in ('3 - Staged Workload', '4 - Unprioritized Workload', '5 - Closed Workload')
and FieldChanged = 'Assigned To Rank';

update WorkItem_History
set NewValue = case
					when NewValue = '3 - Staged Workload' then '4 - Staged Workload'
					when NewValue = '4 - Unprioritized Workload' then '5 - Unprioritized Workload'
					when NewValue = '5 - Closed Workload' then '6 - Closed Workload'
					else NewValue
				end
where NewValue in ('3 - Staged Workload', '4 - Unprioritized Workload', '5 - Closed Workload')
and FieldChanged = 'Assigned To Rank';

update WORKITEM_TASK_HISTORY
set OldValue = case
					when OldValue = '3 - Staged Workload' then '4 - Staged Workload'
					when OldValue = '4 - Unprioritized Workload' then '5 - Unprioritized Workload'
					when OldValue = '5 - Closed Workload' then '6 - Closed Workload'
					else OldValue
				end
where OldValue in ('3 - Staged Workload', '4 - Unprioritized Workload', '5 - Closed Workload')
and FieldChanged = 'Assigned To Rank';

update WORKITEM_TASK_HISTORY
set NewValue = case
					when NewValue = '3 - Staged Workload' then '4 - Staged Workload'
					when NewValue = '4 - Unprioritized Workload' then '5 - Unprioritized Workload'
					when NewValue = '5 - Closed Workload' then '6 - Closed Workload'
					else NewValue
				end
where NewValue in ('3 - Staged Workload', '4 - Unprioritized Workload', '5 - Closed Workload')
and FieldChanged = 'Assigned To Rank';