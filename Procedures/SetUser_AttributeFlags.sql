USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SetUser_AttributeFlags]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [SetUser_AttributeFlags]
GO

CREATE PROCEDURE [dbo].[SetUser_AttributeFlags]
	@WTS_RESOURCEID int,
	@AttributeFlags nvarchar(MAX) = '',
	@saved int output
AS
BEGIN
	SET @saved = 0;

	DELETE FROM WTS_Resource_Flag
	WHERE WTS_ResourceID = @WTS_RESOURCEID;

	IF (LEN(@AttributeFlags) > 0)
		BEGIN
			CREATE TABLE #FLAGS(
				AttributeID NVARCHAR(10)
			);
			INSERT INTO #FLAGS (AttributeID)
			SELECT Data FROM dbo.split(@AttributeFlags,',');

			--insert user attributeid
			INSERT INTO WTS_Resource_Flag(WTS_ResourceID, AttributeID, Checked)
				SELECT @WTS_RESOURCEID, a.AttributeID, 1
				FROM
					(SELECT DISTINCT a.AttributeID
						FROM 
							Attribute a
								JOIN #FLAGS f ON CONVERT(nvarchar(10), a.AttributeID) = f.AttributeID
						WHERE
							a.AttributeTypeId = 1 --resource
						) a;

			DROP TABLE #FLAGS;

			SET @saved = 1;
		END;

END;

GO
