use [WTS]
go

/*
3	Delete this Workload Allocation 1
4	Delete this Workload Allocation 2
5	Delete this Workload Allocation 3
8	Delete this Workload Allocation 5
9	Delete this Workload Allocation
13	Delete this Workload Allocation 7
15	Delete this Workload Allocation 4
19	Delete this Workload Allocation 6
*/

update AORRelease
set WorkloadAllocationID = null
where WorkloadAllocationID in (3,4,5,8,9,13,15,19);

delete from WorkloadAllocation_Status
where WorkloadAllocationID in (3,4,5,8,9,13,15,19);

delete from WorkloadAllocation
where WorkloadAllocationID in (3,4,5,8,9,13,15,19);
