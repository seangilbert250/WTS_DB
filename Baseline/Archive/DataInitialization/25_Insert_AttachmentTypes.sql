USE WTS
GO

DELETE FROM [AttachmentType]
GO

SET IDENTITY_INSERT [AttachmentType] ON
GO

INSERT INTO [AttachmentType](AttachmentTypeId, AttachmentType, [Description], Sort_Order)
SELECT 1, 'GRAPHICS', 'GRAPHICS', 1 UNION ALL
SELECT 2, 'SUPPLEMENTAL DOCUMENT', 'SUPPLEMENTAL DOCUMENT', 2 UNION ALL
SELECT 3, 'CVT', 'CVT DOCUMENT', 3
EXCEPT
SELECT AttachmentTypeId, AttachmentType, [Description], Sort_Order FROM AttachmentType
GO

SET IDENTITY_INSERT [AttachmentType] OFF
GO
