
IF dbo.ColumnExists('dbo', 'AORReleaseResource', 'AORRoleID') = 0
BEGIN

	ALTER TABLE dbo.AORReleaseResource ADD AORRoleID INT NULL

	ALTER TABLE dbo.AORReleaseResource  WITH CHECK ADD CONSTRAINT [FK_AORReleaseResource_Role] FOREIGN KEY(AORRoleID)
	REFERENCES [dbo].AORRole (AORRoleID)

END

GO