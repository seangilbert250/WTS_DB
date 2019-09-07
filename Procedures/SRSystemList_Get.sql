USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[SRSystemList_Get]    Script Date: 4/19/2018 9:19:34 AM ******/
DROP PROCEDURE [dbo].[SRSystemList_Get]
GO

/****** Object:  StoredProcedure [dbo].[SRSystemList_Get]    Script Date: 4/19/2018 9:19:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[SRSystemList_Get]
	@SRID int = 0,
	@StatusID int = 0,
	@SRTypeID int = 0
as
begin
select distinct 
			ROW_NUMBER() OVER (ORDER BY [System]) as SRSystemID,
			[System] as SRSystem
	from
	(
		select distinct
			'WTS' AS System
		from SR
		join WTS_RESOURCE wre
		on SR.SubmittedByID = wre.WTS_RESOURCEID
		join [STATUS] s
		on SR.STATUSID = s.STATUSID
		join SRType srt
		on SR.SRTypeID = srt.SRTypeID
		where SR.Archive = 0
		and (isnull(@SRID, 0) = 0 or SR.SRID = @SRID)
		and (isnull(@StatusID, 0) = 0 or s.STATUSID = @StatusID)
		and (isnull(@SRTypeID, 0) = 0 or srt.SRTypeID = @SRTypeID)

		UNION ALL

		select distinct
			AORSR.Websystem as [System]
		from AORSR
		left join WTS_RESOURCE wre
		on AORSR.CreatedBy = wre.USERNAME
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
		and (isnull(@SRID, 0) = 0 or AORSR.SRID = @SRID)
		and (isnull(@StatusID, 0) = 0 or s.STATUSID = @StatusID)
		and (isnull(@SRTypeID, 0) = 0 or srt.SRTypeID = @SRTypeID)
	) a
end;

