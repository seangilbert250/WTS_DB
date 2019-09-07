use [WTS]
go
IF dbo.ColumnExists('dbo','Narrative_CONTRACT','ImageID') = 0
BEGIN
ALTER TABLE Narrative_CONTRACT
    ADD ImageID int null

ALTER TABLE Narrative_CONTRACT
    ADD FOREIGN KEY (ImageID) REFERENCES Image(ImageID);

END
GO

