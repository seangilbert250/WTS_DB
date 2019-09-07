USE WTS
GO

DELETE FROM [HardwareType]
GO

SET IDENTITY_INSERT [HardwareType] ON
GO

INSERT INTO [HardwareType](HardwareTypeID, HardwareType, [Description])
SELECT 1, 'ITI Laptop', 'ITI Owned Laptop computer' UNION ALL
SELECT 2, 'ITI Desktop', 'ITI Owned Desktop computer' UNION ALL
SELECT 3, 'GFE', 'Government Owned computer' 
EXCEPT
SELECT HardwareTypeID, HardwareType, [Description] FROM HardwareType
GO

SET IDENTITY_INSERT [HardwareType] OFF
GO