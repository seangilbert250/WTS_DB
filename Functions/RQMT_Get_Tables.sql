USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[RQMT_Get_Tables]    Script Date: 10/5/2018 12:05:12 PM ******/
DROP FUNCTION [dbo].[RQMT_Get_Tables]
GO

/****** Object:  UserDefinedFunction [dbo].[RQMT_Get_Tables]    Script Date: 10/5/2018 12:05:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO












CREATE function [dbo].[RQMT_Get_Tables]
(
	@ColumnName nvarchar(100),
	@Option int = 0
)
returns nvarchar(1000)
as
begin
	declare @colName nvarchar(100);
	declare @tables nvarchar(1000);
	declare @countColumnMode bit = 0

	-- NOTE: EVERY COLUMN NEEDS TO BE SURROUNDED BY []'s; WE USE THESE TO APPEND _COUNTCOLUMN WHEN WE ARE IN COUNT COLUMN MODE

	if @ColumnName like '%_COUNTCOLUMN' 
	begin
		set @countColumnMode = 1
		set @ColumnName = replace(@ColumnName, '_COUNTCOLUMN', '')
	end

	set @colName = upper(@ColumnName);

	set @tables = 
		case
		when @colName = 'Description' or @colName = 'DESCRIPTION_ID' then
			case when @Option = 0 then 'left join RQMTSystemRQMTDescription rsrd on rsrd.RQMTSystemID = rs.RQMTSystemID left join RQMTDescription rd on rd.RQMTDescriptionID = rsrd.RQMTDescriptionID left join RQMTDescriptionType rdt on rdt.RQMTDescriptionTypeID = rd.RQMTDescriptionTypeID'
			else '' end
		when @colName = 'SYSTEM SUITE' or @colName = 'SYSTEMSUITE_ID' then
			case when @Option = 0 then 'left join WTS_SYSTEM_SUITE syss on sys.WTS_SYSTEM_SUITEID = syss.WTS_SYSTEM_SUITEID'
			else '' end
		when @colName = 'RQMT Usage' or @colName = 'RQMT Set Usage' then
			case when @Option = 0 then 'left join RQMTSet_RQMTSystem_Usage rsetusage on rsetusage.RQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID'
			else '' end
		when @colName = 'RQMT Usage Month' or @colName = 'USAGEMONTH_ID' or @colName = 'USAGESETMONTH_ID' then
			case when @Option = 0 then 
				'join RQMTSet_RQMTSystem_Usage rsetmonthusage on rsetmonthusage.RQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID ' +
				'join #months usagemonth on ' +
				'(' +
				'	(rsetmonthusage.Month_1 <> 0 and usagemonth.Month = 1) or ' +
				'	(rsetmonthusage.Month_2 <> 0 and usagemonth.Month = 2) or ' +
				'	(rsetmonthusage.Month_3 <> 0 and usagemonth.Month = 3) or ' +
				'	(rsetmonthusage.Month_4 <> 0 and usagemonth.Month = 4) or ' +
				'	(rsetmonthusage.Month_5 <> 0 and usagemonth.Month = 5) or ' +
				'	(rsetmonthusage.Month_6 <> 0 and usagemonth.Month = 6) or ' +
				'	(rsetmonthusage.Month_7 <> 0 and usagemonth.Month = 7) or ' +
				'	(rsetmonthusage.Month_8 <> 0 and usagemonth.Month = 8) or ' +
				'	(rsetmonthusage.Month_9 <> 0 and usagemonth.Month = 9) or ' +
				'	(rsetmonthusage.Month_10 <> 0 and usagemonth.Month = 10) or ' +
				'	(rsetmonthusage.Month_11 <> 0 and usagemonth.Month = 11) or ' +
				'	(rsetmonthusage.Month_12 <> 0 and usagemonth.Month = 12) ' +
				')'								
			else '' end
		when @colName = 'RQMT Defects' then
			case when @Option = 0 then 'left join RQMTSystemDefect rsd on rs.RQMTSystemID = rsd.RQMTSystemID left join RQMTAttribute ra_defect_impact on rsd.ImpactID = ra_defect_impact.RQMTAttributeID left join RQMTATtribute ra_defect_stage on rsd.RQMTStageID = ra_defect_stage.RQMTAttributeID'
			else '' end
		when @colName = 'RQMT Defect Description' or @colName = 'RQMT Defect Stage' or @colName = 'RQMT Defect Impact' or @colName = 'RQMT Defect Number' or @colName = 'RQMT Metrics'
							or @colName = 'RQMT Defect Verified' or @colName = 'RQMT Defect Resolved' or @colName = 'RQMT Defect Review' or @colName = 'RQMT Defect Mitigation'
						or @colName = 'RQMTSYSTEMDEFECTDESCRIPTION_ID' or @colName = 'RQMTSYSTEMDEFECTIMPACT_ID' or @colName = 'RQMTSYSTEMDEFECTSTAGE_ID' or @colName = 'RQMTSYSTEMDEFECTNUMBER_ID'
							or @colName = 'RQMTSYSTEMDEFECTVERIFIED_ID' or @colName = 'RQMTSYSTEMDEFECTRESOLVED_ID' or @colName = 'RQMTSYSTEMDEFECTREVIEW_ID' or @colName = 'RQMTSYSTEMDEFECTMITIGATION_ID' then			
			case when @Option = 0 then 'join RQMTSystemDefect rsdinner on rs.RQMTSystemID = rsdinner.RQMTSystemID left join RQMTAttribute ra_defect_impact_inner on rsdinner.ImpactID = ra_defect_impact_inner.RQMTAttributeID left join RQMTATtribute ra_defect_stage_inner on rsdinner.RQMTStageID = ra_defect_stage_inner.RQMTAttributeID'
			else '' end			
		when @colName = 'Functionality' or @colName= 'FUNCTIONALITY_ID' then
			case when @Option = 0 then 'left join RQMTSet_RQMTSystem_Functionality rsrsfunc on (rsrsfunc.RQMTSet_RQMTSystemID = rsrs.RQMTSet_RQMTSystemID) left join RQMTSet_Functionality rsetfunc on (rsetfunc.RQMTSetFunctionalityID = rsrsfunc.RQMTSetFunctionalityID) left join WorkloadGroup rsetfuncwg on (rsetfuncwg.WorkloadGroupID = rsetfunc.FunctionalityID)'
			else '' end
		else '' end;

		if @countColumnMode = 1
		begin
			if @Option = 1			
			begin
				set @tables = replace(@tables, ']', '_COUNTCOLUMN]')
			end
		end

	return @tables;
end;
GO


