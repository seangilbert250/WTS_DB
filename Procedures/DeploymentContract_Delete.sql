USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[DeploymentContract_Delete]    Script Date: 4/5/2018 2:19:28 PM ******/
DROP PROCEDURE [dbo].[DeploymentContract_Delete]
GO

/****** Object:  StoredProcedure [dbo].[DeploymentContract_Delete]    Script Date: 4/5/2018 2:19:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[DeploymentContract_Delete]
	@DeploymentContractID int,
	@Exists int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from DeploymentContract where DeploymentContractID = @DeploymentContractID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		delete from DeploymentContract
		where DeploymentContractID = @DeploymentContractID;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
GO
