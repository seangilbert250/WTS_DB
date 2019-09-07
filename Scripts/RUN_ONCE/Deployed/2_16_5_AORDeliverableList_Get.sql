USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORDeliverableList_Get]    Script Date: 2/16/2018 3:38:46 PM ******/
DROP PROCEDURE [dbo].[AORDeliverableList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORDeliverableList_Get]    Script Date: 2/16/2018 3:38:46 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE procedure [dbo].[AORDeliverableList_Get]
	@DeliverableID int = 0
as
begin
	begin
		select AOR.AORID as [AOR #],
			AOR.AORName as [AOR Name],
			AOR.[Description],
			arl.AORReleaseID as AORRelease_ID,
			pv.ProductVersionID as ProductVersion_ID,
			pv.ProductVersion as Release,
			ars.AORReleaseDeliverableID as AORReleaseDeliverable_ID,
			null as Z
		from AOR
		join AORRelease arl
		on AOR.AORID = arl.AORID
		left join ProductVersion pv
		on arl.ProductVersionID = pv.ProductVersionID
		join AORReleaseDeliverable ars
		on arl.AORReleaseID = ars.AORReleaseID
		where ars.DeliverableID = @DeliverableID
		and AOR.Archive = 0
		order by upper(pv.ProductVersion), upper(AOR.AORName);
	end;
end;

GO


