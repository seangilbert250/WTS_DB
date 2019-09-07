USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[RQMT_Get_Columns]    Script Date: 10/12/2018 11:50:21 AM ******/
DROP FUNCTION [dbo].[RQMT_Get_Columns]
GO

/****** Object:  UserDefinedFunction [dbo].[RQMT_Get_Columns]    Script Date: 10/12/2018 11:50:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


















CREATE function [dbo].[RQMT_Get_Columns]
(
	@ColumnName nvarchar(100),
	@Option int = 0,
	@ID nvarchar(100) = '',
	@Sort nvarchar(100) = ''
)
returns nvarchar(2000)
as
begin
	-- @Option (0=select, 1=where(only called as a drilldown), 2=groupby, 3=orderby, 6=countcolumns) -- note: options 4 and 5 are currently removed
	-- NOTE: ALL COLUMNS IN OPTIONS 0, 3, 4, AND 6 MUST USE [] BECAUSE WE USE BRACKETS TO FIX COLUMN NAMES AT THE END OF THE FUNCTION (THE FIXES HAVE TO DO WITH COUNT COLUMNS)

	declare @colName nvarchar(1000);
	declare @colSort nvarchar(100);
	declare @columns nvarchar(2000);
	declare @countColumnMode bit = 0

	if @ColumnName like '%_COUNTCOLUMN' 
	begin
		set @countColumnMode = 1
		set @ColumnName = replace(@ColumnName, '_COUNTCOLUMN', '')
	end
	
	set @colName = upper(@ColumnName);
	set @colSort = replace(replace(@Sort, 'Ascending', 'asc'), 'Descending', 'desc');
	
	set @columns = 
		case

		when @colName = 'RQMT #' or @colName = 'RQMT_ID' then
			case when @Option = 0 then 'r.RQMTID as [RQMT_ID], r.RQMTID as [RQMT #]'
			when @Option = 1 then 'r.[RQMTID] = ' + @ID + ' and '
			when @Option = 2 then 'r.[RQMTID]'
			when @Option = 3 then 'a.[RQMT_ID] ' + @colSort
			when @Option = 6 then 'a.[RQMT_ID]'
			else '[RQMT #]' end

		when @colName = 'RQMT' or @colName = 'RQMTNAME_ID' then
			case when @Option = 0 then 'r.RQMTID as [RQMTNAME_ID], r.RQMT as [RQMT], r.Universal as [RQMTUNIVERSAL_HDN]'
			when @Option = 1 then 'r.[RQMTID] = ' + @ID + ' and '
			when @Option = 2 then 'r.[RQMTID], r.[RQMT], r.[Universal]'
			when @Option = 3 then 'a.[RQMT] ' + @colSort
			when @Option = 6 then 'a.[RQMTNAME_ID]'
			else '[RQMT]' end

		when @colName = 'RQMT Primary #' or @colName = 'RQMTPRIMARY_ID' then
			case when @Option = 0 then 'r.RQMTID as [RQMTPRIMARY_ID], r.RQMTID as [RQMT PRIMARY #]'
			when @Option = 1 then 'r.[RQMTID] = ' + @ID + ' and '
			when @Option = 2 then 'r.[RQMTID]'
			when @Option = 3 then 'a.[RQMT PRIMARY #] ' + @colSort
			when @Option = 6 then 'a.[RQMTPRIMARY_ID]'
			else '[RQMT PRIMARY #]' end

		when @colName = 'RQMT Primary' or @colName = 'RQMTPRIMARYNAME_ID' then
			case when @Option = 0 then 'r.RQMTID as [RQMTPRIMARYNAME_ID], r.RQMT as [RQMT PRIMARY], r.Universal as [RQMTPRIMARYUNIVERSAL_HDN]'
			when @Option = 1 then 'r.[RQMTID] = ' + @ID + ' and '
			when @Option = 2 then 'r.[RQMTID], r.[RQMT], r.[Universal]'
			when @Option = 3 then 'a.[RQMT PRIMARY] ' + @colSort
			when @Option = 6 then 'a.[RQMTPRIMARYNAME_ID]'
			else '[RQMT Primary]' end

		when @colName = 'RQMTPRIMARYCOMBINEDNUMBER' or @colName = 'RQMTPRIMARYCOMBINEDNUMBER_ID' then
			case when @Option = 0 then 'isnull(rparent.RQMTID, r.RQMTID) as [RQMTPRIMARYCOMBINEDNUMBER_ID], isnull(rparent.RQMTID, r.RQMTID) as [RQMT PRIMARY #]'
			when @Option = 1 then '(case when rparent.[RQMTID] is null then 0 else rparent.[RQMTID] end) = (case when rparent.[RQMTID] is null then 0 else ' + @ID + ' end) and '
			when @Option = 2 then 'isnull(rparent.[RQMTID], r.[RQMTID])'
			when @Option = 3 then 'a.[RQMT PRIMARY #] ' + @colSort
			when @Option = 6 then 'a.[RQMTPRIMARYCOMBINEDNUMBER_ID]'
			else '[RQMT PRIMARY #]' end

		when @colName = 'RQMTPRIMARYCOMBINEDNAME' or @colName = 'RQMTPRIMARYCOMBINEDNAME_ID' then
			case when @Option = 0 then 'isnull(rparent.RQMTID, r.RQMTID) as [RQMTPRIMARYCOMBINEDNAME_ID], isnull(rparent.RQMT, r.RQMT) as [RQMT PRIMARY], isnull(rparent.Universal, r.Universal) as [RQMTPRIMARYUNIVERSAL_HDN]'
			when @Option = 1 then '(case when rparent.[RQMTID] is null then 0 else rparent.[RQMTID] end) = (case when rparent.[RQMTID] is null then 0 else ' + @ID + ' end) and '
			when @Option = 2 then 'isnull(rparent.[RQMTID], r.[RQMTID]), isnull(rparent.[RQMT], r.[RQMT]), isnull(rparent.[Universal], r.[Universal])'
			when @Option = 3 then 'a.[RQMT PRIMARY] ' + @colSort
			when @Option = 6 then 'a.[RQMTPRIMARYCOMBINEDNAME_ID]'
			else '[RQMT Primary]' end

		when @colName = 'RQMTNESTEDNUMBER' or @colName = 'RQMTNESTEDNUMBER_ID' then
			case when @Option = 0 then 'r.RQMTID as [RQMTNESTEDNUMBER_ID], r.RQMTID as [RQMT #]'
			when @Option = 1 then 'r.[RQMTID] = ' + @ID + ' and '
			when @Option = 2 then 'r.[RQMTID]'
			when @Option = 3 then 'a.[RQMTNESTEDNUMBER_ID] ' + @colSort
			when @Option = 6 then 'a.[RQMTNESTEDNUMBER_ID]'
			else '[RQMT #]' end

		when @colName = 'RQMTNESTED' or @colName = 'RQMTNESTEDNAME_ID' then
			case when @Option = 0 then 'r.RQMTID as [RQMTNESTEDNAME_ID], r.RQMT as [RQMT], r.Universal as [RQMTUNIVERSAL_HDN]'
			when @Option = 1 then 'r.[RQMTID] = ' + @ID + ' and '
			when @Option = 2 then 'r.[RQMTID], r.[RQMT], r.[Universal]'
			when @Option = 3 then 'a.[RQMT] ' + @colSort
			when @Option = 6 then 'a.[RQMTNESTEDNAME_ID]'
			else '[RQMT]' end

		when @colName = 'RQMTPRIMARYNESTEDNUMBER' or @colName = 'RQMTPRIMARYNESTEDNUMBER_ID' or @colName = 'RQMTPRIMARYNESTEDNUMBER_PARENT_ID' then
			case when @Option = 0 then 'r.RQMTID as [RQMTPRIMARYNESTEDNUMBER_ID], r.RQMTID as [RQMT PRIMARY #], rparent.RQMTID as [RQMTPRIMARYNESTEDNUMBER_PARENT_ID]' -- this last column is needed for grouping when count columns are needed
			when @Option = 1 then (case when @colName = 'RQMTPRIMARYNESTEDNUMBER_ID' then 'rparent.RQMTID = ' + @ID else '1=1' end) + ' and '
			when @Option = 2 then 'r.[RQMTID], rparent.[RQMTID]'
			when @Option = 3 then 'a.[RQMT PRIMARY #] ' + @colSort
			when @Option = 6 then 'a.[RQMTPRIMARYNESTEDNUMBER_PARENT_ID]'
			else '[RQMT PRIMARY #]' end

		when @colName = 'RQMTPRIMARYNESTED' or @colName = 'RQMTPRIMARYNESTEDNAME_ID' or @colName = 'RQMTPRIMARYNESTEDNAME_PARENT_ID' then
			case when @Option = 0 then 'r.RQMTID as [RQMTPRIMARYNESTEDNAME_ID], r.RQMT as [RQMT PRIMARY], r.Universal as [RQMTPRIMARYUNIVERSAL_HDN], rparent.RQMTID as [RQMTPRIMARYNESTEDNAME_PARENT_ID]' -- this last column is needed for grouping when count columns are needed
			when @Option = 1 then (case when @colName = 'RQMTPRIMARYNESTEDNAME_ID' then 'rparent.RQMTID = ' + @ID else '1=1' end) + ' and '
			when @Option = 2 then 'r.[RQMTID], r.RQMT, r.Universal, rparent.[RQMTID]'
			when @Option = 3 then 'a.[RQMT PRIMARY] ' + @colSort
			when @Option = 6 then 'a.[RQMTPRIMARYNESTEDNAME_PARENT_ID]'
			else '[RQMT PRIMARY]' end
			

		when @colName = 'Outline Index' then
			case when @Option = 0 then '(case when rsrs.ParentRQMTSet_RQMTSystemID = 0 then convert(varchar(10), rsrs.OutlineIndex) + ''.0'' else convert(varchar(10), rsrsparent.OutlineIndex) + ''.'' + convert(varchar(10), rsrs.OutlineIndex) end) as [Outline Index]' -- we drill down in the context of the rqmt, not the rqmt parent
			when @Option = 1 then ''
			when @Option = 2 then '(case when rsrs.ParentRQMTSet_RQMTSystemID = 0 then convert(varchar(10), rsrs.OutlineIndex) + ''.0'' else convert(varchar(10), rsrsparent.OutlineIndex) + ''.'' + convert(varchar(10), rsrs.OutlineIndex) end)'
			when @Option = 3 then 'cast(a.[Outline Index] as numeric(18, 2)) ' + @colSort
			when @Option = 4 then ''
			else '[Outline Index]'
			end		

		when @colName = 'Outline Index Child' then
			case when @Option = 0 then '(case when rsrs.ParentRQMTSet_RQMTSystemID = 0 then ''0'' else convert(varchar(10), rsrs.OutlineIndex) end) as [Outline Index Child]' -- we drill down in the context of the rqmt, not the rqmt parent
			when @Option = 1 then ''
			when @Option = 2 then '(case when rsrs.ParentRQMTSet_RQMTSystemID = 0 then ''0'' else convert(varchar(10), rsrs.OutlineIndex) end)'
			when @Option = 3 then 'cast(a.[Outline Index Child] as numeric(18, 2)) ' + @colSort
			when @Option = 4 then ''
			else '[Outline Index Child]'
			end	

		when @colName = 'Outline Index Parent' then
			case when @Option = 0 then '(case when rsrs.ParentRQMTSet_RQMTSystemID = 0 then convert(varchar(10), rsrs.OutlineIndex) else convert(varchar(10), rsrsparent.OutlineIndex) end) as [Outline Index Parent]' -- we drill down in the context of the rqmt, not the rqmt parent
			when @Option = 1 then ''
			when @Option = 2 then '(case when rsrs.ParentRQMTSet_RQMTSystemID = 0 then convert(varchar(10), rsrs.OutlineIndex) else convert(varchar(10), rsrsparent.OutlineIndex) end)'
			when @Option = 3 then 'cast(a.[Outline Index Parent] as numeric(18, 2)) ' + @colSort
			when @Option = 4 then ''
			else '[Outline Index Parent]'
			end		
				
		when @colName = 'RQMT Set' or @colName = 'RQMTSET_ID' then
			case when @Option = 0 then 'rset.RQMTSetID as [RQMTSET_ID], convert(varchar(10), rset.RQMTSetID) + '' - '' + rsetname.RQMTSetName as [RQMT Set]'
			when @Option = 1 then 'isnull(rset.RQMTSetID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rset.RQMTSetID, rsetname.RQMTSetName'
			when @Option = 3 then 'a.[RQMT Set] ' + @colSort
			when @Option = 6 then 'a.[RQMTSET_ID]'
			else '[RQMT Set Name]' end			
		when @colName = 'RQMT Type' or @colName = 'RQMTTYPE_ID' then
			case when @Option = 0 then 'rt.RQMTTypeID as [RQMTTYPE_ID], rt.RQMTType as [RQMT Type]'
			when @Option = 1 then 'isnull(rt.RQMTTypeID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rt.RQMTTypeID, rt.RQMTType'
			when @Option = 3 then 'a.[RQMT Type] ' + @colSort
			when @Option = 6 then 'a.[RQMTTYPE_ID]'
			else '[RQMT Type]' end
		when @colName = 'SYSTEM SUITE' or @colName = 'SYSTEMSUITE_ID' then
			case when @Option = 0 then 'syss.WTS_SYSTEM_SUITEID as [SYSTEMSUITE_ID], syss.WTS_SYSTEM_SUITE as [System Suite]'
			when @Option = 1 then 'isnull(syss.WTS_SYSTEM_SUITEID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'syss.WTS_SYSTEM_SUITEID, syss.WTS_SYSTEM_SUITE'
			when @Option = 3 then 'a.[System Suite] ' + @colSort
			when @Option = 6 then 'a.[SYSTEMSUITE_ID]'
			else '[System Suite]' end
		when @colName = 'SYSTEM' or @colName = 'SYSTEM_ID' then
			case when @Option = 0 then 'sys.WTS_SYSTEMID as [SYSTEM_ID], sys.WTS_SYSTEM as [System]'
			when @Option = 1 then 'isnull(sys.WTS_SYSTEMID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'sys.WTS_SYSTEMID, sys.WTS_SYSTEM'
			when @Option = 3 then 'a.[System] ' + @colSort
			when @Option = 6 then 'a.[SYSTEM_ID]'
			else '[System]' end
		when @colName = 'WORK AREA' or @colName = 'WORKAREA_ID' then
			case when @Option = 0 then 'wa.WorkAreaID as [WORKAREA_ID], wa.WorkArea as [Work Area]'
			when @Option = 1 then 'isnull(wa.WorkAreaID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'wa.WorkAreaID, wa.WorkArea'
			when @Option = 3 then 'a.[Work Area] ' + @colSort
			when @Option = 6 then 'a.[WORKAREA_ID]'
			else '[Work Area]' end
		when @colName = 'Description' or @colName = 'DESCRIPTION_ID' then
			case when @Option = 0 then 'rd.RQMTDescriptionID as [DESCRIPTION_ID], rd.RQMTDescription + '' ('' + rdt.RQMTDescriptionType + '')'' as [Description]'
			when @Option = 1 then 'isnull(rd.RQMTDescriptionID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rd.RQMTDescriptionID, rd.RQMTDescription, rdt.RQMTDescriptionType'
			when @Option = 3 then 'a.[Description] ' + @colSort
			when @Option = 6 then 'a.[DESCRIPTION_ID]'
			else '[Description]' end
		when @colName = 'RQMT Status' or @colName = 'RQMTSTATUS_ID' then
			case when @Option = 0 then 'ra_status.RQMTAttributeID as [RQMTSTATUS_ID], ra_status.RQMTAttribute as [RQMT Status]'
			when @Option = 1 then 'isnull(ra_status.RQMTAttributeID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ra_status.RQMTAttributeID, ra_status.RQMTAttribute'
			when @Option = 3 then 'a.[RQMT Status] ' + @colSort
			when @Option = 6 then 'a.[RQMTSTATUS_ID]'
			else '[RQMT Status]' end
		when @colName = 'RQMT Stage' or @colName = 'RQMTSTAGE_ID' then
			case when @Option = 0 then 'ra_stage.RQMTAttributeID as [RQMTSTAGE_ID], ra_stage.RQMTAttribute as [RQMT Stage]'
			when @Option = 1 then 'isnull(ra_stage.RQMTAttributeID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ra_stage.RQMTAttributeID, ra_stage.RQMTAttribute'
			when @Option = 3 then 'a.[RQMT Stage] ' + @colSort
			when @Option = 6 then 'a.[RQMTSTAGE_ID]'
			else '[RQMT Stage]' end
		when @colName = 'RQMT Accepted' or @colName = 'RQMTACCEPTED_ID' then
			case when @Option = 0 then 'rs.RQMTAccepted as [RQMTACCEPTED_ID], CAST(rs.RQMTAccepted AS int) as [Accepted]'
			when @Option = 1 then 'isnull(rs.RQMTAccepted, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rs.RQMTAccepted'
			when @Option = 3 then 'a.[Accepted] ' + @colSort
			when @Option = 6 then 'a.[RQMTACCEPTED_ID]'
			else '[Accepted]' end
		when @colName = 'RQMT Criticality' or @colName = 'RQMTCRITICALITY_ID' then
			case when @Option = 0 then 'ra_critical.RQMTAttributeID as [RQMTCRITICALITY_ID], ra_critical.RQMTAttribute as [Criticality]'
			when @Option = 1 then 'isnull(ra_critical.RQMTAttributeID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ra_critical.RQMTAttributeID, ra_critical.RQMTAttribute'
			when @Option = 3 then 'a.[Criticality] ' + @colSort
			when @Option = 6 then 'a.[RQMTCRITICALITY_ID]'
			else '[Criticality]' end
		when @colName = 'RQMT Defects' or @colName = 'RQMTSYSTEMDEFECT_ID' then
			case when @Option = 0 then 'rsd.RQMTSystemDefectID as [RQMTSYSTEMDEFECT_ID], rsd.Description + '' ('' + ra_defect_impact.RQMTAttribute + ''/'' + isnull(ra_defect_stage.RQMTAttribute, ''None'') + '')'' as [Defects]'
			when @Option = 1 then 'isnull(rsd.RQMTSystemDefectID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rsd.RQMTSystemDefectID, rsd.Description, ra_defect_impact.RQMTAttribute, ra_defect_stage.RQMTAttribute'
			when @Option = 3 then 'a.[Defects] ' + @colSort
			when @Option = 6 then 'a.[RQMTSYSTEMDEFECT_ID]'
			else '[Defects]' 
			end
		when @colName = 'RQMT Defect Description' or @colName = 'RQMTSYSTEMDEFECTDESCRIPTION_ID' then
			case when @Option = 0 then 'rsdinner.RQMTSystemDefectID as [RQMTSYSTEMDEFECTDESCRIPTION_ID], rsdinner.Description as [Defect Description]'
			when @Option = 1 then 'isnull(rsdinner.RQMTSystemDefectID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rsdinner.RQMTSystemDefectID, rsdinner.Description'
			when @Option = 3 then 'a.[Defect Description] ' + @colSort
			when @Option = 6 then 'a.[RQMTSYSTEMDEFECTDESCRIPTION_ID]'
			else '[Defect Description]' 
			end
		when @colName = 'RQMT Defect Impact' or @colName = 'RQMTSYSTEMDEFECTIMPACT_ID' then
			case when @Option = 0 then 'rsdinner.ImpactID as [RQMTSYSTEMDEFECTIMPACT_ID], ra_defect_impact_inner.RQMTAttribute as [Defect Impact]'
			when @Option = 1 then 'isnull(rsdinner.ImpactID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rsdinner.ImpactID, ra_defect_impact_inner.RQMTAttribute'
			when @Option = 3 then 'a.[Defect Impact] ' + @colSort
			when @Option = 6 then 'a.[RQMTSYSTEMDEFECTIMPACT_ID]'
			else '[Defect Impact]' 
			end			
		when @colName = 'RQMT Defect Mitigation' or @colName = 'RQMTSYSTEMDEFECTMITIGATION_ID' then
			case when @Option = 0 then 'rsdinner.RQMTSystemDefectID as [RQMTSYSTEMDEFECTMITIGATION_ID], rsdinner.Mitigation as [Defect Mitigation]' 
			when @Option = 1 then 'isnull(rsdinner.RQMTSystemDefectID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rsdinner.RQMTSystemDefectID, rsdinner.Mitigation'
			when @Option = 3 then 'a.[Defect Mitigation] ' + @colSort
			when @Option = 6 then 'a.[RQMTSYSTEMDEFECTMITIGATION_ID]'
			else '[Defect Mitigation]' 
			end
		when @colName = 'RQMT Defect Number' or @colName = 'RQMTSYSTEMDEFECTNUMBER_ID' then
			case when @Option = 0 then 'rsdinner.RQMTSystemDefectID as [RQMTSYSTEMDEFECTNUMBER_ID], rsdinner.RQMTSystemDefectID as [Defect Number]'
			when @Option = 1 then 'isnull(rsdinner.RQMTSystemDefectID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rsdinner.RQMTSystemDefectID'
			when @Option = 3 then 'a.[Defect Number] ' + @colSort
			when @Option = 6 then 'a.[RQMTSYSTEMDEFECTNUMBER_ID]'
			else '[Defect Number]' 
			end
		when @colName = 'RQMT Defect Resolved' or @colName = 'RQMTSYSTEMDEFECTRESOLVED_ID' then
			case when @Option = 0 then 'rsdinner.Resolved as [RQMTSYSTEMDEFECTRESOLVED_ID], rsdinner.Resolved as [Defect Resolved]'
			when @Option = 1 then 'isnull(rsdinner.Resolved, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rsdinner.Resolved'
			when @Option = 3 then 'a.[Defect Resolved] ' + @colSort
			when @Option = 6 then 'a.[RQMTSYSTEMDEFECTRESOLVED_ID]'
			else '[Defect Resolved]' 
			end	
		when @colName = 'RQMT Defect Review' or @colName = 'RQMTSYSTEMDEFECTREVIEW_ID' then
			case when @Option = 0 then 'rsdinner.ContinueToReview as [RQMTSYSTEMDEFECTREVIEW_ID], rsdinner.ContinueToReview as [Defect Review]'
			when @Option = 1 then 'isnull(rsdinner.ContinueToReview, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rsdinner.ContinueToReview'
			when @Option = 3 then 'a.[Defect Review] ' + @colSort
			when @Option = 6 then 'a.[RQMTSYSTEMDEFECTREVIEW_ID]'
			else '[Defect Review]' 
			end							
		when @colName = 'RQMT Defect Stage' or @colName = 'RQMTSYSTEMDEFECTSTAGE_ID' then
			case when @Option = 0 then 'rsdinner.RQMTStageID as [RQMTSYSTEMDEFECTSTAGE_ID], ra_defect_stage_inner.RQMTAttribute as [Defect Stage]'
			when @Option = 1 then 'isnull(rsdinner.RQMTStageID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rsdinner.RQMTStageID, ra_defect_stage_inner.RQMTAttribute'
			when @Option = 3 then 'a.[Defect Stage] ' + @colSort
			when @Option = 6 then 'a.[RQMTSYSTEMDEFECTSTAGE_ID]'
			else '[Defect Stage]' 
			end		
		when @colName = 'RQMT Defect Verified' or @colName = 'RQMTSYSTEMDEFECTVERIFIED_ID' then
			case when @Option = 0 then 'rsdinner.Verified as [RQMTSYSTEMDEFECTVERIFIED_ID], rsdinner.Verified as [Defect Verified]'
			when @Option = 1 then 'isnull(rsdinner.Verified, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rsdinner.Verified'
			when @Option = 3 then 'a.[Defect Verified] ' + @colSort
			when @Option = 6 then 'a.[RQMTSYSTEMDEFECTVERIFIED_ID]'
			else '[Defect Verified]' 
			end
		when @colName = 'RQMT Metrics' then
			case when @Option = 0 then 'CONVERT(VARCHAR(10), COUNT(DISTINCT CASE WHEN ra_defect_impact_inner.RQMTAttribute = ''Deficiencies'' THEN rsdinner.RQMTSystemDefectID ELSE NULL END)) + ''.'' + CONVERT(VARCHAR(10), COUNT(DISTINCT CASE WHEN ra_defect_impact_inner.RQMTAttribute = ''Work Stoppage'' THEN rsdinner.RQMTSystemDefectID ELSE NULL END)) as [RQMT Metrics]'
			when @Option = 1 then 'isnull(rsdinner.ImpactID, 0) = ' + @ID + ' and '
			when @Option = 2 then ''
			when @Option = 3 then 'a.[RQMT Metrics] ' + @colSort
			when @Option = 6 then 'a.[RQMT Metrics]'
			else '[Defect Impact]' 
			end		
		when @colName = 'Functionality' or @colName = 'FUNCTIONALITY_ID' then
			case when @Option = 0 then 'rsetfunc.FunctionalityID AS [FUNCTIONALITY_ID], rsetfuncwg.WorkloadGroup AS [Functionality]'
			when @Option = 1 then 'isnull(rsetfunc.FunctionalityID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rsetfunc.FunctionalityID, rsetfuncwg.WorkloadGroup'
			when @Option = 3 then 'a.[Functionality] ' + @colSort
			when @Option = 6 then 'a.[FUNCTIONALITY_ID]'
			else '[Functionality]' end
		when @colName = 'RQMT Set Complexity' or @colName = 'RQMTSETCOMPLEXITY_ID' then
			case when @Option = 0 then 'rset.RQMTComplexityID AS [RQMTSETCOMPLEXITY_ID], rsetcomp.Points as [RQMTSETCOMPLEXITYPOINTS_HDN], rsetcomp.RQMTComplexity AS [Set Complexity]'
			when @Option = 1 then 'isnull(rset.RQMTComplexityID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rset.[RQMTComplexityID], rsetcomp.[Points], rsetcomp.[RQMTComplexity]'
			when @Option = 3 then 'a.[RQMTSETCOMPLEXITYPOINTS_HDN] ' + @colSort
			when @Option = 6 then 'a.[RQMTSETCOMPLEXITY_ID]'
			else '[Set Complexity]' end
		when @colName = 'RQMT Set Complexity Justification' or @colName = 'RQMTSETCOMPLEXITYJUSTIFICATION_ID' then
			case when @Option = 0 then 'rset.RQMTComplexityID AS [RQMTSETCOMPLEXITYJUSTIFICATION_ID], rset.Justification as [Set Justification]'
			when @Option = 1 then 'isnull(rset.RQMTComplexityID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'rset.[RQMTComplexityID], rset.[Justification]'
			when @Option = 3 then 'a.[Set Justification] ' + @colSort
			when @Option = 6 then 'a.[RQMTSETCOMPLEXITYJUSTIFICATION_ID]'
			else '[Complexity]' end
		when @colName = 'RQMT Usage' then
			case when @Option = 0 then 'rsetusage.Month_1, rsetusage.Month_2, rsetusage.Month_3, rsetusage.Month_4, rsetusage.Month_5, rsetusage.Month_6, rsetusage.Month_7, rsetusage.Month_8, rsetusage.Month_9, rsetusage.Month_10, rsetusage.Month_11, rsetusage.Month_12'
			when @Option = 1 then ''
			when @Option = 2 then 'rsetusage.Month_1, rsetusage.Month_2, rsetusage.Month_3, rsetusage.Month_4, rsetusage.Month_5, rsetusage.Month_6, rsetusage.Month_7, rsetusage.Month_8, rsetusage.Month_9, rsetusage.Month_10, rsetusage.Month_11, rsetusage.Month_12'
			when @Option = 3 then '1' -- we don't sort by usage
			when @Option = 6 then ''
			else '[RQMT Usage]' end
		when @colName = 'RQMT Usage Month' or @colName = 'USAGEMONTH_ID' then
			case when @Option = 0 then 'usagemonth.Month as [USAGEMONTH_ID], usagemonth.MonthName as [Usage Month]'
			when @Option = 1 then 'isnull(usagemonth.Month, 0) = ' + @ID + ' and '
			when @Option = 2 then 'usagemonth.[Month], usagemonth.[MonthName]'
			when @Option = 3 then 'a.[USAGEMONTH_ID] ' + @colSort
			when @Option = 6 then 'a.[USAGEMONTH_ID]'
			else '[Usage Month]' end		
		when @colName = 'USAGESETMONTH_ID' then
			case when @Option = 0 then '' -- this value will never be specified as an actual column by the user
			when @Option = 1 then '(''' + @ID + ''' = ''0'' or isnull(usagemonth.Month, 0) in (' + @ID + ')) and '
			when @Option = 2 then ''
			when @Option = 3 then ''
			when @Option = 6 then ''
			else '[Usage Set Month]' end
		when @colName = 'RQMT Set Usage' then
			case when @Option = 0 then '''TRUE'' as RQMTSetUsage_HDN, max(case when rsetusage.Month_1 is null then 0 else rsetusage.Month_1 end) as Month_1, ' +
				'max(case when rsetusage.Month_2 is null then 0 else rsetusage.Month_2 end) as Month_2,' +
				'max(case when rsetusage.Month_3 is null then 0 else rsetusage.Month_3 end) as Month_3,' +
				'max(case when rsetusage.Month_4 is null then 0 else rsetusage.Month_4 end) as Month_4,' +
				'max(case when rsetusage.Month_5 is null then 0 else rsetusage.Month_5 end) as Month_5,' +
				'max(case when rsetusage.Month_6 is null then 0 else rsetusage.Month_6 end) as Month_6,' +
				'max(case when rsetusage.Month_7 is null then 0 else rsetusage.Month_7 end) as Month_7,' +
				'max(case when rsetusage.Month_8 is null then 0 else rsetusage.Month_8 end) as Month_8,' +
				'max(case when rsetusage.Month_9 is null then 0 else rsetusage.Month_9 end) as Month_9,' +
				'max(case when rsetusage.Month_10 is null then 0 else rsetusage.Month_10 end) as Month_10,' +
				'max(case when rsetusage.Month_11 is null then 0 else rsetusage.Month_11 end) as Month_11,' +
				'max(case when rsetusage.Month_12 is null then 0 else rsetusage.Month_12 end) as Month_12'
			when @Option = 1 then ''
			when @Option = 2 then '' -- we do NOT group by the rqmtset usage because we want to rollup the child usage values
			when @Option = 3 then '' -- we don't sort by usage
			when @Option = 6 then ''
			else '[RQMT Usage]' end
		else '' end;

		-- when we have count columns, our parent queries insert extra columns to count by
		-- however, if users have added the same column twice, once at a parent level and once at a child level, we could end up with
		--    a count column that matches the same name as a child row column
		-- to help with this, we give count columns a suffix named _COUNTCOLUMN, allowing us to end up with queries such as:
		-- select WTS_SYSTEMID_COUNTCOLUMN, WTS_SYSTEM_COUNTCOLUMN, WTS_SYSTEMID, WTS_SYSTEM, RQMT
		-- and later select WTS_SYSTEMID_COUNTCOLUMN, WTS_SYSTEM_COUNTCOLUMN, COUNT (1) FROM a group by WTS_SYSTEMID_COUNTCOLUMN, WTS_SYSTEM_COUNTCOLUMN...
		if @countColumnMode = 1
		begin
			if @Option = 0 or @Option = 3 or @Option = 6			
			begin
				set @columns = replace(@columns, ']', '_COUNTCOLUMN]')
			end
		end
		
	return @columns;
end;
GO


