use [WTS]
go

UPDATE AORAttachmentType
SET
    AORAttachmentTypeName = 'Technical Design Slides',
    [Description] = 'Technical Design Slides',
    Sort = 2
WHERE
    AORAttachmentTypeName = 'Approved Technical Design Slides'

UPDATE AORAttachmentType
SET
    AORAttachmentTypeName = 'Customer Design Slides',
    [Description] = 'Customer Design Slides',
    Sort = 3
WHERE
    AORAttachmentTypeName = 'Approved Customer Design Slides'

UPDATE AORAttachmentType
SET
    AORAttachmentTypeName = 'Data Model',
    [Description] = 'Data Model',
    Sort = 4
WHERE
    AORAttachmentTypeName = 'Approved Data Model'

UPDATE AORAttachmentType
SET
    AORAttachmentTypeName = 'Developer Meeting Minutes',
    [Description] = 'Developer Meeting Minutes',
    Sort = 5
WHERE
    AORAttachmentTypeName = 'Approved Developer Meeting Minutes'

UPDATE AORAttachmentType
SET
    AORAttachmentTypeName = 'DAR',
    [Description] = 'DAR',
    Sort = 1
WHERE
    AORAttachmentTypeName = 'Approved DAR'

UPDATE AORAttachmentType
SET
    Sort = 6
WHERE
    AORAttachmentTypeName = 'CVTs'

UPDATE AORAttachmentType
SET
    Sort = 7
WHERE
    AORAttachmentTypeName = 'Other'