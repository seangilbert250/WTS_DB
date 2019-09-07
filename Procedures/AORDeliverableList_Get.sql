USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORDeliverableList_Get]    Script Date: 6/1/2018 9:21:00 AM ******/
DROP PROCEDURE [dbo].[AORDeliverableList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORDeliverableList_Get]    Script Date: 6/1/2018 9:21:00 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[AORDeliverableList_Get]
	@DeliverableID int = 0
as
begin
	select aear.AORReleaseID,
		sum(case when aear.PriorityID = 45 then isnull(aear.[Weight], 0) else 0 end) as Low,
		sum(case when aear.PriorityID = 46 then isnull(aear.[Weight], 0) else 0 end) as Moderate,
		sum(case when aear.PriorityID = 47 then isnull(aear.[Weight], 0) else 0 end) as High
	into #AOREstimate
	from AOREstimation_AORRelease aear
	where exists (
		select 1
		from AORReleaseDeliverable ard
		where ard.DeliverableID = @DeliverableID
		and ard.AORReleaseID = aear.AORReleaseID
	)
	group by aear.AORReleaseID;

	SELECT X,
			a.[AOR #],
			a.[AOR Name],
			a.[Description],
			a.Risk,
			a.[Weight],
			a.AVG_RESOURCES,
			a.AORRelease_ID,
			a.ProductVersion_ID,
			a.Release,
			a.AORReleaseDeliverable_ID,
			a.Z	
	into #AORDeliverable
	FROM (
		select null as X,
			AOR.AORID as [AOR #],
			arl.AORName as [AOR Name],
			arl.[Description],
			case when ae.High > 40 then (select p.[PRIORITY] from [PRIORITY] p where p.PRIORITYID = 47)
				when ae.High + ae.Moderate > 70 then (select p.[PRIORITY] from [PRIORITY] p where p.PRIORITYID = 46)
				when ae.AORReleaseID is null then 'Low (Not Maintained)'
				else (select p.[PRIORITY] from [PRIORITY] p where p.PRIORITYID = 45) end as Risk,
			ars.[Weight],
			COUNT(arr.WTS_RESOURCEID) / COUNT(DISTINCT arl.AORReleaseID) AS AVG_RESOURCES,
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
		left join #AOREstimate ae
		on arl.AORReleaseID = ae.AORReleaseID
		left outer join AORReleaseResource arr
		on arl.AORReleaseID = arr.AORReleaseID
		where ars.DeliverableID = @DeliverableID
		and AOR.Archive = 0
		group by AOR.AORID,
			arl.AORName,
			arl.[Description],
			ae.High,
			ae.Moderate,
			ae.AORReleaseID,
			ars.[Weight],
			arl.AORReleaseID,
			pv.ProductVersionID,
			pv.ProductVersion,
			ars.AORReleaseDeliverableID
	) a
	;

	select null as X
	     , 0 as [AOR #]
		 , null as [AOR Name]
		 , null as [Description]
		 , case when a.High > 40 then (select p.[PRIORITY] from [PRIORITY] p where p.PRIORITYID = 47)
				when a.High + a.Moderate > 70 then (select p.[PRIORITY] from [PRIORITY] p where p.PRIORITYID = 46)
				else (select p.[PRIORITY] from [PRIORITY] p where p.PRIORITYID = 45) end as Risk
		 , a.[Weight]
		 , AVG_RESOURCES as [Avg. Resources]
		 , 0 as AORRelease_ID
		 , 0 as ProductVersion_ID
		 , null as Release
		 , 0 as AORReleaseDeliverable_ID
		 , null as Z	
	from (
		select sum(case when ad.Risk like 'Low%' then isnull(ad.[Weight], 0) else 0 end) as Low
			 , sum(case when ad.Risk like 'Moderate%' then isnull(ad.[Weight], 0) else 0 end) as Moderate
			 , sum(case when ad.Risk like 'High%' then isnull(ad.[Weight], 0) else 0 end) as High
			 , sum(isnull(ad.[Weight],0)) as [Weight]
			 , sum(ad.AVG_RESOURCES) / count(ad.[AOR #]) as AVG_RESOURCES
		from #AORDeliverable ad
	) a
	union 
	select b.X
	     , b.[AOR #]
		 , b.[AOR Name]
		 , b.[Description]
		 , b.Risk
		 , b.[Weight]
		 , b.AVG_RESOURCES as [Avg. Resources]
		 , b.AORRelease_ID
		 , b.ProductVersion_ID
		 , b.Release
		 , b.AORReleaseDeliverable_ID
		 , b.Z	
	from #AORDeliverable b
	order by [Release], [AOR Name]
	;

	drop table #AOREstimate;
	drop table #AORDeliverable;
end;

GO

