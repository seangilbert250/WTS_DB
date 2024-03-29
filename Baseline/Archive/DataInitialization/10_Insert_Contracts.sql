﻿USE WTS
GO

DELETE FROM [ContractType]
GO

SET IDENTITY_INSERT [ContractType] ON
GO

INSERT INTO [ContractType](ContractTypeID, ContractType, [Description])
SELECT 1, 'Fixed Rate', 'Fixed Rate' UNION ALL
SELECT 2, 'Time and Materials', 'Time and Materials' UNION ALL
SELECT 3, 'Other', 'Other undetermined contract types'
EXCEPT
SELECT ContractTypeID, ContractType, [Description] FROM ContractType
GO

SET IDENTITY_INSERT [ContractType] OFF
GO


DELETE FROM [CONTRACT]
GO

SET IDENTITY_INSERT [CONTRACT] ON
GO

INSERT INTO [CONTRACT](CONTRACTID, ContractTypeID, CONTRACT, [DESCRIPTION])
SELECT 1, 1, 'CAFDEx', 'CAFDEx contract' UNION ALL
SELECT 2, 1, 'ECT', 'ECT contract' UNION ALL
SELECT 3, 1, 'ACC/GIO NIPR', 'ACC/GIO NIPR contract' UNION ALL
SELECT 4, 1, 'ACC/GIO SIPR', 'ACC/GIO SIPR contract' UNION ALL
SELECT 5, 1, 'AMC/GIO', 'AMC/GIO contract' UNION ALL
SELECT 6, 1, 'CAS', 'CAS contract'
EXCEPT
SELECT CONTRACTID, ContractTypeID, CONTRACT, [DESCRIPTION] FROM CONTRACT
GO

SET IDENTITY_INSERT [CONTRACT] OFF
GO
