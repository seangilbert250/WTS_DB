USE WTS
GO

SET IDENTITY_INSERT dbo.FilterType ON;
GO

IF NOT EXISTS (SELECT 1 FROM FilterType WHERE FilterType = 'RQMT')
BEGIN
	INSERT INTO FilterType (FilterTypeID, FilterType)  VALUES (5, 'RQMT')
END

SET IDENTITY_INSERT dbo.FilterType OFF;
GO