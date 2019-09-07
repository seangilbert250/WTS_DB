USE WTS
GO

DELETE FROM UserSettingType;

SET IDENTITY_INSERT UserSettingType ON
GO

INSERT INTO UserSettingType(UserSettingTypeID, UserSettingType, [Description])
SELECT 1 AS UserSettingTypeID, 'GridView' AS UserSettingType, 'Grid view option selection' AS [Description]

EXCEPT SELECT UserSettingTypeID, UserSettingType, [Description] FROM UserSettingType
;

GO

SET IDENTITY_INSERT UserSettingType OFF
GO