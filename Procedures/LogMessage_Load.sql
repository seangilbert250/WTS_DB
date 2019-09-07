USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[LogMessage_Load]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [LogMessage_Load]

GO

CREATE PROCEDURE [dbo].[LogMessage_Load]
	@Log_MessageId int
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
		Log l
			LEFT OUTER JOIN LOG_TYPE lt ON lt.LOG_TYPEID = l.LOG_TYPEID
	WHERE
		l.LOGID = @Log_MessageId;

END