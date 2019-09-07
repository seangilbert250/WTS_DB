use [WTS]
go

UPDATE STATUS
SET
    STATUS = 'Ready for Review',
    [Description] = 'Ready for Review'
WHERE
    StatusTypeID = 16
    and STATUS = 'Reviewed'