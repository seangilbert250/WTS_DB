USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[StatusTypeList_Get]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [StatusTypeList_Get]

GO

CREATE PROCEDURE [dbo].[StatusTypeList_Get]
	@IncludeArchive bit = 0
AS
BEGIN
	SELECT
		st.StatusTypeID
		, st.StatusType + ' - ' + st.[DESCRIPTION] AS StatusType
	FROM
		StatusType st
	WHERE
		(ISNULL(@IncludeArchive,1) = 1 OR st.Archive = @IncludeArchive)
	ORDER BY
		Sort_Order, StatusType
	;

END;

GO
