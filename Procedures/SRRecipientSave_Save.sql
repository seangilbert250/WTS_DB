USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[SRRecipientSave_Save]    Script Date: 4/26/2017 3:25:58 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SRRecipientSave_Save]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[SRRecipientSave_Save]
GO
/****** Object:  StoredProcedure [dbo].[SRRecipientSave_Save]    Script Date: 4/26/2017 3:25:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SRRecipientSave_Save]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[SRRecipientSave_Save] AS' 
END
GO

ALTER PROCEDURE [dbo].[SRRecipientSave_Save] 

	@WTSID INT = 0,
	@receiveSREMail BIT = 0,
	@includeInSRCounts BIT = 0

AS
BEGIN
	SET NOCOUNT ON;

	UPDATE WTS_RESOURCE SET ReceiveSREMail = @receiveSREMail, IncludeInSRCounts = @includeInSRCounts WHERE WTS_RESOURCEID = @WTSID;
	 
END

GO
