﻿USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Status_Phase_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Status_Phase_Add]

GO

CREATE PROCEDURE [dbo].[Status_Phase_Add]
	@PDDTDR_PhaseID int,
	@StatusID int,
	@Description nvarchar(500) = null,
	@Sort_Order int = null,
	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@exists bit output,
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	SET @exists = 0;
	SET @newID = 0;

	SELECT @exists = COUNT(*) FROM Status_Phase WHERE PDDTDR_PHASEID = @PDDTDR_PhaseID AND STATUSID = @StatusID;
	IF (ISNULL(@exists,0) > 0)
		BEGIN
			RETURN;
		END;

	INSERT INTO Status_Phase(
		PDDTDR_PHASEID
		, STATUSID
		, [DESCRIPTION]
		, SORT_ORDER
		, ARCHIVE
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@PDDTDR_PhaseID
		, @StatusID
		, @Description
		, @Sort_Order
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

GO
