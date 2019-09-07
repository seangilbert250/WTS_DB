USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkRequest_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkRequest_Add]

GO
USE [WTS]
GO
/****** Object:  StoredProcedure [dbo].[WorkRequest_Add]    Script Date: 6/9/2016 8:39:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[WorkRequest_Add]
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
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @newID = 0;

	INSERT INTO WORKREQUEST(
		REQUESTTYPEID
		, RequestGroupID
		, CONTRACTID
		, ORGANIZATIONID
		, WTS_SCOPEID
		, EFFORTID
		, SMEID
		, LEAD_IA_TWID
		, LEAD_RESOURCEID
		, OP_PRIORITYID
		, TITLE
		, [DESCRIPTION]
		, JUSTIFICATION
		, ARCHIVE
		, SUBMITTEDBY
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@REQUESTTYPEID
		, @RequestGroupID
		, @CONTRACTID
		, @ORGANIZATIONID
		, @WTS_SCOPEID
		, @EFFORTID
		, @SMEID
		, @LEAD_IA_TWID
		, @LEAD_RESOURCEID
		, @OP_PRIORITYID
		, @TITLE
		, @DESCRIPTION
		, @JUSTIFICATION
		, @ARCHIVE
		, @SUBMITTEDBY
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);

	SELECT @newID = SCOPE_IDENTITY();
END;

