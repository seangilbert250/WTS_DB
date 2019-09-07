USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_DeliverableList_Get]    Script Date: 6/1/2018 10:33:41 AM ******/
DROP PROCEDURE [dbo].[ReleaseSchedule_DeliverableList_Get]
GO

/****** Object:  StoredProcedure [dbo].[ReleaseSchedule_DeliverableList_Get]    Script Date: 6/1/2018 10:33:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ReleaseSchedule_DeliverableList_Get]
	@ProductVersionID int
AS
BEGIN
	select a.AORReleaseID,
		case when a.High > 40 then 47
			when a.High + a.Moderate > 70 then 46
			else 45 end as PriorityID
	into #AOREstimate
	from (
		select aear.AORReleaseID,
			sum(case when aear.PriorityID = 45 then isnull(aear.[Weight], 0) else 0 end) as Low,
			sum(case when aear.PriorityID = 46 then isnull(aear.[Weight], 0) else 0 end) as Moderate,
			sum(case when aear.PriorityID = 47 then isnull(aear.[Weight], 0) else 0 end) as High
		from AOREstimation_AORRelease aear
		where exists (
			select 1
			from AORReleaseDeliverable ard
			join ReleaseSchedule rs
			on ard.DeliverableID = rs.ReleaseScheduleID
			where rs.ProductVersionID = @ProductVersionID
			and ard.AORReleaseID = aear.AORReleaseID
		)
		group by aear.AORReleaseID
	) a;

	select ard.DeliverableID,
		sum(case when ae.PriorityID = 45 then isnull(ard.[Weight], 0) else 0 end) as Low,
		sum(case when ae.PriorityID = 46 then isnull(ard.[Weight], 0) else 0 end) as Moderate,
		sum(case when ae.PriorityID = 47 then isnull(ard.[Weight], 0) else 0 end) as High
	into #DeploymentEstimate
	from AORReleaseDeliverable ard
	join #AOREstimate ae
	on ard.AORReleaseID = ae.AORReleaseID
	where exists (
		select 1
		from ReleaseSchedule rs
		where rs.ProductVersionID = @ProductVersionID
		and rs.ReleaseScheduleID = ard.DeliverableID
	)
	group by ard.DeliverableID;

	select a.DeliverableID
         , sum(a.AVG_RESOURCES) / count(a.AORID) as [Avg. Resources]
	into #AvgResources
	from (
			select ard.DeliverableID
				 , AOR.AORID
				 , COUNT(arr.WTS_RESOURCEID) / COUNT(DISTINCT arl.AORReleaseID) AS AVG_RESOURCES
			from AOR
			join AORRelease arl
			on AOR.AORID = arl.AORID
			left join ProductVersion pv
			on arl.ProductVersionID = pv.ProductVersionID
			join AORReleaseDeliverable ard
			on arl.AORReleaseID = ard.AORReleaseID
			left outer join AORReleaseResource arr
			on arl.AORReleaseID = arr.AORReleaseID
			where exists (
				select 1
				from ReleaseSchedule rs
				where rs.ProductVersionID = @ProductVersionID
				and rs.ReleaseScheduleID = ard.DeliverableID
			)
			and AOR.Archive = 0
			group by ard.DeliverableID
					, AOR.AORID
	) a
	group by a.DeliverableID

	SELECT * FROM (
	--Add empty header row, used to make sure header is always created and row for cloning to create new records
		SELECT '' as X
		  ,0 as ReleaseScheduleID
		  ,'' as ReleaseScheduleDeliverable
		  ,0 as ProductVersionID
		  ,0 as AORCount
		  ,0 as ContractCount
		  ,'' as [Description]
		  ,'' as Narrative
		  ,'' as PlannedDevTestStart
		  ,'' as PlannedDevTestEnd
		  ,'' as PlannedStart
		  ,'' as PlannedEnd
		  ,'' as Risk
		  ,'' as [Avg. Resources]
		  ,0 as Visible
		  ,'' as PlannedInvStart
		  ,'' as PlannedInvEnd
		  ,'' as PlannedTDStart
		  ,'' as PlannedTDEnd
		  ,'' as PlannedCDStart
		  ,'' as PlannedCDEnd
		  ,'' as PlannedCodingStart
		  ,'' as PlannedCodingEnd
		  ,'' as PlannedITStart
		  ,'' as PlannedITEnd
		  ,'' as PlannedCVTStart
		  ,'' as PlannedCVTEnd
		  ,'' as PlannedAdoptStart
		  ,'' as PlannedAdoptEnd
		  ,0 as SORT_ORDER 
		  ,0 as ARCHIVE
		  ,'' as ContractIDs
		  ,'' as AORReleaseIDs
		UNION ALL
		SELECT '' as X
		  ,ReleaseScheduleID
		  ,ReleaseScheduleDeliverable
		  ,ProductVersionID
		  , (SELECT COUNT(*) 
				FROM AORReleaseDeliverable aorrs
				left join AORRelease arl
				on aorrs.AORReleaseID = arl.AORReleaseID
				left join AOR 
				on arl.AORID = AOR.AORID 
				WHERE aorrs.DeliverableID = rs.ReleaseScheduleID
				and AOR.Archive = 0) AS AORCount
		  , (SELECT COUNT(*) FROM DeploymentContract dc WHERE dc.DeliverableID = rs.ReleaseScheduleID) AS ContractCount
		  ,[Description]
		  ,Narrative
		  ,PlannedDevTestStart
		  ,PlannedDevTestEnd
		  ,PlannedStart
		  ,PlannedEnd
		  ,case when de.High > 40 then (select p.[PRIORITY] from [PRIORITY] p where p.PRIORITYID = 47)
				when de.High + de.Moderate > 70 then (select p.[PRIORITY] from [PRIORITY] p where p.PRIORITYID = 46)
				when de.DeliverableID is null then 'Low (Not Maintained)'
				else (select p.[PRIORITY] from [PRIORITY] p where p.PRIORITYID = 45) end as Risk
		  ,avr.[Avg. Resources]
		  ,Visible
		  ,PlannedInvStart
		  ,PlannedInvEnd
		  ,PlannedTDStart
		  ,PlannedTDEnd
		  ,PlannedCDStart
		  ,PlannedCDEnd
		  ,PlannedCodingStart
		  ,PlannedCodingEnd
		  ,PlannedITStart
		  ,PlannedITEnd
		  ,PlannedCVTStart
		  ,PlannedCVTEnd
		  ,PlannedAdoptStart
		  ,PlannedAdoptEnd
		  ,SORT_ORDER
		  ,ARCHIVE
		  ,(select stuff((select ',' + convert(nvarchar(10), ContractID) from DeploymentContract where DeliverableID = rs.ReleaseScheduleID for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '')) as ContractIDs
		  ,(select stuff((select ',' + convert(nvarchar(10), AORReleaseID) from AORReleaseDeliverable where DeliverableID = rs.ReleaseScheduleID for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '')) as AORReleaseIDs
		FROM ReleaseSchedule rs
		left join #DeploymentEstimate de
		on rs.ReleaseScheduleID = de.DeliverableID
		left join #AvgResources avr
		on rs.ReleaseScheduleID = avr.DeliverableID
		WHERE ProductVersionID = @ProductVersionID
	) a
	ORDER BY a.SORT_ORDER, a.ReleaseScheduleID

	drop table #AOREstimate;
	drop table #DeploymentEstimate;
	drop table #AvgResources;

END;
GO

