USE WTS
GO

/****** Object:  StoredProcedure [dbo].[WTS_Resource_HardwareList_Get]    Script Date: 7/20/2015 1:02:37 PM ******/
DROP PROCEDURE [dbo].[WTS_Resource_HardwareList_Get]
GO

/****** Object:  StoredProcedure [dbo].[WTS_Resource_HardwareList_Get]    Script Date: 7/20/2015 1:02:37 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[WTS_Resource_HardwareList_Get]
	@WTS_RescourceID int
AS
BEGIN
	SELECT * FROM (
		SELECT
			0 AS WTS_Resource_HardwareID
			, @WTS_RescourceID AS WTS_ResourceID
			, 0 AS HardwareTypeID
			, '' AS HardwareType
			, '' AS DeviceName
			, '' AS DeviceSN_Tag
			, '' AS [Description]
			, 0 AS HasDevice
			, '' AS X
			, '' AS CREATEDBY
			, '' AS CREATEDDATE
			, '' AS UPDATEDBY
			, '' AS UPDATEDDATE
		UNION ALL

		SELECT
			wh.WTS_Resource_HardwareID
			, wh.WTS_RESOURCEID
			, ht.HardwareTypeID
			, ht.HardwareType
			, wh.DeviceName
			, wh.DeviceSN_Tag
			, wh.[Description]
			, ISNULL(wh.HasDevice,0) AS HasDevice
			, '' AS X
			, wh.CreatedBy
			, convert(varchar, wh.CREATEDDATE, 110) AS CREATEDDATE
			, wh.UPDATEDBY
			, convert(varchar, wh.UPDATEDDATE, 110) AS UPDATEDDATE
		FROM
			HardwareType ht
				LEFT JOIN WTS_Resource_Hardware wh ON ht.HardwareTypeID = wh.HardwareTypeID AND wh.WTS_ResourceID = @WTS_RescourceID
		WHERE
			ht.Archive = 0 OR ht.Archive IS NULL
	) h
	ORDER BY UPPER(h.HardwareType), UPPER(h.DeviceName), UPPER(h.DeviceSN_Tag);


END;

GO
