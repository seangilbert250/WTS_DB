USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[DeploymentContractList_Get]    Script Date: 4/5/2018 10:27:36 AM ******/
DROP PROCEDURE [dbo].[DeploymentContractList_Get]
GO

/****** Object:  StoredProcedure [dbo].[DeploymentContractList_Get]    Script Date: 4/5/2018 10:27:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[DeploymentContractList_Get]
	@DeliverableID int = 0
as
begin
	begin
		select c.CONTRACTID as Contract_ID,
			c.CONTRACT as [CONTRACT],
			dc.DeploymentContractID as DeploymentContract_ID,
			null as Z
		from CONTRACT c
		join DeploymentContract dc
		on c.CONTRACTID = dc.ContractID
		where dc.DeliverableID = @DeliverableID
		and c.Archive = 0
		order by upper(c.SORT_ORDER);
	end;
end;

GO
