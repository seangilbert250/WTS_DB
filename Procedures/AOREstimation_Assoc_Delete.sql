USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOREstimation_Assoc_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AOREstimation_Assoc_Delete]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[AOREstimation_Assoc_Delete]
	@AOREstimation_AORAssocID int,
	@Exists int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from AOREstimation_AORAssoc where AOREstimation_AORAssocID = @AOREstimation_AORAssocID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		delete from AOREstimation_AORAssoc
		where AOREstimation_AORAssocID = @AOREstimation_AORAssocID;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
GO


