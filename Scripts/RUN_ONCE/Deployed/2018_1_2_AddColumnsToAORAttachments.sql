IF dbo.ColumnExists('dbo', 'AORReleaseAttachment', 'TechnicalStatusID') = 0
BEGIN
	ALTER TABLE dbo.AORReleaseAttachment 
	ADD
		InvestigationStatusID INT NULL,
		TechnicalStatusID INT NULL,
		CustomerDesignStatusID INT NULL,
		CodingStatusID INT NULL,
		InternalTestingStatusID INT NULL,
		CustomerValidationTestingStatusID INT NULL,
		AdoptionStatusID INT NULL	
		
	ALTER TABLE dbo.AORReleaseAttachment ADD CONSTRAINT FK_AORReleaseAttachment_InvestigationStatus FOREIGN KEY(InvestigationStatusID)
	REFERENCES dbo.STATUS (STATUSID)
	
	ALTER TABLE dbo.AORReleaseAttachment ADD CONSTRAINT FK_AORReleaseAttachment_TechnicalStatus FOREIGN KEY(TechnicalStatusID)
	REFERENCES dbo.STATUS (STATUSID)
	
	ALTER TABLE dbo.AORReleaseAttachment ADD CONSTRAINT FK_AORReleaseAttachment_CustomerDesignStatus FOREIGN KEY(CustomerDesignStatusID)
	REFERENCES dbo.STATUS (STATUSID)
	
	ALTER TABLE dbo.AORReleaseAttachment ADD CONSTRAINT FK_AORReleaseAttachment_CodingStatus FOREIGN KEY(CodingStatusID)
	REFERENCES dbo.STATUS (STATUSID)
	
	ALTER TABLE dbo.AORReleaseAttachment ADD CONSTRAINT FK_AORReleaseAttachment_InternalTestingStatus FOREIGN KEY(InternalTestingStatusID)
	REFERENCES dbo.STATUS (STATUSID)
	
	ALTER TABLE dbo.AORReleaseAttachment ADD CONSTRAINT FK_AORReleaseAttachment_CustomerValidationTestingStatus FOREIGN KEY(CustomerValidationTestingStatusID)
	REFERENCES dbo.STATUS (STATUSID)
	
	ALTER TABLE dbo.AORReleaseAttachment ADD CONSTRAINT FK_AORReleaseAttachment_AdoptionStatus FOREIGN KEY(AdoptionStatusID)
	REFERENCES dbo.STATUS (STATUSID)								
			
END