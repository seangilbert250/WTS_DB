USE [WTS]
GO

IF NOT EXISTS (SELECT 1 FROM UserSettingType WHERE UserSettingType = 'RQMTQuickAddWarning')
BEGIN
	INSERT INTO [dbo].[UserSettingType] VALUES ('RQMTQuickAddWarning', 'Shows warning when user uses quick add to add RQMT to multiple sets', 0)
END

GO
