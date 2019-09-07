use [WTS]
go

alter table WORKITEMTYPE
add WorkloadAllocationID int null;
go

ALTER TABLE [dbo].[WORKITEMTYPE]  WITH CHECK ADD  CONSTRAINT [FK_WORKITEMTYPE_WorkloadAllocationID] FOREIGN KEY([WorkloadAllocationID])
REFERENCES [dbo].[WorkloadAllocation] ([WorkloadAllocationID])
GO