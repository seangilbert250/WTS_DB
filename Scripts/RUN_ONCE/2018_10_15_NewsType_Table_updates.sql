use [WTS]
go

Update AttachmentType set AttachmentType = 'NEWS' ,
Description = 'NEWS'
where AttachmentTypeId = 5

delete AttachmentType where AttachmentTypeId = 6


GO


update news set NewsTypeID = 2 where NewsTypeID = 3
update news set NewsTypeID = 3 where NewsTypeID = 2

GO



