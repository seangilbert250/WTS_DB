USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORTaskCascadeAOR_Get]    Script Date: 3/6/2018 10:47:12 AM ******/
DROP PROCEDURE [dbo].[AORTaskCascadeAOR_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORTaskCascadeAOR_Get]    Script Date: 3/6/2018 10:47:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[AORTaskCascadeAOR_Get]
	@TaskID int = 0
as
begin
	select distinct AOR.AORID,
		arl.AORName,
		arl.AORReleaseID,
		isnull(art.CascadeAOR, 0) as CascadeAOR,
		isnull(awt.AORWorkTypeName, 'No AOR Type') as AORType
	from AOR
	join AORRelease arl
	on AOR.AORID = arl.AORID
	join AORReleaseTask art 
	on arl.AORReleaseID = art.AORReleaseID
	left join AORWorkType awt
	on arl.AORWorkTypeID = awt.AORWorkTypeID
	where art.WORKITEMID = @TaskID
	and awt.AORWorkTypeID != 2
	and arl.[Current] = 1
end;
GO


