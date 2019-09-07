USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[LOGEMAILMESSAGELIST_GET]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [LOGEMAILMESSAGELIST_GET]

GO

CREATE PROCEDURE [dbo].[LOGEMAILMESSAGELIST_GET]
	@StatusId int = 0
AS
BEGIN
	SELECT 
		l.[LOG_EMAILID], 
		l.STATUSID,
		st.[STATUS],
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
		LOG_EMAIL l
			LEFT OUTER JOIN EMAIL_STATUS_TYPE st ON st.EMAIL_STATUS_TYPEID = l.STATUSID
	WHERE
		ISNULL(@StatusId,0) = 0
		OR L.STATUSID = @StatusId;

END;

GO
