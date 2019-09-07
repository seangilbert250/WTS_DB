USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORResourceList_Get]    Script Date: 6/13/2018 2:35:40 PM ******/
DROP PROCEDURE [dbo].[AORResourceList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORResourceList_Get]    Script Date: 6/13/2018 2:35:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[AORResourceList_Get]
	@AORID int = 0,
	@AORReleaseID int = 0
as
begin

	DECLARE @ReleaseProductVersionID INT = (SELECT ProductVersionID FROM AORRelease WHERE AORReleaseID = @AORReleaseID)
	select * from (
	select AOR.AORID as AOR_ID,
		arl.AORName as [AOR Name],
		arl.ProductVersionID,
		res.WTS_RESOURCEID as WTS_RESOURCE_ID,
		res.USERNAME as [Resource],
		wrt.WTS_RESOURCE_TYPE as [Resource Type]
	from AOR
	join AORRelease arl
	on AOR.AORID = arl.AORID
	join AORReleaseTask art
	on arl.AORReleaseID = art.AORReleaseID
	join WORKITEM wi
	on art.WORKITEMID = wi.WORKITEMID
	join WTS_RESOURCE res
	on wi.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
	or wi.PrimaryBusinessResourceID = res.WTS_RESOURCEID
	join WTS_RESOURCE_TYPE wrt
	on res.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
	join WorkType_WTS_RESOURCE wtwr
	on wi.WorkTypeID = wtwr.WorkTypeID
	join WorkActivity_WTS_RESOURCE_TYPE wawrt
	on wrt.WTS_RESOURCE_TYPEID = wawrt.WTS_RESOURCE_TYPEID
	where (@AORID = 0 or AOR.AORID = @AORID)
	and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
	and wi.WORKITEMTYPEID = wawrt.WorkItemTypeID
	group by AOR.AORID, arl.AORName, res.WTS_RESOURCEID, res.USERNAME, wrt.WTS_RESOURCE_TYPE, arl.ProductVersionID, art.AORReleaseID

	union 

	select AOR.AORID as AOR_ID,
		arl.AORName as [AOR Name],
		arl.ProductVersionID,
		res.WTS_RESOURCEID as WTS_RESOURCE_ID,
		res.USERNAME as [Resource],
		wrt.WTS_RESOURCE_TYPE as [Resource Type]
	from AOR
	join AORRelease arl
	on AOR.AORID = arl.AORID
	join AORReleaseSubTask arst
	on arl.AORReleaseID = arst.AORReleaseID
	join WORKITEM_TASK wit
	on arst.WORKITEMTASKID = wit.WORKITEM_TASKID
	join WTS_RESOURCE res
	on wit.ASSIGNEDRESOURCEID = res.WTS_RESOURCEID
	or wit.PrimaryResourceID = res.WTS_RESOURCEID
	join WTS_RESOURCE_TYPE wrt
	on res.WTS_RESOURCE_TYPEID = wrt.WTS_RESOURCE_TYPEID
	join WorkActivity_WTS_RESOURCE_TYPE wawrt
	on wrt.WTS_RESOURCE_TYPEID = wawrt.WTS_RESOURCE_TYPEID
	where (@AORID = 0 or AOR.AORID = @AORID)
	and ((@AORReleaseID = 0 and arl.[Current] = 1) or arl.AORReleaseID = @AORReleaseID)
	and wit.WORKITEMTYPEID = wawrt.WorkItemTypeID
	group by AOR.AORID, arl.AORName, res.WTS_RESOURCEID, res.USERNAME, wrt.WTS_RESOURCE_TYPE, arl.ProductVersionID, arst.AORReleaseID
	) a
	order by upper(a.[AOR Name]), upper(a.[Resource])

end;

GO


