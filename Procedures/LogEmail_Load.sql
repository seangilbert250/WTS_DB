IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[LogEmail_Load]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [LogEmail_Load]

GO

CREATE PROCEDURE [dbo].[LogEmail_Load]
	@Log_EmailId int
AS
BEGIN
	-- SET NOCOUNT ON Loaded to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
		l.LOG_EMAILID, 
		l.STATUSID,
		st.[Status],
		l.Sender,
		l.ToAddresses,
		l.CcAddresses,
		l.BccAddresses,
		l.[Subject],
		l.Body,
		l.SentDate,
		l.Procedure_Used,
		l.ErrorMessage,
		l.[CreatedBy],
		l.[CreatedDate],
		l.[UpdatedBy],
		l.[UpdatedDate]
	FROM
		Log_Email l
			LEFT OUTER JOIN Email_Status_Type st ON st.EMAIL_STATUS_TYPEID = l.StatusId
	WHERE
		l.LOG_EMAILID = @Log_EmailId;

END