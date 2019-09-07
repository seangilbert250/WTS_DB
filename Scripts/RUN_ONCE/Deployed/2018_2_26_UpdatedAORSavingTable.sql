USE [WTS]
GO

--UPDATE THE AOR TABLE TO BE MAX
ALTER TABLE dbo.AOR ADD temp VARCHAR(MAX) NULL; 

go

update dbo.AOR set temp = [Description];

ALTER TABLE dbo.AOR DROP COLUMN [Description]; 

EXEC sp_rename 'dbo.AOR.temp', 'Description', 'COLUMN';  

GO