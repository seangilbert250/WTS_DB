USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORStageList_Get]    Script Date: 2/14/2018 2:58:53 PM ******/
DROP PROCEDURE [dbo].[AORStageList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORStageList_Get]    Script Date: 2/14/2018 2:58:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[AORStageList_Get]
	@StageID int = 0
as
begin
	begin
		select AOR.AORID as [AOR #],
			AOR.AORName as [AOR Name],
			AOR.[Description],
			arl.AORReleaseID as AORRelease_ID,
			pv.ProductVersionID as ProductVersion_ID,
			pv.ProductVersion as Release,
			ars.AORReleaseStageID as AORReleaseStage_ID,
			null as Z
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		left join ProductVersion pv
		on arl.ProductVersionID = pv.ProductVersionID
		join AORReleaseStage ars
		on arl.AORReleaseID = ars.AORReleaseID
		where ars.StageID = @StageID
		and AOR.Archive = 0
		order by upper(pv.ProductVersion), upper(AOR.AORName);
	end;
end;

GO


