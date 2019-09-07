use [WTS]
go

Begin
update AORRelease
set WorkloadAllocationID = 
(select WorkloadAllocationID
from WorkloadAllocation 
where WorkloadAllocation = 
(select [status] from [status]
where [statusID] = ReleaseProductionStatusID));

End
go

use [WTS]
go

Begin
update Image_CONTRACT
set WorkloadAllocationID = 
(select WorkloadAllocationID
from WorkloadAllocation 
where WorkloadAllocation = 
(select [status] from [status]
where [statusID] = ReleaseProductionStatusID));

End
go

use [WTS]
go

Begin
update Narrative_CONTRACT
set WorkloadAllocationID = 
ReleaseProductionStatusID;

End
go