USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkRequest_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkRequest_Update]

GO
USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WorkRequest_Update]    Script Date: 6/8/2016 4:03:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WorkRequest_Update]
	@WORKREQUESTID int,
	@RequestGroupID int = null,
	@REQUESTTYPEID int,
	@CONTRACTID int = null,
	@ORGANIZATIONID int = null,
	@WTS_SCOPEID int = null,
	@EFFORTID int = null,
	@SMEID int = null,
	@LEAD_IA_TWID int = null,
	@LEAD_RESOURCEID int = null,
	@OP_PRIORITYID int = null,
	@TITLE nvarchar(150),
	@DESCRIPTION nvarchar(max) = null,
	@JUSTIFICATION nvarchar(max) = null,
	@ARCHIVE bit = 0,
	@SUBMITTEDBY int = null,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@saved bit output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @saved = 0;
	
	SELECT @count = COUNT(*) FROM WORKREQUEST WHERE WORKREQUESTID = @WORKREQUESTID;
	
	IF (ISNULL(@count,0) > 0)
		BEGIN
			UPDATE WORKREQUEST
			SET
				REQUESTTYPEID = @REQUESTTYPEID
				, RequestGroupID = @RequestGroupID
				, CONTRACTID = @CONTRACTID
				, ORGANIZATIONID = @ORGANIZATIONID
				, WTS_SCOPEID = @WTS_SCOPEID
				, EFFORTID = @EFFORTID
				, SMEID = @SMEID
				, LEAD_IA_TWID = @LEAD_IA_TWID
				, LEAD_RESOURCEID = @LEAD_RESOURCEID
				, OP_PRIORITYID = @OP_PRIORITYID
				, TITLE = @TITLE
				, [DESCRIPTION] = @DESCRIPTION
				, JUSTIFICATION = @JUSTIFICATION
				, ARCHIVE = @ARCHIVE
				, SUBMITTEDBY = @SUBMITTEDBY
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE
				WORKREQUESTID = @WORKREQUESTID
			;

			SET @saved = 1;
		END;
END;
