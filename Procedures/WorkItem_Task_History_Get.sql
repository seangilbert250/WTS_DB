USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkItem_Task_History_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkItem_Task_History_Get]

GO

CREATE PROCEDURE [dbo].[WorkItem_Task_History_Get]
	@WORKITEM_TASKID nvarchar(255) = ''
	, @ITEM_UPDATETYPE nvarchar(255) = ''
	, @FieldChanged nvarchar(255) = ''
	, @CREATEDBY nvarchar(255) = ''
AS
BEGIN
	SELECT
		a.WORKITEM_TASK_HISTORYID
		, a.WORKITEM_TASKID
		, a.ITEM_UPDATETYPEID
		, b.ITEM_UPDATETYPE
		, a.FieldChanged
		, a.OldValue
		, a.NewValue
		, a.CREATEDBY
		, a.CREATEDDATE
		, a.UPDATEDBY
		, a.UPDATEDDATE
	FROM
		WORKITEM_TASK_HISTORY a
	JOIN ITEM_UPDATETYPE b ON a.ITEM_UPDATETYPEID = b.ITEM_UPDATETYPEID
	WHERE
		(ISNULL(@WORKITEM_TASKID,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), a.WORKITEM_TASKID) + ',', ',' + @WORKITEM_TASKID + ',') > 0)
		AND (ISNULL(@ITEM_UPDATETYPE,'') = '' OR CHARINDEX(',' + UPPER(b.ITEM_UPDATETYPE) + ',', ',' + UPPER(@ITEM_UPDATETYPE) + ',') > 0)
		AND (ISNULL(@FieldChanged,'') = '' OR CHARINDEX(',' + UPPER(a.FieldChanged) + ',', ',' + UPPER(@FieldChanged) + ',') > 0)
		AND (ISNULL(@CREATEDBY,'') = '' OR CHARINDEX(',' + UPPER(a.CREATEDBY) + ',', ',' + UPPER(@CREATEDBY) + ',') > 0)
	ORDER BY
		a.UPDATEDDATE DESC
	;

END;

GO