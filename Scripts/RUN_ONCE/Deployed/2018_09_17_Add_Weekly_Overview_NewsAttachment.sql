use [WTS]
go

declare @date datetime = getdate();

insert into AttachmentType (AttachmentType, [Description], Sort_Order, Archive, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE, ShowInLists)
values ('WEEKLY OVERVIEW', 'WEEKLY OVERVIEW', 5, 0, 'WTS', @date, 'WTS', @date, 0);

alter table News add primary key (NewsID)
go

IF dbo.TableExists('dbo', 'NewsAttachment') = 0
BEGIN
	CREATE TABLE dbo.NewsAttachment
	(
		NewsAttachmentID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
		NewsID INT NOT NULL,
		AttachmentID INT NOT NULL
	)

	CREATE NONCLUSTERED INDEX [IDX_NewsAttachment_News] ON [dbo].NewsAttachment(NewsID ASC)
	CREATE NONCLUSTERED INDEX [IDX_NewsAttachment_Attachment] ON [dbo].NewsAttachment(AttachmentID ASC)

	ALTER TABLE [dbo].NewsAttachment  WITH CHECK ADD CONSTRAINT [FK_NewsAttachment_News] FOREIGN KEY(NewsID) REFERENCES dbo.News(NewsID)
	ALTER TABLE [dbo].NewsAttachment  WITH CHECK ADD CONSTRAINT [FK_NewsAttachment_Attachment] FOREIGN KEY(AttachmentID) REFERENCES dbo.Attachment(AttachmentID)
END
go

