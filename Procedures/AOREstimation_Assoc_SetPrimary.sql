USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOREstimation_Assoc_SetPrimary]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AOREstimation_Assoc_SetPrimary]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[AOREstimation_Assoc_SetPrimary]
	@AOREstimation_AORAssocID int,
	@Exists int = 0 output,
	@Saved bit = 0 output
as
begin
	select @Exists = count(*) from AOREstimation_AORAssoc where AOREstimation_AORAssocID = @AOREstimation_AORAssocID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		update AOREstimation_AORAssoc
		set [Primary] = 0
		;

		update AOREstimation_AORAssoc
		set [Primary] = 1
		where AOREstimation_AORAssocID = @AOREstimation_AORAssocID;

		set @Saved = 1;
	end try
	begin catch
		
	end catch;
end;
GO


