use wts
go


UPDATE [GridView]
SET
	[Archive] = 1
WHERE [GridViewID] = 2;

UPDATE [UserSetting]
SET
	[SettingValue] = 3
WHERE [SettingValue] = 2;