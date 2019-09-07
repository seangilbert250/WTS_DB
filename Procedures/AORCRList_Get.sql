USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORCRList_Get]    Script Date: 10/5/2017 3:58:12 PM ******/
DROP PROCEDURE [dbo].[AORCRList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORCRList_Get]    Script Date: 10/5/2017 3:58:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORCRList_Get]
	@AORID int = 0,
	@AORReleaseID int = 0,
	@CRID int = 0
as
begin
	if (@AORID = 0 and @AORReleaseID = 0 and @CRID != 0)
		begin
			select AOR.AORID as [AOR #],
				arl.AORName as [AOR Name],
				arl.[Description],
				arl.AORReleaseID as AORRelease_ID,
				pv.ProductVersionID as ProductVersion_ID,
				pv.ProductVersion as Release,
				arc.AORReleaseCRID as AORReleaseCR_ID,
				null as Z
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			left join ProductVersion pv
			on arl.ProductVersionID = pv.ProductVersionID
			join AORReleaseCR arc
			on arl.AORReleaseID = arc.AORReleaseID
			where arc.CRID = @CRID
			and AOR.Archive = 0
			order by upper(pv.ProductVersion), upper(arl.AORName);
		end;
	else
		begin
			select AOR.AORID as AOR_ID,
				arl.AORName as [AOR Name],
				arc.AORReleaseCRID as AORReleaseCR_ID,
				acr.CRID as CR_ID,
				acr.CRName as [CR Customer Title],
				acr.Title as [CR Internal Title],
				acr.Notes as Notes,
				acr.Websystem as [Websystem],
				acr.Websystem as [Websystem_ID],
				case when acr.CSDRequiredNow = 1 then 'Yes' else 'No' end as [CSD Required Now],
				acr.RelatedRelease as [Related Release],
				acr.Subgroup,
				acr.DesignReview as [Design Review],
				lower(acr.ITIPOC) as [ITI POC],
				acr.CustomerPriorityList as [Customer Priority List],
				acr.GovernmentCSRD as [Government CSRD #],
				crc.[Contract],
				crc.[CONTRACTID] as [Contract_ID],
				acr.[CyberISMT],
				crs.[StatusID] as [Status_ID],
				crs.[Status]
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			join AORReleaseCR arc
			on arl.AORReleaseID = arc.AORReleaseID
			join AORCR acr
			on arc.CRID = acr.CRID
			left join [Contract] crc
			on acr.[CONTRACTID] = crc.[CONTRACTID]
			left join [Status] crs
			on acr.[StatusID] = crs.[StatusID]
			where (@AORID = 0 or AOR.AORID = @AORID)
			and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
			order by arl.AORName, upper(acr.CRName);
		end;
end;

GO

