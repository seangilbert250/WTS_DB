USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORDeliverable_Delete]    Script Date: 2/16/2018 3:37:38 PM ******/
DROP PROCEDURE [dbo].[AORDeliverable_Delete]
GO

/****** Object:  StoredProcedure [dbo].[AORDeliverable_Delete]    Script Date: 2/16/2018 3:37:38 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[AORDeliverable_Delete]
	@AORReleaseDeliverableID int,
	@Exists int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from AORReleaseDeliverable where AORReleaseDeliverableID = @AORReleaseDeliverableID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	begin try
		delete from AORReleaseDeliverable
		where AORReleaseDeliverableID = @AORReleaseDeliverableID;

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
GO


