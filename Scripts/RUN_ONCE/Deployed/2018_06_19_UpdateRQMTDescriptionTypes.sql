IF NOT EXISTS (SELECT 1 FROM RQMTDescriptionType WHERE RQMTDescriptionType='Description Type 1')
BEGIN
	INSERT INTO RQMTDescriptionType VALUES ('Description Type 1', null, 0, 0, 'System.Administrator', GETDATE(), 'System.Administrator', GETDATE())
	INSERT INTO RQMTDescriptionType VALUES ('Description Type 2', null, 0, 0, 'System.Administrator', GETDATE(), 'System.Administrator', GETDATE())
	INSERT INTO RQMTDescriptionType VALUES ('Description Type 3', null, 0, 0, 'System.Administrator', GETDATE(), 'System.Administrator', GETDATE())

	UPDATE RQMTDescription SET RQMTDescriptionTypeID = (SELECT RQMTDescriptionTypeID FROM RQMTDescriptionType WHERE RQMTDescriptionType='Description Type 1')
END