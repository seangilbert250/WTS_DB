USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkRequest_QM_Update]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkRequest_QM_Update]

GO
USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WorkRequest_QM_Update]    Script Date: 6/9/2016 9:53:50 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WorkRequest_QM_Update]
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
	@DESCRIPTION nvarchar(500) = null,
	@JUSTIFICATION nvarchar(500) = null,
	@Last_Meeting date = null,
	@Next_Meeting date = null,
	@Dev_Start date = null,
	@CIA_Risk nvarchar(50) = null,
	@CMMI nvarchar(50) = null,
	@TD_StatusID int = null,
	@CD_StatusID int = null,
	@C_StatusID int = null,
	@IT_StatusID int = null,
	@CVT_StatusID int = null,
	@A_StatusID int = null,
	@CR_StatusID int = null,
	@HasSlides int = null,
	@WorkStoppage int = null,
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
				--, Last_Meeting = @Last_Meeting
				--, Next_Meeting = @Next_Meeting
				--, Dev_Start = @Dev_Start
				--, CIA_Risk = @CIA_Risk
				--, CMMI = @CMMI
				, TD_STATUSID = @TD_StatusID
				, CD_StatusID = @CD_StatusID
				, C_STATUSID = @C_StatusID
				, IT_STATUSID = @IT_StatusID 
				, CVT_STATUSID = @CVT_StatusID
				, A_StatusID = @A_StatusID
				, CR_STATUSID = @CR_StatusID
				--, HasSlides = @HasSlides
				--, WorkStoppage = @WorkStoppage
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

