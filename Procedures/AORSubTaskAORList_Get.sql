USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORSubTaskAORList_Get]    Script Date: 5/30/2018 1:39:42 PM ******/
DROP PROCEDURE [dbo].[AORSubTaskAORList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORSubTaskAORList_Get]    Script Date: 5/30/2018 1:39:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[AORSubTaskAORList_Get]
	@TaskID int = 0
as
begin
	select wi.WORKITEM_TASKID,
		AOR.AORID,
		arl.AORName,
		arl.AORReleaseID,
		isnull(wa.Abbreviation, 'O') as Abbreviation,
		isnull(awt.AORWorkTypeName, 'No AOR Type') as AORType
	from AOR
	join AORRelease arl
	on AOR.AORID = arl.AORID
	left join WorkloadAllocation wa
	on arl.WorkloadAllocationID = wa.WorkloadAllocationID
	join AORReleaseSubTask rta
	on arl.AORReleaseID = rta.AORReleaseID
	join WORKITEM_TASK wi
	on rta.WORKITEMTASKID = wi.WORKITEM_TASKID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	where AOR.Archive = 0
	and arl.[Current] = 1
	and awt.AORWorkTypeID != 2
	and (@TaskID = 0 or wi.WORKITEM_TASKID = @TaskID)
	order by wi.WORKITEMID desc, upper(arl.AORName);
end;
GO


