USE WTS
GO

DELETE FROM [ITEM_UPDATETYPE]
GO

INSERT INTO [ITEM_UPDATETYPE](ITEM_UPDATETYPE, [DESCRIPTION], SORT_ORDER)
SELECT 'Add', 'Item was created', 1 UNION ALL
SELECT 'Update', 'Item attribute(s) were updated', 2 UNION ALL
SELECT 'Comment', 'Comment was added to item', 3 UNION ALL
SELECT 'Attachment', 'Attachment added or removed from item', 4 UNION ALL
SELECT 'Email', 'Email sent for item', 5
EXCEPT
SELECT ITEM_UPDATETYPE, [DESCRIPTION], SORT_ORDER FROM ITEM_UPDATETYPE
GO
