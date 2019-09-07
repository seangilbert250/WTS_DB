use [WTS]
go

ALTER TABLE Narrative_CONTRACT
    ADD ProductVersionID int not null DEFAULT 40
go

ALTER TABLE Narrative_CONTRACT
    ADD FOREIGN KEY (ProductVersionID) REFERENCES ProductVersion(ProductVersionID);
go

ALTER TABLE Narrative_CONTRACT
    ALTER COLUMN ReleaseProductionStatusID int NULL
go

ALTER TABLE Narrative_CONTRACT
    DROP CONSTRAINT UK_Narrative_CONTRACT
go

ALTER TABLE Narrative_CONTRACT
    ADD CONSTRAINT UK_Narrative_CONTRACT UNIQUE (NarrativeID, ProductVersionID, CONTRACTID)
go

ALTER TABLE Narrative
    DROP CONSTRAINT UK_Narrative
go