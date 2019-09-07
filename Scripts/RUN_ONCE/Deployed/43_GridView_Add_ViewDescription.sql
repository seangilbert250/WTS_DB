USE WTS
GO

ALTER TABLE GridView
ADD [ViewDescription] NVARCHAR(500) NULL;

GO

UPDATE GridView
SET ViewDescription = 'View includes all data.'
WHERE GridNameID = 9
AND WTS_RESOURCEID IS NULL
AND UPPER(ViewName) = 'ENTERPRISE';

UPDATE GridView
SET ViewDescription = 'View includes data which you are selected as Assigned To or Primary Resource as well as data which you are a resource of the AOR or System.'
WHERE GridNameID = 9
AND WTS_RESOURCEID IS NULL
AND UPPER(ViewName) = 'MY DATA';

GO
