USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORTaskAORList_Get]    Script Date: 5/30/2018 1:32:02 PM ******/
DROP PROCEDURE [dbo].[AORTaskAORList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORTaskAORList_Get]    Script Date: 5/30/2018 1:32:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[AORTaskAORList_Get]
	@TaskID int = 0
as
begin
	select wi.WORKITEMID,
		AOR.AORID,
		arl.AORName,
		arl.AORReleaseID,
		arl.AORWorkTypeID,
		isnull(wa.Abbreviation, 'O') as Abbreviation,
		rta.CascadeAOR,
		arl.WorkloadAllocationID
	from AOR
	join AORRelease arl
	on AOR.AORID = arl.AORID
	left join WorkloadAllocation wa
	on arl.WorkloadAllocationID = wa.WorkloadAllocationID
	join AORReleaseTask rta
	on arl.AORReleaseID = rta.AORReleaseID
	join WORKITEM wi
	on rta.WORKITEMID = wi.WORKITEMID
	where AOR.Archive = 0
	and arl.[Current] = 1
	and (@TaskID = 0 or wi.WORKITEMID = @TaskID)
	order by wi.WORKITEMID desc, upper(arl.AORName);
end;
GO


