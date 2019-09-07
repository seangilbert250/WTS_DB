USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_Get_Columns]    Script Date: 7/23/2018 12:18:02 PM ******/
DROP FUNCTION [dbo].[AOR_Get_Columns]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_Get_Columns]    Script Date: 7/23/2018 12:18:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE function [dbo].[AOR_Get_Columns]
(
	@ColumnName nvarchar(100),
	@Option int = 0,
	@ID nvarchar(100) = '',
	@Sort nvarchar(100) = '',
	@Alt int = 0
)
returns nvarchar(1000)
as
begin
	declare @colName nvarchar(1000);
	declare @colSort nvarchar(100);
	declare @columns nvarchar(1000);
	
	set @colName = upper(@ColumnName);
	set @colSort = replace(replace(@Sort, 'Ascending', 'asc'), 'Descending', 'desc');

	set @columns = 
		case when @colName = 'TASK.WORKLOAD.RELEASE STATUS' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Task.Workload.Release Status] ' + @colSort
			when @Option = 4 then '' else '[Task.Workload.Release Status]' end
		when @colName = 'WORKLOAD PRIORITY' then
			case when @Option = 0 then
				case when @Alt = 1 then 'isnull(convert(nvarchar(10), isnull(sum(wps.[1]), 0)) + ''.'' +
				  convert(nvarchar(10), isnull(sum(wps.[2]), 0)) + ''.'' +
				  convert(nvarchar(10), isnull(sum(wps.[3]), 0)) + ''.'' +
				  convert(nvarchar(10), isnull(sum(wps.[4]), 0)) + ''.'' +
				  convert(nvarchar(10), isnull(sum(wps.[5+]), 0)) + ''.'' +
				  convert(nvarchar(10), isnull(sum(wps.[6]), 0)) + 
				  '' ('' + convert(nvarchar(10), isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + '', '' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + ''%)'', ''0.0.0.0.0.0 (0, 0%)'') as [Workload Priority]'
				when @Alt = 2 then 'isnull(convert(nvarchar(10), max(case when wit.AssignedToRankID = 27 and wit.STATUSID != 10 then 1 else 0 end)) + ''.'' +
				  convert(nvarchar(10), max(case when wit.AssignedToRankID = 28 and wit.STATUSID != 10 then 1 else 0 end)) + ''.'' +
				  convert(nvarchar(10), max(case when wit.AssignedToRankID = 38 and wit.STATUSID != 10 then 1 else 0 end)) + ''.'' +
				  convert(nvarchar(10), max(case when wit.AssignedToRankID = 29 and wit.STATUSID != 10 then 1 else 0 end)) + ''.'' +
				  convert(nvarchar(10), max(case when wit.AssignedToRankID = 30 and wit.STATUSID != 10 then 1 else 0 end)) + ''.'' +
				  convert(nvarchar(10), max(case when wit.AssignedToRankID = 31 then 1 else 0 end)) + 
				  '' ('' + convert(nvarchar(10), max(case when wit.STATUSID != 10 then 1 else 0 end)) + '', '' + convert(nvarchar(10), max(case when wit.STATUSID = 10 then 100 else 0 end)) + ''%)'', ''0.0.0.0.0.0 (0, 0%)'') as [Workload Priority]'
				else 'isnull(convert(nvarchar(10),  isnull(sum(wps.[1]), 0)) + ''.'' +
				  convert(nvarchar(10),  isnull(sum(wps.[2]), 0)) + ''.'' +
				  convert(nvarchar(10),  isnull(sum(wps.[3]), 0)) + ''.'' +
				  convert(nvarchar(10),  isnull(sum(wps.[4]), 0)) + ''.'' +
				  convert(nvarchar(10),  isnull(sum(wps.[5+]), 0)) + ''.'' +
				  convert(nvarchar(10),  isnull(sum(wps.[6]), 0)) + 
				  '' ('' + convert(nvarchar(10),  isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0)) + '', '' + convert(nvarchar(10), 100*isnull(sum(wps.[6]), 0)/nullif(isnull(sum(wps.[1]), 0) + isnull(sum(wps.[2]), 0) + isnull(sum(wps.[3]), 0) + isnull(sum(wps.[4]), 0) + isnull(sum(wps.[5+]), 0) + isnull(sum(wps.[6]), 0), 0)) + ''%)'', ''0.0.0.0.0.0 (0, 0%)'') as [Workload Priority]' end
			when @Option = 1 then null
			when @Option = 2 then null
			when @Option = 3 then 'a.[Workload Priority] ' + @colSort
			when @Option = 4 then '' else '[Workload Priority]' end
		when @colName = 'RESOURCE COUNT (T.BA.PA.CT)' then
			case when @Option = 0 then
				'isnull(convert(nvarchar(10),  isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 1 then wrta.WTS_RESOURCEID  else null end), 0) 
				  + isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 2 then wrta.WTS_RESOURCEID  else null end), 0) 
				  + isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 3 then wrta.WTS_RESOURCEID  else null end), 0)) + ''.'' + 
				  convert(nvarchar(10),  isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 1 then wrta.WTS_RESOURCEID  else null end), 0)) + ''.'' +
				  convert(nvarchar(10),  isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 2 then wrta.WTS_RESOURCEID  else null end), 0)) + ''.'' +
				  convert(nvarchar(10),  isnull(count(distinct case when wrta.WTS_RESOURCE_TYPEID = 3 then wrta.WTS_RESOURCEID  else null end), 0)), ''0.0.0.0'') as [Resource Count (T.BA.PA.CT)]' 
			when @Option = 1 then null
			when @Option = 2 then null
			when @Option = 3 then 'a.[Resource Count (T.BA.PA.CT)] ' + @colSort
			when @Option = 4 then '' else '[Resource Count (T.BA.PA.CT)]' end
		when @colName = 'CARRY IN/OUT COUNT' then
			case when @Option = 0 then 'isnull(convert(nvarchar(10), isnull(sum(cio.CarryInCount), 0)) + '' ('' + convert(nvarchar(10), cast((cast(isnull(sum(cio.CarryInCount), 0) as decimal) / cast(nullif(sum(cio.TotalCount), 0) as decimal)) * 100 as decimal)) + ''%) / '' +
				convert(nvarchar(10), isnull(sum(cio.CarryOutCount), 0)) + '' ('' + convert(nvarchar(10), cast((cast(isnull(sum(cio.CarryOutCount), 0) as decimal) / cast(nullif(sum(cio.TotalCount), 0) as decimal)) * 100 as decimal)) + ''%)'', ''0 (0%) / 0 (0%)'') as [Carry In/Out Count]' 
			when @Option = 1 then null
			when @Option = 2 then null
			when @Option = 3 then 'a.[Carry In/Out Count] ' + @colSort
			when @Option = 4 then '' else '[Carry In/Out Count]' end
		when @colName = '# OF MEETINGS' or @colName = 'MEETINGCOUNT_ID' then
			case when @Option = 0 then 'isnull(wmc.MeetingCount, 0) as MeetingCount_ID, isnull(wmc.MeetingCount, 0) as [# of Meetings]'
			when @Option = 1 then 'isnull(wmc.MeetingCount, 0) = ' + @ID + ' and '
			when @Option = 2 then 'isnull(wmc.MeetingCount, 0)'
			when @Option = 3 then 'a.[# of Meetings] ' + @colSort
			when @Option = 4 then 'AOR'
			else '[# of Meetings]' end
		when @colName = '# OF ATTACHMENTS' or @colName = 'ATTACHMENTCOUNT_ID' then
			case when @Option = 0 then 'isnull(wac.AttachmentCount, 0) as AttachmentCount_ID, isnull(wac.AttachmentCount, 0) as [# of Attachments]'
			when @Option = 1 then 'isnull(wac.AttachmentCount, 0) = ' + @ID + ' and '
			when @Option = 2 then 'isnull(wac.AttachmentCount, 0)'
			when @Option = 3 then 'a.[# of Attachments] ' + @colSort
			when @Option = 4 then 'AOR'
			else '[# of Attachments]' end
		when @colName = 'VISIBLE TO CUSTOMER' or @colName = 'VISIBLETOCUSTOMER_ID' then
			case when @Option = 0 then 'case arl.AORCustomerFlagship when 1 then ''1'' else ''0'' end as VisibleToCustomer_ID, case arl.AORCustomerFlagship when 1 then ''Yes'' else ''No'' end as [Visible To Customer]'
			when @Option = 1 then 'isnull(arl.AORCustomerFlagship, 0) = ' + @ID + ' and '
			when @Option = 2 then 'arl.AORCustomerFlagship'
			when @Option = 3 then 'a.[Visible To Customer] ' + @colSort
			when @Option = 4 then 'AOR' else '[Visible To Customer]' end
		when @colName = 'DEPLOYMENT' or @colName = 'DEPLOYMENT_ID' then
			case when @Option = 0 then 'rs.ReleaseScheduleID as DEPLOYMENT_ID, rs.ReleaseScheduleDeliverable as [Deployment]'
			when @Option = 1 then 'rs.ReleaseScheduleID = ' + @ID + ' and '
			when @Option = 2 then 'rs.ReleaseScheduleID, rs.ReleaseScheduleDeliverable'
			when @Option = 3 then 'a.[Deployment] ' + @colSort
			when @Option = 4 then '' else '[Deployment]' end
		when @colName = 'DEPLOYMENT TITLE' or @colName = 'DEPLOYMENT_TITLE_ID' then
			case when @Option = 0 then 'rs.ReleaseScheduleID as DEPLOYMENT_TITLE_ID, rs.[Description] as [Deployment Title]'
			when @Option = 1 then 'rs.ReleaseScheduleID = ' + @ID + ' and '
			when @Option = 2 then 'rs.ReleaseScheduleID, rs.[Description]'
			when @Option = 3 then 'a.[Deployment Title] ' + @colSort
			when @Option = 4 then 'AOR' else '[Deployment Title]' end
		when @colName = 'DEPLOYMENT START DATE' or @colName = 'DEPLOYMENT_START_ID' then
			case when @Option = 0 then 'rs.ReleaseScheduleID as DEPLOYMENT_START_ID, rs.PlannedDevTestStart as [Deployment Start Date]'
			when @Option = 1 then 'rs.ReleaseScheduleID = ' + @ID + ' and '
			when @Option = 2 then 'rs.ReleaseScheduleID, rs.PlannedDevTestStart'
			when @Option = 3 then 'a.[Deployment Start Date] ' + @colSort
			when @Option = 4 then 'AOR' else '[Deployment Start Date]' end
		when @colName = 'DEPLOYMENT END DATE' or @colName = 'DEPLOYMENT_END_ID' then
			case when @Option = 0 then 'rs.ReleaseScheduleID as DEPLOYMENT_END_ID, rs.PlannedEnd as [Deployment End Date]'
			when @Option = 1 then 'rs.ReleaseScheduleID = ' + @ID + ' and '
			when @Option = 2 then 'rs.ReleaseScheduleID, rs.PlannedEnd'
			when @Option = 3 then 'a.[Deployment End Date] ' + @colSort
			when @Option = 4 then 'AOR' else '[Deployment End Date]' end
		when @colName = 'AOR NAME' or @colName = 'AORRELEASE_ID' then
			case when @Option = 0 then 'AOR.AORID as AOR_ID, arl.AORName as [AOR Name], arl.AORReleaseID as AORRelease_ID, at.AORWorkTypeName as AORTypeRef_ID, case AOR.Archive when 1 then ''true'' else ''false'' end as Archive_ID'
			when @Option = 1 then 'arl.AORReleaseID = ' + @ID + ' and '
			when @Option = 2 then 'AOR.AORID, arl.AORName, arl.AORReleaseID, at.AORWorkTypeName, AOR.Archive'
			when @Option = 3 then 'upper(a.[AOR Name]) ' + @colSort
			when @Option = 4 then 'AOR' else '[AOR Name]' end
		when @colName = 'AOR #' or @colName = 'AORNUMRELEASE_ID' then
			case when @Option = 0 then 'AOR.AORID as AORNUM_ID, AOR.AORID as [AOR #], arl.AORReleaseID as AORNumRelease_ID'
			when @Option = 1 then 'arl.AORReleaseID = ' + @ID + ' and '
			when @Option = 2 then 'AOR.AORID, arl.AORReleaseID'
			when @Option = 3 then 'upper(a.[AOR #]) ' + @colSort
			when @Option = 4 then 'AOR' else '[AOR #]' end
		when @colName = 'DESCRIPTION' or @colName = 'AORDESCRIPTIONRELEASE_ID' then
			case when @Option = 0 then 'AOR.AORID as AORDESCRIPTION_ID, arl.[Description], arl.AORReleaseID as AORDescriptionRelease_ID'
			when @Option = 1 then 'arl.AORReleaseID = ' + @ID + ' and '
			when @Option = 2 then 'AOR.AORID, arl.[Description], arl.AORReleaseID'
			when @Option = 3 then 'upper(a.[Description]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Description]' end
		when @colName = 'SORT' or @colName = 'AORSORTRELEASE_ID' then
			case when @Option = 0 then 'AOR.AORID as AORSORT_ID, AOR.Sort AS [Sort], arl.AORReleaseID as AORSortRelease_ID'
			when @Option = 1 then 'arl.AORReleaseID = ' + @ID + ' and '
			when @Option = 2 then 'AOR.AORID, AOR.Sort, arl.AORReleaseID'
			when @Option = 3 then 'upper(a.[Sort]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Sort]' end
		when @colName = 'CARRY IN' or @colName = 'CARRYIN_ID' then
			case when @Option = 0 then 'spv.ProductVersionID as CarryIn_ID, spv.ProductVersion as [Carry In]'
			when @Option = 1 then 'isnull(spv.ProductVersionID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'spv.ProductVersionID, spv.ProductVersion'
			when @Option = 3 then 'upper(a.[Carry In]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Carry In]' end
		when @colName = 'CMMI' or @colName = 'CMMI_ID' then
			case when @Option = 0 then 'cs.STATUSID as CMMI_ID, cs.[STATUS] as CMMI'
			when @Option = 1 then 'isnull(cs.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'cs.STATUSID, cs.[STATUS]'
			when @Option = 3 then 'upper(a.CMMI) ' + @colSort
			when @Option = 4 then 'AOR' else 'CMMI' end
		when @colName = 'CRITICAL PATH TEAM' or @colName = 'CRITICALPATHTEAM_ID' then
			case when @Option = 0 then 'art.AORTeamID as CriticalPathTeam_ID, art.AORTeamName as [Critical Path Team]'
			when @Option = 1 then 'isnull(art.AORTeamID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'art.AORTeamID, art.AORTeamName'
			when @Option = 3 then 'upper(a.[Critical Path Team]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Critical Path Team]' end
		when @colName = 'RELEASE' or @colName = 'RELEASE_ID' then
			case when @Option = 0 then 'rpv.ProductVersionID as Release_ID, rpv.ProductVersion as [Release]'
			when @Option = 1 then 'isnull(rpv.ProductVersionID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rpv.ProductVersionID, rpv.ProductVersion'
			when @Option = 3 then 'upper(a.[Release]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Release]' end
		when @colName = 'CYBER REVIEW' or @colName = 'CYBER_ID' then
			case when @Option = 0 then 'crs.STATUSID as Cyber_ID, crs.STATUS as [Cyber Review]'
			when @Option = 1 then 'isnull(arl.CyberID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'arl.CyberID'
			when @Option = 3 then 'a.[Cyber Review] ' + @colSort
			when @Option = 4 then 'AOR' else '[Cyber Review]' end
		when @colName = 'CODING ESTIMATED EFFORT' or @colName = 'CODINGEFFORT_ID' then
			case when @Option = 0 then 'ces.EffortSizeID as CodingEffort_ID, ces.EffortSize as [Coding Estimated Effort]'
			when @Option = 1 then 'isnull(ces.EffortSizeID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ces.EffortSizeID, ces.EffortSize'
			when @Option = 3 then 'upper(a.[Coding Estimated Effort]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Coding Estimated Effort]' end
		when @colName = 'TESTING ESTIMATED EFFORT' or @colName = 'TESTINGEFFORT_ID' then
			case when @Option = 0 then 'tes.EffortSizeID as TestingEffort_ID, tes.EffortSize as [Testing Estimated Effort]'
			when @Option = 1 then 'isnull(tes.EffortSizeID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'tes.EffortSizeID, tes.EffortSize'
			when @Option = 3 then 'upper(a.[Testing Estimated Effort]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Testing Estimated Effort]' end
		when @colName = 'TRAINING/SUPPORT ESTIMATED EFFORT' or @colName = 'TRAININGSUPPORTEFFORT_ID' then
			case when @Option = 0 then 'ses.EffortSizeID as TrainingSupportEffort_ID, ses.EffortSize as [Training/Support Estimated Effort]'
			when @Option = 1 then 'isnull(ses.EffortSizeID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ses.EffortSizeID, ses.EffortSize'
			when @Option = 3 then 'upper(a.[Training/Support Estimated Effort]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Training/Support Estimated Effort]' end
		when @colName = 'LAST MEETING' or @colName = 'LASTMEETING_ID' then
			case when @Option = 0 then 'wlm.LastMeeting as LastMeeting_ID, wlm.LastMeeting as [Last Meeting]'
			when @Option = 1 then 'isnull(wlm.LastMeeting, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'wlm.LastMeeting'
			when @Option = 3 then 'a.[Last Meeting] ' + @colSort
			when @Option = 4 then 'AOR' else '[Last Meeting]' end
		when @colName = 'NEXT MEETING' or @colName = 'NEXTMEETING_ID' then
			case when @Option = 0 then 'wnm.NextMeeting as NextMeeting_ID, wnm.NextMeeting as [Next Meeting]'
			when @Option = 1 then 'isnull(wnm.NextMeeting, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'wnm.NextMeeting'
			when @Option = 3 then 'a.[Next Meeting] ' + @colSort
			when @Option = 4 then 'AOR' else '[Next Meeting]' end
		when @colName = 'RANK' or @colName = 'RANK_ID' then
			case when @Option = 0 then 'arl.RankID as Rank_ID, arl.RankID as Rank'
			when @Option = 1 then 'isnull(arl.RankID, -999) = ' + @ID + ' and '
			when @Option = 2 then 'arl.RankID'
			when @Option = 3 then 'a.Rank ' + @colSort
			when @Option = 4 then 'AOR' else 'Rank' end
		when @colName = 'STAGE PRIORITY' or @colName = 'STAGEPRIORITY_ID' then
			case when @Option = 0 then 'arl.StagePriority as StagePriority_ID, arl.StagePriority as [Stage Priority]'
			when @Option = 1 then 'isnull(arl.StagePriority, 0) = ' + @ID + ' and '
			when @Option = 2 then 'arl.StagePriority'
			when @Option = 3 then 'a.[Stage Priority] ' + @colSort
			when @Option = 4 then 'AOR' else '[Stage Priority]' end
		when @colName = 'TIER' or @colName = 'TIER_ID' then
			case when @Option = 0 then 'arl.TierID as Tier_ID, case when arl.TierID = 1 then ''A'' when arl.TierID = 2 then ''B'' when arl.TierID = 3 then ''C'' else '''' end as Tier'
			when @Option = 1 then 'isnull(arl.TierID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'arl.TierID'
			when @Option = 3 then 'a.Tier ' + @colSort
			when @Option = 4 then 'AOR' else 'Tier' end
		when @colName = 'AOR WORKLOAD TYPE' or @colName = 'AORTYPE_ID' then
			case when @Option = 0 then 'awt.AORWorkTypeID as AORTYPE_ID, awt.AORWorkTypeName as [AOR Workload Type]'
			when @Option = 1 then 'isnull(awt.AORWorkTypeID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'awt.AORWorkTypeID, awt.AORWorkTypeName'
			when @Option = 3 then 'upper(a.[AOR Workload Type]) ' + @colSort
			when @Option = 4 then 'AOR' else '[AOR Workload Type]' end
		when @colName = 'INVESTIGATION STATUS' or @colName = 'INVESTIGATION_STATUS_ID' then
			case when @Option = 0 then 'invs.STATUSID as INVESTIGATION_STATUS_ID, invs.[STATUS] as [Investigation Status]'
			when @Option = 1 then 'isnull(invs.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'invs.STATUSID, invs.[STATUS]'
			when @Option = 3 then 'upper(a.[Investigation Status]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Investigation Status]' end
		when @colName = 'TECHNICAL STATUS' or @colName = 'TECHNICAL_STATUS_ID' then
			case when @Option = 0 then 'ts.STATUSID as TECHNICAL_STATUS_ID, ts.[STATUS] as [Technical Status]'
			when @Option = 1 then 'isnull(ts.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ts.STATUSID, ts.[STATUS]'
			when @Option = 3 then 'upper(a.[Technical Status]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Technical Status]' end
		when @colName = 'CUSTOMER DESIGN STATUS' or @colName = 'CUSTOMER_DESIGN_STATUS_ID' then
			case when @Option = 0 then 'cds.STATUSID as CUSTOMER_DESIGN_STATUS_ID, cds.[STATUS] as [Customer Design Status]'
			when @Option = 1 then 'isnull(cds.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'cds.STATUSID, cds.[STATUS]'
			when @Option = 3 then 'upper(a.[Customer Design Status]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Customer Design Status]' end
		when @colName = 'CODING STATUS' or @colName = 'CODING_STATUS_ID' then
			case when @Option = 0 then 'cods.STATUSID as CODING_STATUS_ID, cods.[STATUS] as [Coding Status]'
			when @Option = 1 then 'isnull(cods.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'cods.STATUSID, cods.[STATUS]'
			when @Option = 3 then 'upper(a.[Coding Status]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Coding Status]' end
		when @colName = 'INTERNAL TESTING STATUS' or @colName = 'INTERNAL_TESTING_STATUS_ID' then
			case when @Option = 0 then 'its.STATUSID as INTERNAL_TESTING_STATUS_ID, its.[STATUS] as [Internal Testing Status]'
			when @Option = 1 then 'isnull(its.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'its.STATUSID, its.[STATUS]'
			when @Option = 3 then 'upper(a.[Internal Testing Status]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Internal Testing Status]' end
		when @colName = 'CUSTOMER VALIDATION TESTING STATUS' or @colName = 'CUSTOMER_VALIDATION_TESTING_STATUS_ID' then
			case when @Option = 0 then 'cvts.STATUSID as CUSTOMER_VALIDATION_STATUS_ID, cvts.[STATUS] as [Customer Validation Testing Status]'
			when @Option = 1 then 'isnull(cvts.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'cvts.STATUSID, cvts.[STATUS]'
			when @Option = 3 then 'upper(a.[Customer Validation Testing Status]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Customer Validation Testing Status]' end
		when @colName = 'ADOPTION STATUS' or @colName = 'ADOPTION_STATUS_ID' then
			case when @Option = 0 then 'ads.STATUSID as ADOPTION_STATUS_ID, ads.[STATUS] as [Adoption Status]'
			when @Option = 1 then 'isnull(ads.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ads.STATUSID, ads.[STATUS]'
			when @Option = 3 then 'upper(a.[Adoption Status]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Adoption Status]' end
		when @colName = 'IP1 STATUS' or @colName = 'IP1_STATUS_ID' then
			case when @Option = 0 then 'ip1s.STATUSID as IP1_STATUS_ID, ip1s.[STATUS] as [IP1 Status]'
			when @Option = 1 then 'isnull(ip1s.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ip1s.STATUSID, ip1s.[STATUS]'
			when @Option = 3 then 'upper(a.[IP1 Status]) ' + @colSort
			when @Option = 4 then 'AOR' else '[IP1 Status]' end
		when @colName = 'IP2 STATUS' or @colName = 'IP2_STATUS_ID' then
			case when @Option = 0 then 'ip2s.STATUSID as IP2_STATUS_ID, ip2s.[STATUS] as [IP2 Status]'
			when @Option = 1 then 'isnull(ip2s.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ip2s.STATUSID, ip2s.[STATUS]'
			when @Option = 3 then 'upper(a.[IP2 Status]) ' + @colSort
			when @Option = 4 then 'AOR' else '[IP2 Status]' end
		when @colName = 'IP3 STATUS' or @colName = 'IP3_STATUS_ID' then
			case when @Option = 0 then 'ip3s.STATUSID as IP3_STATUS_ID, ip3s.[STATUS] as [IP3 Status]'
			when @Option = 1 then 'isnull(ip3s.STATUSID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ip3s.STATUSID, ip3s.[STATUS]'
			when @Option = 3 then 'upper(a.[IP3 Status]) ' + @colSort
			when @Option = 4 then 'AOR' else '[IP3 Status]' end
		when @colName = 'PRIMARY SYSTEM' or @colName = 'PRIMARY_SYSTEM_ID' then
			case when @Option = 0 then 'aorpsys.WTS_SYSTEMID as PRIMARY_SYSTEM_ID, aorpsys.[WTS_SYSTEM] as [Primary System], aorpss.SORTORDER as AORPRIMARYSYSTEMSUITESORT_ID, aorpsys.SORT_ORDER as AORPRIMARYSYSTEMSORT_ID'
			when @Option = 1 then 'isnull(aorpsys.WTS_SYSTEMID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'aorpsys.WTS_SYSTEMID, aorpsys.[WTS_SYSTEM], aorpss.SORTORDER, aorpsys.SORT_ORDER'
			when @Option = 3 then 'a.AORPRIMARYSYSTEMSUITESORT_ID, a.AORPRIMARYSYSTEMSORT_ID, upper(a.[Primary System]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Primary System]' end
		when @colName = 'AOR SYSTEM' or @colName = 'AOR_SYSTEM_ID' then
			case when @Option = 0 then 'aorsys.WTS_SYSTEMID as AOR_SYSTEM_ID, aorsys.[WTS_SYSTEM] as [AOR System], aorss.SORTORDER as AORSYSTEMSUITESORT_ID, aorsys.SORT_ORDER as AORSYSTEMSORT_ID'
			when @Option = 1 then 'isnull(aorsys.WTS_SYSTEMID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'aorsys.WTS_SYSTEMID, aorsys.[WTS_SYSTEM], aorss.SORTORDER, aorsys.SORT_ORDER'
			when @Option = 3 then 'a.AORSYSTEMSUITESORT_ID, a.AORSYSTEMSORT_ID, upper(a.[AOR System]) ' + @colSort
			when @Option = 4 then 'AOR' else '[AOR System]' end
		when @colName = 'RESOURCES' or @colName = 'RESOURCES_ID' then
			case when @Option = 0 then 'AOR.AORID as RESOURCES_ID, count(arr.WTS_RESOURCEID) OVER(PARTITION BY arr.AORReleaseID) as [Resources]'
			when @Option = 1 then 'arl.AORReleaseID = ' + @ID + ' and '
			when @Option = 2 then 'AOR.AORID, arl.AORReleaseID'
			when @Option = 3 then 'upper(a.[Resources]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Resources]' end
		when @colName = 'WORKLOAD ALLOCATION' or @colName = 'WORKLOAD_ALLOCATION_ID' then
			case when @Option = 0 then 'rps.WorkloadAllocationID as WORKLOAD_ALLOCATION_ID, rps.[WorkloadAllocation] as [Workload Allocation]'
			when @Option = 1 then 'isnull(rps.WorkloadAllocationID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rps.WorkloadAllocationID, rps.[WorkloadAllocation]'
			when @Option = 3 then 'upper(a.[Workload Allocation]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Workload Allocation]' end
		when @colName = 'APPROVED' or @colName = 'APPROVED_ID' then
			case when @Option = 0 then 'case AOR.[Approved] when 1 then ''1'' else ''0'' end as APPROVED_ID, case AOR.[Approved] when 1 then ''Yes'' else ''No'' end as [Approved]'
			when @Option = 1 then 'isnull(AOR.[Approved], 0) = ' + @ID + ' and '
			when @Option = 2 then 'AOR.[Approved]'
			when @Option = 3 then 'upper(a.[Approved]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Approved]' end
		when @colName = 'APPROVED BY' or @colName = 'APPROVEDBY_ID' then
			case when @Option = 0 then 'aoraby.WTS_RESOURCEID as APPROVEDBY_ID, aoraby.USERNAME as [Approved By]'
			when @Option = 1 then 'aoraby.WTS_RESOURCEID = ' + @ID + ' and '
			when @Option = 2 then 'aoraby.WTS_RESOURCEID, aoraby.USERNAME'
			when @Option = 3 then 'a.[Approved By] ' + @colSort
			when @Option = 4 then 'AOR' else NULL end
		when @colName = 'APPROVED DATE' or @colName = 'APPROVEDDATERELEASE_ID' then
			case when @Option = 0 then 'AOR.AORID as APPROVEDDATE_ID, AOR.[ApprovedDate] as [Approved Date], arl.AORReleaseID as ApprovedDateRelease_ID'
			when @Option = 1 then 'arl.AORReleaseID = ' + @ID + ' and '
			when @Option = 2 then 'AOR.AORID, AOR.[ApprovedDate], arl.AORReleaseID'
			when @Option = 3 then 'upper(a.[Approved Date]) ' + @colSort
			when @Option = 4 then 'AOR' else '[Approved Date]' end
		when @colName = 'DEV WORKLOAD MANAGER' or @colName = 'DEVWORKLOADMANAGER_ID' then
			case when @Option = 0 then 'dwm.WTS_RESOURCEID as DEVWORKLOADMANAGER_ID, dwm.USERNAME as [Dev Workload Manager]'
			when @Option = 1 then 'isnull(dwm.WTS_RESOURCEID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'dwm.WTS_RESOURCEID, dwm.USERNAME'
			when @Option = 3 then 'a.[Dev Workload Manager] ' + @colSort
			when @Option = 4 then 'AOR' else NULL end
		when @colName = 'BUS WORKLOAD MANAGER' or @colName = 'BUSWORKLOADMANAGER_ID' then
			case when @Option = 0 then 'bwm.WTS_RESOURCEID as BUSWORKLOADMANAGER_ID, bwm.USERNAME as [Bus Workload Manager]'
			when @Option = 1 then 'bwm.WTS_RESOURCEID = ' + @ID + ' and '
			when @Option = 2 then 'bwm.WTS_RESOURCEID, bwm.USERNAME'
			when @Option = 3 then 'a.[Bus Workload Manager] ' + @colSort
			when @Option = 4 then 'AOR' else NULL end
		when @colName = 'PLANNED START' or @colName = 'PLANNEDSTART_ID' then
			case when @Option = 0 then 'arl.PlannedStartDate as PlannedStart_ID, arl.PlannedStartDate as [Planned Start]'
			when @Option = 1 then 'isnull(arl.PlannedStartDate, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'arl.PlannedStartDate'
			when @Option = 3 then 'a.[Planned Start] ' + @colSort
			when @Option = 4 then 'AOR' else '[Planned Start]' end
		when @colName = 'PLANNED END' or @colName = 'PLANNEDEND_ID' then
			case when @Option = 0 then 'arl.PlannedEndDate as PlannedEnd_ID, arl.PlannedEndDate as [Planned End]'
			when @Option = 1 then 'isnull(arl.PlannedEndDate, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'arl.PlannedEndDate'
			when @Option = 3 then 'a.[Planned End] ' + @colSort
			when @Option = 4 then 'AOR' else '[Planned End]' end
		when @colName = 'ACTUAL START' or @colName = 'ACTUALSTART_ID' then
			case when @Option = 0 then 'aas.ActualStartDate as ActualStart_ID, aas.ActualStartDate as [Actual Start]'
			when @Option = 1 then 'isnull(aas.ActualStartDate, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'aas.ActualStartDate'
			when @Option = 3 then 'a.[Actual Start] ' + @colSort
			when @Option = 4 then 'AOR' else '[Actual Start]' end
		when @colName = 'ACTUAL END' or @colName = 'ACTUALEND_ID' then
			case when @Option = 0 then 'aae.ActualEndDate as ActualEnd_ID, aae.ActualEndDate as [Actual End]'
			when @Option = 1 then 'isnull(aae.ActualEndDate, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'aae.ActualEndDate'
			when @Option = 3 then 'a.[Actual End] ' + @colSort
			when @Option = 4 then 'AOR' else '[Actual End]' end
		--CR FIELDS
		when @colName = 'CR CUSTOMER TITLE' or @colName = 'CRNAME_ID' then
			case when @Option = 0 then 'acr.CRID as CRName_ID, acr.CRName as [CR Customer Title]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.CRName'
			when @Option = 3 then 'a.[CR Customer Title] ' + @colSort
			when @Option = 4 then 'CR' else '[CR Customer Title]' end
		when @colName = 'CR INTERNAL TITLE' or @colName = 'CRTITLE_ID' then
			case when @Option = 0 then 'acr.CRID as CRTITLE_ID, acr.Title AS [CR Internal Title]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.Title'
			when @Option = 3 then 'a.[CR Internal Title] ' + @colSort
			when @Option = 4 then 'CR' else '[CR Internal Title]' end
		when @colName = 'CR DESCRIPTION' or @colName = 'CRDESCRIPTION_ID' then
			case when @Option = 0 then 'acr.CRID as CRDESCRIPTION_ID, acr.Notes AS [CR Description]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.Notes'
			when @Option = 3 then 'a.[CR Description] ' + @colSort
			when @Option = 4 then 'CR' else '[CR Description]' end
		when @colName = 'RATIONALE' or @colName = 'CRRATIONALE_ID' then
			case when @Option = 0 then 'acr.CRID as CRRATIONALE_ID, acr.RATIONALE AS [Rationale]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.Rationale'
			when @Option = 3 then 'a.[Rationale] ' + @colSort
			when @Option = 4 then 'CR' else '[Rationale]' end
		when @colName = 'CUSTOMER IMPACT' or @colName = 'CRCUSTOMERIMPACT_ID' then
			case when @Option = 0 then 'acr.CRID as CRCUSTOMERIMPACT_ID, acr.CustomerImpact AS [Customer Impact]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.CustomerImpact'
			when @Option = 3 then 'a.[Customer Impact] ' + @colSort
			when @Option = 4 then 'CR' else '[Customer Impact]' end
		when @colName = 'CR WEBSYSTEM' or @colName = 'CRWEBSYSTEM_ID' then
			case when @Option = 0 then 'acr.Websystem as CRWEBSYSTEM_ID, acr.Websystem AS [CR Websystem]'
			when @Option = 1 then 'acr.Websystem = ''' + @ID + ''' and '
			when @Option = 2 then 'acr.CRID, acr.Websystem'
			when @Option = 3 then 'a.[CR Websystem] ' + @colSort
			when @Option = 4 then 'CR' else '[CR Websystem]' end
		when @colName = 'CSD REQUIRED NOW' or @colName = 'CRCSDR_ID' then
			case when @Option = 0 then 'acr.CRID as CRCSDR_ID, case when acr.CSDRequiredNow = 1 then ''Yes'' else ''No'' end as [CSD Required Now]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.CSDRequiredNow'
			when @Option = 3 then 'a.[CSD Required Now] ' + @colSort
			when @Option = 4 then 'CR' else '[CSD Required Now]' end
		when @colName = 'RELATED RELEASE' or @colName = 'CRRR_ID' then
			case when @Option = 0 then 'acr.CRID as CRRR_ID, acr.RelatedRelease as [Related Release]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.RelatedRelease'
			when @Option = 3 then 'a.[Related Release] ' + @colSort
			when @Option = 4 then 'CR' else '[RELATED RELEASE]' end
		when @colName = 'SUB GROUP' or @colName = 'CRSUBGROUP_ID' then
			case when @Option = 0 then ' acr.CRID as CRSUBGROUP_ID, acr.SubGroup as [Sub Group]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.SubGroup'
			when @Option = 3 then 'a.[Sub Group] ' + @colSort
			when @Option = 4 then 'CR' else '[Sub Group]' end
		when @colName = 'DESIGN REVIEW' or @colName = 'CRDESIGNREVIEW_ID' then
			case when @Option = 0 then ' acr.CRID as CRDESIGNREVIEW_ID, acr.DesignReview as [Design Review]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.DesignReview'
			when @Option = 3 then 'a.[Design Review] ' + @colSort
			when @Option = 4 then 'CR' else '[Design Review]' end
		when @colName = 'CR ITI POC' or @colName = 'CRITIPOC_ID' then
			case when @Option = 0 then ' acr.CRID as CRITIPOC_ID, lower(acr.ITIPOC) as [CR ITI POC]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, lower(acr.ITIPOC)'
			when @Option = 3 then 'a.[CR ITI POC] ' + @colSort
			when @Option = 4 then 'CR' else '[CR ITI POC]' end
		when @colName = 'CUSTOMER PRIORITY LIST' or @colName = 'CRCPL_ID' then
			case when @Option = 0 then ' acr.CRID as CRCPL_ID, acr.CustomerPriorityList as [Customer Priority List]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.CustomerPriorityList'
			when @Option = 3 then 'a.[Customer Priority List] ' + @colSort
			when @Option = 4 then 'CR' else '[Customer Priority List]' end
		when @colName = 'GOVERNMENT CSRD #' or @colName = 'CRGCSRD_ID' then
			case when @Option = 0 then ' acr.CRID as CRGCSRD_ID, acr.GovernmentCSRD as [Government CSRD #]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.GovernmentCSRD'
			when @Option = 3 then 'a.[Government CSRD #] ' + @colSort
			when @Option = 4 then 'CR' else '[Government CSRD #]' end
		when @colName = 'ITI PRIORITY' or @colName = 'ITI_PRIORITY_ID' then
			case when @Option = 0 then ' acr.CRID as ITI_PRIORITY_ID, acr.ITIPriority as [ITI Priority]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.ITIPriority'
			when @Option = 3 then 'a.[ITI Priority] ' + @colSort
			when @Option = 4 then 'CR' else '[ITI Priority]' end
		when @colName = 'CYBER/ISMT' or @colName = 'CYBERISMT_ID' then
			case when @Option = 0 then 'acr.CRID as CyberISMT_ID, case acr.CyberISMT when 1 then ''Yes'' else ''No'' end as [Cyber/ISMT]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.CyberISMT'
			when @Option = 3 then 'a.[Cyber/ISMT] ' + @colSort
			when @Option = 4 then 'CR' else '[Cyber/ISMT]' end
		when @colName = 'PRIMARY SR' or @colName = 'PRIMARYSR_ID' then
			case when @Option = 0 then ' acr.CRID as PRIMARYSR_ID, acr.PrimarySR as [Primary SR]'
			when @Option = 1 then 'isnull(acr.CRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'acr.CRID, acr.PrimarySR'
			when @Option = 3 then 'a.[Primary SR] ' + @colSort
			when @Option = 4 then 'CR' else '[Primary SR]' end
		when @colName = 'CONTRACT' or @colName = 'CONTRACT_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'upper(a.[Contract]) ' + @colSort
			when @Option = 4 then 'TASK' else '[Contract]' end
		--SR FIELDS 
		when @colName = 'SR #' or @colName = 'SR_ID' then
			case when @Option = 0 then ' asr.SRID as SR_ID, asr.SRID as [SR #]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID'
			when @Option = 3 then 'a.[SR #] ' + @colSort
			when @Option = 4 then 'SR' else '[SR #]' end
		when @colName = 'SR SUBMITTED BY' or @colName = 'SRSUBMITTEDBY_ID' then
			case when @Option = 0 then ' asr.SRID as SRSUBMITTEDBY_ID, lower(asr.SubmittedBy) as [SR Submitted By]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID, lower(asr.SubmittedBy)'
			when @Option = 3 then 'a.[SR Submitted By] ' + @colSort
			when @Option = 4 then 'SR' else '[SR Submitted By]' end
		when @colName = 'SR SUBMITTED DATE' or @colName = 'SRSUBMITTEDDATE_ID' then
			case when @Option = 0 then ' asr.SRID as SRSUBMITTEDDATE_ID, asr.SubmittedDate as [SR Submitted Date]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID, asr.SubmittedDate'
			when @Option = 3 then 'a.[SR Submitted Date] ' + @colSort
			when @Option = 4 then 'SR' else '[SR Submitted Date]' end
		when @colName = 'SR KEYWORDS' or @colName = 'SRKEYWORDS_ID' then
			case when @Option = 0 then ' asr.SRID as SRKEYWORDS_ID, asr.Keywords as [SR Keywords]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID, asr.Keywords'
			when @Option = 3 then 'a.[SR Keywords] ' + @colSort
			when @Option = 4 then 'SR' else '[SR Keywords]' end
		when @colName = 'SR WEBSYSTEM' or @colName = 'SRWEBSYSTEM_ID' then
			case when @Option = 0 then 'asr.Websystem AS SRWEBSYSTEM_ID, asr.Websystem AS [SR Websystem]'
			when @Option = 1 then 'asr.Websystem = ''' + @ID + ''' and '
			when @Option = 2 then 'asr.Websystem'
			when @Option = 3 then 'a.[SR Websystem] ' + @colSort
			when @Option = 4 then 'SR' else '[SR Websystem]' end
		when @colName = 'SR STATUS' or @colName = 'SRSTATUS_ID' then
			case when @Option = 0 then ' asr.SRID as SRSTATUS_ID, asr.[Status] as [SR Status]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID, asr.[Status]'
			when @Option = 3 then 'a.[SR Status] ' + @colSort
			when @Option = 4 then 'SR' else '[SR Status]' end
		when @colName = 'SR TYPE' or @colName = 'SRTYPE_ID' then
			case when @Option = 0 then ' asr.SRID as SRTYPE_ID, asr.SRType as [SR Type]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID, asr.SRType'
			when @Option = 3 then 'a.[SR Type] ' + @colSort
			when @Option = 4 then 'SR' else '[SR Type]' end
		when @colName = 'SR PRIORITY' or @colName = 'SRPRIORITY_ID' then
			case when @Option = 0 then ' asr.SRID as SRPRIORITY_ID, asr.[Priority] as [SR Priority]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID, asr.[Priority]'
			when @Option = 3 then 'a.[SR Priority] ' + @colSort
			when @Option = 4 then 'SR' else '[SR Priority]' end
		when @colName = 'SR LCMB' or @colName = 'SRLCMB_ID' then
			case when @Option = 0 then ' asr.SRID as SRLCMB_ID, case when asr.LCMB = 1 then ''Yes'' else ''No'' end as [SR LCMB]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID, asr.LCMB'
			when @Option = 3 then 'a.[SR LCMB] ' + @colSort
			when @Option = 4 then 'SR' else '[SR LCMB]' end
		when @colName = 'SR ITI' or @colName = 'SRITI_ID' then
			case when @Option = 0 then ' asr.SRID as SRITI_ID, case when asr.ITI = 1 then ''Yes'' else ''No'' end as [SR ITI]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID, asr.ITI'
			when @Option = 3 then 'a.[SR ITI] ' + @colSort
			when @Option = 4 then 'SR' else '[SR ITI]' end
		when @colName = 'SR ITI POC' or @colName = 'SRITIPOC_ID' then
			case when @Option = 0 then ' asr.SRID as SRITIPOC_ID, lower(asr.ITIPOC) as [SR ITI POC]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID, lower(asr.ITIPOC) '
			when @Option = 3 then 'a.[SR ITI POC] ' + @colSort
			when @Option = 4 then 'SR' else '[SR ITI POC]' end
		when @colName = 'SR DESCRIPTION' or @colName = 'SRDESCRIPTION_ID' then
			case when @Option = 0 then ' asr.SRID as SRDESCRIPTION_ID, asr.[Description] as [SR Description]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID, asr.[Description]'
			when @Option = 3 then 'a.[SR Description] ' + @colSort
			when @Option = 4 then 'SR' else '[SR Description]' end
		when @colName = 'LAST REPLY' or @colName = 'SRLASTREPLY_ID' then
			case when @Option = 0 then ' asr.SRID as SRLASTREPLY_ID, asr.LastReply as [Last Reply]'
			when @Option = 1 then 'asr.SRID = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID, asr.LastReply'
			when @Option = 3 then 'a.[Last Reply] ' + @colSort
			when @Option = 4 then 'SR' else '[Last Reply]' end
		--TASK FIELDS
		when @colName = 'AFFILIATED' or @colName = 'AFFILIATED_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.Affiliated ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'CONTRACT ALLOCATION ASSIGNMENT' or @colName = 'CONTRACTALLOCATIONASSIGNMENT_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Contract Allocation Assignment] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'CONTRACT ALLOCATION GROUP' or @colName = 'CONTRACTALLOCATIONGROUP_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Contract Allocation Group] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'ASSIGNED TO' or @colName = 'ASSIGNEDTO_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Assigned To] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'FUNCTIONALITY' or @colName = 'FUNCTIONALITY_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.Functionality ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'WORK ACTIVITY' or @colName = 'WORKACTIVITY_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Work Activity] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'ORGANIZATION (ASSIGNED TO)' or @colName = 'ORGANIZATION_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Organization (Assigned To)] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'PDD TDR' or @colName = 'PDDTDR_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[PDD TDR] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'PERCENT COMPLETE' or @colName = 'PERCENTCOMPLETE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Percent Complete] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'BUS. RANK' or @colName = 'PRIMARYBUSRANK_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Bus. Rank] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'PRIMARY BUS. RESOURCE' or @colName = 'PRIMARYBUSRESOURCE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Primary Bus. Resource] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'TECH. RANK' or @colName = 'PRIMARYTECHRANK_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Tech. Rank] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'CUSTOMER RANK' or @colName = 'CUSTOMERRANK_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Customer Rank] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'ASSIGNED TO RANK' or @colName = 'ASSIGNEDTORANK_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Assigned To Rank] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'PRIMARY RESOURCE' or @colName = 'PRIMARYTECHRESOURCE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Primary Resource] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'PRIORITY' or @colName = 'PRIORITY_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Priority] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'PRODUCT VERSION' or @colName = 'PRODUCTVERSION_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Product Version] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'PRODUCTION STATUS' or @colName = 'PRODUCTIONSTATUS_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Production Status] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'SECONDARY BUS. RESOURCE' or @colName = 'SECONDARYBUSRESOURCE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Secondary Bus. Resource] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'SECONDARY TECH. RESOURCE' or @colName = 'SECONDARYTECHRESOURCE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Secondary Tech. Resource] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'STATUS' or @colName = 'STATUS_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Status] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'SUBMITTED BY' or @colName = 'SUBMITTEDBY_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Submitted By] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'SYSTEM(TASK)' or @colName = 'SYSTEMTASK_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.SYSTEMSUITESORT_ID, a.SYSTEMSORT_ID, a.[System(Task)] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'SYSTEM SUITE' or @colName = 'SYSTEMSUITE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.SUITESORT_ID, a.[System Suite] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'WORK AREA' or @colName = 'WORKAREA_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Work Area] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'TASK' or @colName = 'TASK_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Task] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'TASK TITLE' or @colName = 'TASKTITLE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Task Title] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'TITLE' or @colName = 'TITLE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Title] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'WORK TASK' or @colName = 'WORKTASK_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Work Task] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'PRIMARY TASK TITLE' or @colName = 'PRIMARYTASK_TITLE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Primary Task Title] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'PRIMARY TASK' or @colName = 'PRIMARYTASK_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Primary Task] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'WORK REQUEST' or @colName = 'WORKREQUEST_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Work Request] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'RESOURCE GROUP' or @colName = 'RESOURCEGROUP_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Resource Group] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'AOR RELEASE/DEPLOYMENT MGMT' or @colName = 'AOR_RELEASE_MGMT_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[AOR Release/Deployment MGMT] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'AOR WORKLOAD MGMT' or @colName = 'AOR_WORKLOAD_MGMT_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[AOR Workload MGMT] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'IN PROGRESS DATE' or @colName = 'INPROGRESSDATE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[In Progress Date] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'DEPLOYED DATE' or @colName = 'DEPLOYEDDATE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Deployed Date] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'READY FOR REVIEW DATE' or @colName = 'READYFORREVIEWDATE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[Ready For Review Date] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end
		when @colName = 'CLOSED DATE' or @colName = 'CLOSEDDATE_ID' then
			case when @Option = 0 then NULL
			when @Option = 1 then NULL
			when @Option = 2 then NULL
			when @Option = 3 then 'a.[CLOSED Date] ' + @colSort
			when @Option = 4 then 'TASK' else NULL end

		----Sub-Task
		--when @colName = 'SUB-TASK' or @colName = 'SUBTASK_ID' then
		--	case when @Option = 0 then 'wit.WORKITEM_TASKID as SUBTASK_ID, convert(nvarchar(10), wit.WORKITEMID) + '' - '' + convert(nvarchar(10), wit.TASK_NUMBER)  as [Sub-Task]'
		--	when @Option = 1 then 'wit.WORKITEM_TASKID = ' + @ID + ' and '
		--	when @Option = 2 then 'wit.WORKITEM_TASKID, wit.WORKITEMID, wit.TASK_NUMBER' 
		--	when @Option = 3 then 'a.[Sub-Task] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK TITLE' or @colName = 'SUBTASKTITLE_ID' then
		--	case when @Option = 0 then 'wit.WORKITEMID as SUBTASKTITLE_ID, wit.TITLE as [Sub-Task Title]'
		--	when @Option = 1 then 'wit.WORKITEMID = ' + @ID + ' and '
		--	when @Option = 2 then 'wit.WORKITEMID, wit.TITLE' 
		--	when @Option = 3 then 'a.[Sub-Task Title] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK DESCRIPTION' or @colName = 'SUBTASKDESCRIPTION_ID' then
		--	case when @Option = 0 then 'wit.WORKITEMID as SUBTASKDESCRIPTION_ID, wit.[DESCRIPTION] as [Sub-Task Description]'
		--	when @Option = 1 then 'wit.WORKITEMID = ' + @ID + ' and '
		--	when @Option = 2 then 'wit.WORKITEMID, wit.[DESCRIPTION]' 
		--	when @Option = 3 then 'a.[Sub-Task Description] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK ASSIGNED TO' or @colName = 'SUBTASKASSIGNEDTO_ID' then
		--	case when @Option = 0 then 'stato.WTS_RESOURCEID as SUBTASKASSIGNEDTO_ID, stato.USERNAME as [Sub-Task Assigned To]'
		--	when @Option = 1 then 'stato.WTS_RESOURCEID = ' + @ID + ' and '
		--	when @Option = 2 then 'stato.WTS_RESOURCEID, stato.USERNAME'
		--	when @Option = 3 then 'a.[Sub-Task Assigned To] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK STATUS' or @colName = 'SUBTASKSTATUS_ID' then
		--	case when @Option = 0 then 'sts.STATUSID as SUBTASKSTATUS_ID, sts.[STATUS] as [Sub-Task Status]'
		--	when @Option = 1 then 'sts.STATUSID = ' + @ID + ' and '
		--	when @Option = 2 then 'sts.STATUSID, sts.[STATUS]'
		--	when @Option = 3 then 'a.[Sub-Task Status] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK TECH. RANK' or @colName = 'SUBTASKPRIMARYTECHRANK_ID' then
		--	case when @Option = 0 then 'wit.[SORT_ORDER] as SUBTASKPRIMARYTECHRANK_ID, wit.[SORT_ORDER] as [Sub-Task Tech. Rank]' 
		--	when @Option = 1 then 'isnull(wit.[SORT_ORDER], -999) = ' + @ID + ' and '
		--	when @Option = 2 then 'wit.[SORT_ORDER]' 
		--	when @Option = 3 then 'a.[Sub-Task Tech. Rank] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK CUSTOMER RANK' or @colName = 'SUBTASKCUSTOMERRANK_ID' then
		--	case when @Option = 0 then 'wit.[BusinessRank] as SUBTASKCUSTOMERRANK_ID, wit.[BusinessRank] as [Sub-Task Customer Rank]' 
		--	when @Option = 1 then 'isnull(wit.[BusinessRank], -999) = ' + @ID + ' and '
		--	when @Option = 2 then 'wit.[BusinessRank]'  
		--	when @Option = 3 then 'a.[Sub-Task Customer Rank] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK ASSIGNED TO RANK' or @colName = 'SUBTASKASSIGNEDTORANK_ID' then
		--	case when @Option = 0 then 'wit.AssignedToRankID as SUBTASKASSIGNEDTORANK_ID, statrp.[PRIORITY] as [Sub-Task Assigned To Rank]' 
		--	when @Option = 1 then 'isnull(wit.AssignedToRankID, -999) = ' + @ID + ' and '
		--	when @Option = 2 then 'wit.AssignedToRankID, statrp.[PRIORITY]' 
		--	when @Option = 3 then 'a.[Sub-Task Assigned To Rank] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK PRIMARY RESOURCE' or @colName = 'SUBTASKPRIMARYTECHRESOURCE_ID' then
		--	case when @Option = 0 then 'stptr.WTS_RESOURCEID as SUBTASKPRIMARYTECHRESOURCE_ID, stptr.USERNAME as [Sub-Task Primary Resource]'
		--	when @Option = 1 then 'isnull(stptr.WTS_RESOURCEID, 0) = ' + @ID + ' and '
		--	when @Option = 2 then 'stptr.WTS_RESOURCEID, stptr.USERNAME'
		--	when @Option = 3 then 'a.[Sub-Task Primary Resource] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK PRIORITY' or @colName = 'SUBTASKPRIORITY_ID' then
		--	case when @Option = 0 then 'stp.PRIORITYID as SUBTASKPRIORITY_ID, stp.[PRIORITY] as [Sub-Task Priority]'
		--	when @Option = 1 then 'isnull(stp.PRIORITYID, 0) = ' + @ID + ' and '
		--	when @Option = 2 then 'stp.PRIORITYID, stp.[PRIORITY]'
		--	when @Option = 3 then 'a.[Sub-Task Priority] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK PERCENT COMPLETE' or @colName = 'SUBTASKPERCENTCOMPLETE_ID' then
		--	case when @Option = 0 then 'wit.COMPLETIONPERCENT as SUBTASKPERCENTCOMPLETE_ID, wit.COMPLETIONPERCENT as [Sub-Task Percent Complete] ' 
		--	when @Option = 1 then 'isnull(wit.COMPLETIONPERCENT, -999) = ' + @ID  + ' and '
		--	when @Option = 2 then 'wit.COMPLETIONPERCENT' 
		--	when @Option = 3 then 'a.[Sub-Task Percent Complete] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK BUS. RANK' or @colName = 'SUBTASKPRIMARYBUSRANK_ID' then
		--	case when @Option = 0 then 'wit.[BusinessRank] as SUBTASKPRIMARYBUSRANK_ID, wit.[BusinessRank] as [Sub-Task Bus. Rank]'
		--	when @Option = 1 then 'isnull(wit.[BusinessRank], -999) = ' + @ID  + ' and '
		--	when @Option = 2 then 'wit.[BusinessRank]' 
		--	when @Option = 3 then 'a.[Sub-Task Bus. Rank] ' + @colSort
		--	when @Option = 4 then 'SUB-TASK' else NULL end
		--when @colName = 'SUB-TASK SR NUMBER' or @colName = 'SUBTASKSRNUMBER_ID' then
		--	case when @Option = 0 then 'wit.SRNumber as SUBTASKSRNUMBER_ID, wit.SRNumber as [Sub-Task SR Number] ' 
		--	when @Option = 1 then 'isnull(wit.SRNumber, -999) = ' + @ID  + ' and '
		--	when @Option = 2 then  'wit.SRNumber' 
		--	when @Option = 3 then '[Sub-Task SR Number] ' + @colSort
		--	else '[Sub-Task SR Number]' end
		else NULL end;

	return @columns;
end;
GO

