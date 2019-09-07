USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[LOGMESSAGELIST_GET]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [LOGMESSAGELIST_GET]

GO

CREATE PROCEDURE [dbo].[LOGMESSAGELIST_GET]
	@Log_TypeID int = 0
AS
BEGIN
	SELECT 
		l.LOGID, 
		l.LOG_TYPEID,
		lt.LOG_TYPE,
		l.ParentMessageId,
		l.Username,
		l.MessageDate,
		l.ExceptionType,
		l.[Message],
		l.StackTrace,
		l.MessageSource,
		l.AppVersion,
		l.Url,
		l.AdditionalInfo,
		l.MachineName,
		l.ProcessName,
		l.[CreatedBy],
		l.[CreatedDate]
	FROM
		LOG l
			LEFT OUTER JOIN LOG_TYPE lt ON lt.LOG_TYPEID = l.LOG_TYPEID
	WHERE
		ISNULL(@Log_TypeID,0) = 0
		OR l.LOG_TYPEID = @Log_TypeID;

END;

GO
