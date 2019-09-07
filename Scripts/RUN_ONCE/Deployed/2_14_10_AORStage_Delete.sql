USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORStage_Delete]    Script Date: 2/14/2018 2:57:33 PM ******/
DROP PROCEDURE [dbo].[AORStage_Delete]
GO

/****** Object:  StoredProcedure [dbo].[AORStage_Delete]    Script Date: 2/14/2018 2:57:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[AORStage_Delete]
	@AORReleaseStageID int,
	@Exists int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from AORReleaseStage where AORReleaseStageID = @AORReleaseStageID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		delete from AORReleaseStage
		where AORReleaseStageID = @AORReleaseStageID;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
GO


