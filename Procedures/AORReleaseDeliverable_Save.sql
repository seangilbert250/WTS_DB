USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORReleaseDeliverable_Save]    Script Date: 8/8/2018 12:14:39 PM ******/
DROP PROCEDURE [dbo].[AORReleaseDeliverable_Save]
GO

/****** Object:  StoredProcedure [dbo].[AORReleaseDeliverable_Save]    Script Date: 8/8/2018 12:14:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AORReleaseDeliverable_Save]
	@AORReleaseDeliverableID int,
	@Weight int,
	@UpdatedBy nvarchar(255) = 'WTS',
	@saved int output

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();

	UPDATE [dbo].[AORReleaseDeliverable]
	SET
		[Weight] = @Weight
        ,[UPDATEDBY] = @UpdatedBy
        ,[UPDATEDDATE] = @date
	WHERE AORReleaseDeliverableID = @AORReleaseDeliverableID

	SET @saved = 1;

END;

GO


