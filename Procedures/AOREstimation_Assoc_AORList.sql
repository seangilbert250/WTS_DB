USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOREstimation_Assoc_AORList]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AOREstimation_Assoc_AORList]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AOREstimation_Assoc_AORList]
	@AOREstimation_AORReleaseID INT = 0,
	@IncludeArchive INT = 0
AS
BEGIN
	
	select null as X,
				AOR.AORID as [AOR #],
				arl.AORName as [AOR Name],
				arl.AORReleaseID as AORRelease_ID,
				pv.ProductVersionID as ProductVersion_ID,
				pv.ProductVersion as [Release],
				wsy.WTS_SYSTEMID as WTS_SYSTEM_ID,
				wsy.WTS_SYSTEM as [System]
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			left join ProductVersion pv
			on arl.ProductVersionID = pv.ProductVersionID
			left join AORReleaseSystem ars
			on arl.AORReleaseID = ars.AORReleaseID
			left join WTS_SYSTEM wsy
			on ars.WTS_SYSTEMID = wsy.WTS_SYSTEMID
			where AOR.Archive = 0
			and arl.[Current] = 1
			and not exists (
				select 1
				from AOREstimation_AORAssoc AEAA
				where AEAA.AORID = arl.AORID
				and AEAA.AOREstimation_AORReleaseID = @AOREstimation_AORReleaseID
			)
			order by upper(wsy.WTS_SYSTEM)/*, upper(pv.ProductVersion)*/, upper(arl.AORName);

END;

GO