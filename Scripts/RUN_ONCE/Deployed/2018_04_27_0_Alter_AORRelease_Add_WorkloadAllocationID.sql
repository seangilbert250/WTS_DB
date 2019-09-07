
use [WTS]
go
IF dbo.ColumnExists('dbo','AORRelease','WorkloadAllocationID') = 0
BEGIN
ALTER TABLE AORRelease
    ADD WorkloadAllocationID int null


ALTER TABLE AORRelease
    ADD constraint [FK_AORRelease_WorkloadAllocation] foreign key ([WorkloadAllocationID]) references [WorkloadAllocation]([WorkloadAllocationID])

END
go


use [WTS]
go
IF dbo.ColumnExists('dbo','Image_CONTRACT','WorkloadAllocationID') = 0
BEGIN
ALTER TABLE Image_CONTRACT
    ADD WorkloadAllocationID int null


ALTER TABLE Image_CONTRACT
    ADD constraint [FK_Image_CONTRACT_WorkloadAllocation] foreign key ([WorkloadAllocationID]) references [WorkloadAllocation]([WorkloadAllocationID])

END
go

use [WTS]
go
IF dbo.ColumnExists('dbo','Narrative_CONTRACT','WorkloadAllocationID') = 0
BEGIN
ALTER TABLE Narrative_CONTRACT
    ADD WorkloadAllocationID int null


ALTER TABLE Narrative_CONTRACT
    ADD constraint [FK_Narrative_CONTRACT_WorkloadAllocation] foreign key ([WorkloadAllocationID]) references [WorkloadAllocation]([WorkloadAllocationID])

END
go