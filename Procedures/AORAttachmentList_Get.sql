USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORAttachmentList_Get]    Script Date: 4/18/2018 8:53:53 AM ******/
DROP PROCEDURE [dbo].[AORAttachmentList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORAttachmentList_Get]    Script Date: 4/18/2018 8:53:53 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORAttachmentList_Get]
	@AORID int = 0,
	@AORReleaseID int = 0,
	@AORAttachmentTypeID int = 0
as
begin
	select AOR.AORID as AOR_ID,
		arl.AORName as [AOR Name],
		arl.AORReleaseID as AORRelease_ID,
		art.AORReleaseAttachmentID as AORReleaseAttachment_ID,
		aat.AORAttachmentTypeID as AORAttachmentType_ID,
		aat.AORAttachmentTypeName as [Type],
		art.AORReleaseAttachmentName as [Attachment Name],
		art.[Description],
		art.[FileName] as [File],
		art.InvestigationStatusID as [INV],
		art.TechnicalStatusID as [TD],
		art.CustomerDesignStatusID as [CD],
		art.CodingStatusID as [C],
		art.InternalTestingStatusID as [IT],
		art.CustomerValidationTestingStatusID as [CVT],
		art.AdoptionStatusID as [ADOPT],	
		convert(int, art.Approved) as Approved,
		art.ApprovedByID,
		wre.USERNAME,
		art.ApprovedDate,
		art.CreatedBy as [Added By],
		art.CreatedDate as [Added Date],
		art.UpdatedBy as [Updated By],
		art.UpdatedDate as [Updated Date]
	from AOR
	join AORRelease arl
	on AOR.AORID = arl.AORID
	join AORReleaseAttachment art
	on arl.AORReleaseID = art.AORReleaseID
	join AORAttachmentType aat
	on art.AORAttachmentTypeID = aat.AORAttachmentTypeID
	left join WTS_RESOURCE wre
	on art.ApprovedByID = wre.WTS_RESOURCEID
	where (@AORID = 0 or AOR.AORID = @AORID)
	and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
	and (isnull(@AORAttachmentTypeID, 0) = 0 or aat.AORAttachmentTypeID = @AORAttachmentTypeID)
	order by upper(arl.AORName), upper(aat.AORAttachmentTypeName), upper(art.AORReleaseAttachmentName);
end;
GO


