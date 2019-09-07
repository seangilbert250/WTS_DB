USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AORRelease_History_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AORRelease_History_Get]

GO

CREATE PROCEDURE [dbo].[AORRelease_History_Get]
	@AORReleaseID nvarchar(255) = ''
	, @ITEM_UPDATETYPE nvarchar(255) = ''
	, @FieldChanged nvarchar(255) = ''
	, @CREATEDBY nvarchar(255) = ''
AS
BEGIN
	SELECT
		a.AORRelease_HistoryID
		, a.AORReleaseID
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
		AORRelease_History a
	JOIN ITEM_UPDATETYPE b ON a.ITEM_UPDATETYPEID = b.ITEM_UPDATETYPEID
	WHERE
		(ISNULL(@AORReleaseID,'') = '' OR CHARINDEX(',' + convert(nvarchar(10), a.AORReleaseID) + ',', ',' + @AORReleaseID + ',') > 0)
		AND (ISNULL(@ITEM_UPDATETYPE,'') = '' OR CHARINDEX(',' + UPPER(b.ITEM_UPDATETYPE) + ',', ',' + UPPER(@ITEM_UPDATETYPE) + ',') > 0)
		AND (ISNULL(@FieldChanged,'') = '' OR CHARINDEX(',' + UPPER(a.FieldChanged) + ',', ',' + UPPER(@FieldChanged) + ',') > 0)
		AND (ISNULL(@CREATEDBY,'') = '' OR CHARINDEX(',' + UPPER(a.CREATEDBY) + ',', ',' + UPPER(@CREATEDBY) + ',') > 0)
	ORDER BY
		a.UPDATEDDATE DESC
	;

END;

GO