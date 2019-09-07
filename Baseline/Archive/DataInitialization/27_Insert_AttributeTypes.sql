USE WTS
GO

DELETE FROM [AttributeType]
GO

SET IDENTITY_INSERT [AttributeType] ON
GO

INSERT INTO [AttributeType](AttributeTypeId, AttributeType, [Description])
SELECT 1, 'Resource', 'Attributes apply to Users'
EXCEPT
SELECT AttributeTypeId, AttributeType, [Description] FROM AttributeType
GO

SET IDENTITY_INSERT [AttributeType] OFF
GO
