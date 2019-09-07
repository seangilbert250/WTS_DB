USE WTS
GO

DELETE FROM [Attribute]
GO

INSERT INTO [Attribute](AttributeTypeId, [Attribute], [Description])
SELECT (SELECT AttributeTypeId FROM AttributeTYPE WHERE AttributeTYPE = 'Resource'), 'CAC', 'CAC has been acquired and is valid' UNION ALL
SELECT (SELECT AttributeTypeId FROM AttributeTYPE WHERE AttributeTYPE = 'Resource'), 'CAFDEx Admin', 'Admin account is active' UNION ALL
SELECT (SELECT AttributeTypeId FROM AttributeTYPE WHERE AttributeTYPE = 'Resource'), 'VPN/Network', 'VPN/Network account is active' UNION ALL
SELECT (SELECT AttributeTypeId FROM AttributeTYPE WHERE AttributeTYPE = 'Resource'), 'CAFDEx', 'CAFDEx account is active' UNION ALL
SELECT (SELECT AttributeTypeId FROM AttributeTYPE WHERE AttributeTYPE = 'Resource'), 'eMass', 'eMass' UNION ALL
SELECT (SELECT AttributeTypeId FROM AttributeTYPE WHERE AttributeTYPE = 'Resource'), 'EITDR', 'EITDR' UNION ALL
SELECT (SELECT AttributeTypeId FROM AttributeTYPE WHERE AttributeTYPE = 'Resource'), 'ACART', 'ACART' UNION ALL
SELECT (SELECT AttributeTypeId FROM AttributeTYPE WHERE AttributeTYPE = 'Resource'), 'ISMT', 'ISMT' UNION ALL
SELECT (SELECT AttributeTypeId FROM AttributeTYPE WHERE AttributeTYPE = 'Resource'), 'GCSS-AF', 'GCSS-AF' UNION ALL
SELECT (SELECT AttributeTypeId FROM AttributeTYPE WHERE AttributeTYPE = 'Resource'), 'CDRS', 'CDRS' UNION ALL
SELECT (SELECT AttributeTypeId FROM AttributeTYPE WHERE AttributeTYPE = 'Resource'), 'CRIS', 'CRIS'
EXCEPT
SELECT AttributeTypeId, [Attribute], [Description] FROM Attribute
GO
