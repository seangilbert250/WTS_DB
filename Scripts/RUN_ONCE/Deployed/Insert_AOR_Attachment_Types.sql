use [WTS]
go

insert into AORAttachmentType(AORAttachmentTypeName, [Description])
select a.AORAttachmentTypeName, a.[Description] from (
	select 'Approved Technical Design Slides' as AORAttachmentTypeName, 'Approved Technical Design Slides' as [Description]
	union all
	select 'Approved Customer Design Slides' as AORAttachmentTypeName, 'Approved Customer Design Slides' as [Description]
	union all
	select 'Approved Data Model' as AORAttachmentTypeName, 'Approved Data Model' as [Description]
	union all
	select 'Approved Developer Meeting Minutes' as AORAttachmentTypeName, 'Approved Developer Meeting Minutes' as [Description]
) a;