use [WTS]
go

insert into WorkloadAllocation_Status (wal.WorkloadAllocationID, STATUSID)
select wal.WorkloadAllocationID, s.STATUSID
from WorkloadAllocation wal
cross join [STATUS] s
join StatusType st
on s.StatusTypeID = st.StatusTypeID
where st.StatusType in ('Inv', 'TD', 'CD', 'C', 'IT', 'CVT', 'Adopt')
and not exists (
	select 1
	from WorkloadAllocation_Status was
	where was.WorkloadAllocationID = wal.WorkloadAllocationID
	and was.STATUSID = s.STATUSID
)
order by wal.WorkloadAllocationID, st.SORT_ORDER, s.SORT_ORDER;
