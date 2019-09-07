USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[DeploymentContract_Add]    Script Date: 4/5/2018 1:07:56 PM ******/
DROP PROCEDURE [dbo].[DeploymentContract_Add]
GO

/****** Object:  StoredProcedure [dbo].[DeploymentContract_Add]    Script Date: 4/5/2018 1:07:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[DeploymentContract_Add]
	@DeliverableID int,
	@Additions xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	begin try
		if @Additions.exist('additions/save') > 0
			begin
				with
				w_contracts as (
					select distinct
						tbl.[save].value('contract_id[1]', 'int') as ContractID
					from @Additions.nodes('additions/save') as tbl([save])
				)
				insert into DeploymentContract(ContractID, DeliverableID, CreatedBy, UpdatedBy)
				select ContractID,
					@DeliverableID,
					@UpdatedBy,
					@UpdatedBy
				from w_contracts;
			end;

		set @Saved = 1;
	end try
	begin catch
				
	end catch;
end;
