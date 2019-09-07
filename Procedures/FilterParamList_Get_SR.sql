USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[FilterParamList_Get_SR]    Script Date: 4/24/2018 9:15:13 AM ******/
DROP PROCEDURE [dbo].[FilterParamList_Get_SR]
GO

/****** Object:  StoredProcedure [dbo].[FilterParamList_Get_SR]    Script Date: 4/24/2018 9:15:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[FilterParamList_Get_SR]
	@SessionID nvarchar(100)
	, @UserName nvarchar(100)
	, @FilterName nvarchar(255)
	, @FilterTypeID int = 1
	, @OwnedBy int = null
	, @SubmittedBy nvarchar(255) = null
	, @Status nvarchar(255) = null
	, @Reasoning nvarchar(255) = null
	, @System nvarchar(255) = null
AS
BEGIN 
	SELECT DISTINCT * FROM 
	(

		SELECT FilterID, FilterValue FROM
		(
			SELECT DISTINCT 
				CASE @FilterName
					WHEN 'Submitted By' THEN DENSE_RANK() OVER (ORDER BY wre.USERNAME)
					WHEN 'Status' THEN s.STATUSID
					WHEN 'Reasoning' THEN srt.SRTypeID
					WHEN 'System' THEN 1
				END AS FilterID
				, CASE @FilterName
					WHEN 'Submitted By' THEN wre.USERNAME
					WHEN 'Status' THEN s.[STATUS]
					WHEN 'Reasoning' THEN srt.SRType
					WHEN 'System' THEN 'WTS'
				END AS FilterValue
			from SR
			join WTS_RESOURCE wre
			on SR.SubmittedByID = wre.WTS_RESOURCEID
			join [STATUS] s
			on SR.STATUSID = s.STATUSID
			join SRType srt
			on SR.SRTypeID = srt.SRTypeID
			where (isnull(@SubmittedBy, '') = '' or wre.USERNAME = @SubmittedBy)
			and (isnull(@Status, '') = '' or charindex(',' + convert(nvarchar(10), isnull(s.STATUSID, 0)) + ',', ',' + @Status + ',') > 0)
			and (isnull(@Reasoning, '') = '' or charindex(',' + convert(nvarchar(10), srt.SRTypeID) + ',', ',' + @Reasoning + ',') > 0)
			and (isnull(@System, '') = '' or 'WTS' = @System)
		) t
	 UNION ALL

	 SELECT FilterID, FilterValue FROM
		(
			SELECT DISTINCT 
				CASE @FilterName
					WHEN 'Submitted By' THEN DENSE_RANK() OVER (ORDER BY AORSR.SubmittedBy)
					WHEN 'Status' THEN s.STATUSID
					WHEN 'Reasoning' THEN srt.SRTypeID
					WHEN 'System' THEN DENSE_RANK() OVER (ORDER BY AORSR.Websystem)
				END AS FilterID
				, CASE @FilterName
					WHEN 'Submitted By' THEN AORSR.SubmittedBy
					WHEN 'Status' THEN s.[STATUS]
					WHEN 'Reasoning' THEN srt.SRType
					WHEN 'System' THEN AORSR.Websystem
				END AS FilterValue
			from AORSR
			left join WTS_RESOURCE wre
			on AORSR.SubmittedBy = wre.USERNAME
			join [STATUS] s
			on AORSR.[STATUS] = s.[STATUS]
			join SRType srt
			on AORSR.SRType = srt.SRType
			join [PRIORITY] p
			on AORSR.[PRIORITY] = p.[PRIORITY]
			where AORSR.Archive = 0
			and (AORSR.Websystem LIKE '%CAFDEx/WSS%' or AORSR.Websystem LIKE '%CAFDEx/FHP%')
			and s.StatusTypeID = 16
			and p.PRIORITYTYPEID = 6
			and (isnull(@SubmittedBy, '') = '' or AORSR.SubmittedBy = @SubmittedBy)
			and (isnull(@Status, '') = '' or charindex(',' + convert(nvarchar(10), isnull(s.STATUSID, 0)) + ',', ',' + @Status + ',') > 0)
			and (isnull(@Reasoning, '') = '' or charindex(',' + convert(nvarchar(10), srt.SRTypeID) + ',', ',' + @Reasoning + ',') > 0)
			and (isnull(@System, '') = '' or AORSR.Websystem = @System)
		) t
	) a
	ORDER BY a.FilterValue
END;
GO

