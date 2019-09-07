USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[Get_Rollups]    Script Date: 5/15/2017 3:46:43 PM ******/
DROP FUNCTION [dbo].[Get_Rollups]
GO

/****** Object:  UserDefinedFunction [dbo].[Get_Rollups]    Script Date: 5/15/2017 3:46:43 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[Get_Rollups]
(
	@Field nvarchar(100),
	@Type nvarchar(100),
	@Option int = 0
)
returns nvarchar(4000)
as
begin
	declare @fieldName nvarchar(100);
	declare @typeName nvarchar(100);
	declare @rollups nvarchar(4000);

	set @fieldName = upper(@Field);
	set @typeName = upper(@Type);

	set @rollups = 
		case when @fieldName = 'STATUS' then
			case when @Option = 0 then
				'isnull(sum(case when upper(wi.[STATUS]) not in (''INFO REQUESTED'', ''ON HOLD'', ''CLOSED'') then 1 end), 0) as Open_Tasks,
				isnull(sum(case when upper(wi.[STATUS]) = ''ON HOLD'' then 1 end), 0) as OnHold_Tasks,
				isnull(sum(case when upper(wi.[STATUS]) = ''INFO REQUESTED'' then 1 end), 0) as InfoRequested_Tasks,
				isnull(sum(case when upper(wi.[STATUS]) = ''NEW'' then 1 end), 0) as New_Tasks,
				isnull(sum(case when upper(wi.[STATUS]) = ''IN PROGRESS'' then 1 end), 0) as InProgress_Tasks,
				isnull(sum(case when upper(wi.[STATUS]) = ''RE-OPENED'' then 1 end), 0) as ReOpened_Tasks,
				isnull(sum(case when upper(wi.[STATUS]) = ''INFO PROVIDED'' then 1 end), 0) as InfoProvided_Tasks,
				isnull(sum(case when upper(wi.[STATUS]) = ''UN-REPRODUCIBLE'' then 1 end), 0) as UnReproducible_Tasks,
				isnull(sum(case when upper(wi.[STATUS]) = ''CHECKED IN'' then 1 end), 0) as CheckedIn_Tasks,
				isnull(sum(case when upper(wi.[STATUS]) = ''DEPLOYED'' then 1 end), 0) as Deployed_Tasks,
				isnull(sum(case when upper(wi.[STATUS]) = ''CLOSED'' then 1 end), 0) as Closed_Tasks,'
			when @Option = 1 then
				'isnull(sum(case when upper(wit.[STATUS]) not in (''INFO REQUESTED'', ''ON HOLD'', ''CLOSED'') then 1 end), 0) as Open_Sub_Tasks,
				isnull(sum(case when upper(wit.[STATUS]) = ''ON HOLD'' then 1 end), 0) as OnHold_Sub_Tasks,
				isnull(sum(case when upper(wit.[STATUS]) = ''INFO REQUESTED'' then 1 end), 0) as InfoRequested_Sub_Tasks,
				isnull(sum(case when upper(wit.[STATUS]) = ''NEW'' then 1 end), 0) as New_Sub_Tasks,
				isnull(sum(case when upper(wit.[STATUS]) = ''IN PROGRESS'' then 1 end), 0) as InProgress_Sub_Tasks,
				isnull(sum(case when upper(wit.[STATUS]) = ''RE-OPENED'' then 1 end), 0) as ReOpened_Sub_Tasks,
				isnull(sum(case when upper(wit.[STATUS]) = ''INFO PROVIDED'' then 1 end), 0) as InfoProvided_Sub_Tasks,
				isnull(sum(case when upper(wit.[STATUS]) = ''UN-REPRODUCIBLE'' then 1 end), 0) as UnReproducible_Sub_Tasks,
				isnull(sum(case when upper(wit.[STATUS]) = ''CHECKED IN'' then 1 end), 0) as CheckedIn_Sub_Tasks,
				isnull(sum(case when upper(wit.[STATUS]) = ''DEPLOYED'' then 1 end), 0) as Deployed_Sub_Tasks,
				isnull(sum(case when upper(wit.[STATUS]) = ''CLOSED'' then 1 end), 0) as Closed_Sub_Tasks,'
			when @Option = 2 then
				'isnull(tr.Open_Tasks, 0) + isnull(trs.Open_Sub_Tasks, 0) as [Open],
				isnull(tr.OnHold_Tasks, 0) + isnull(trs.OnHold_Sub_Tasks, 0) as [On Hold],
				isnull(tr.InfoRequested_Tasks, 0) + isnull(trs.InfoRequested_Sub_Tasks, 0) as [Info Requested],
				isnull(tr.New_Tasks, 0) + isnull(trs.New_Sub_Tasks, 0) as New,
				isnull(tr.InProgress_Tasks, 0) + isnull(trs.InProgress_Sub_Tasks, 0) as [In Progress],
				isnull(tr.ReOpened_Tasks, 0) + isnull(trs.ReOpened_Sub_Tasks, 0) as [Re-Opened],
				isnull(tr.InfoProvided_Tasks, 0) + isnull(trs.InfoProvided_Sub_Tasks, 0) as [Info Provided],
				isnull(tr.UnReproducible_Tasks, 0) + isnull(trs.UnReproducible_Sub_Tasks, 0) as [Un-Reproducible],
				isnull(tr.CheckedIn_Tasks, 0) + isnull(trs.CheckedIn_Sub_Tasks, 0) as [Checked In],
				isnull(tr.Deployed_Tasks, 0) + isnull(trs.Deployed_Sub_Tasks, 0) as Deployed,
				isnull(tr.Closed_Tasks, 0) + isnull(trs.Closed_Sub_Tasks, 0) as Closed,'
			when @Option = 3 then
				'convert(nvarchar(10), isnull(tra.Open_Tasks, 0) + isnull(trsa.Open_Sub_Tasks, 0)) + '' || '' +  convert(nvarchar(10),isnull(tr.Open_Tasks, 0) + isnull(trs.Open_Sub_Tasks, 0)) as [Open],
				convert(nvarchar(10),isnull(tra.OnHold_Tasks, 0) + isnull(trsa.OnHold_Sub_Tasks, 0)) + '' || '' + convert(nvarchar(10),isnull(tr.OnHold_Tasks, 0) + isnull(trs.OnHold_Sub_Tasks, 0)) as [On Hold],
				convert(nvarchar(10),isnull(tra.InfoRequested_Tasks, 0) + isnull(trsa.InfoRequested_Sub_Tasks, 0)) + '' || '' + convert(nvarchar(10),isnull(tr.InfoRequested_Tasks, 0) + isnull(trs.InfoRequested_Sub_Tasks, 0)) as [Info Requested],
				convert(nvarchar(10),isnull(tra.New_Tasks, 0) + isnull(trsa.New_Sub_Tasks, 0)) + '' || '' + convert(nvarchar(10),isnull(tr.New_Tasks, 0) + isnull(trs.New_Sub_Tasks, 0)) as New,
				convert(nvarchar(10),isnull(tra.InProgress_Tasks, 0) + isnull(trsa.InProgress_Sub_Tasks, 0)) + '' || '' + convert(nvarchar(10),isnull(tr.InProgress_Tasks, 0) + isnull(trs.InProgress_Sub_Tasks, 0)) as [In Progress],
				convert(nvarchar(10),isnull(tra.ReOpened_Tasks, 0) + isnull(trsa.ReOpened_Sub_Tasks, 0)) + '' || '' + convert(nvarchar(10),isnull(tr.ReOpened_Tasks, 0) + isnull(trs.ReOpened_Sub_Tasks, 0)) as [Re-Opened],
				convert(nvarchar(10),isnull(tra.InfoProvided_Tasks, 0) + isnull(trsa.InfoProvided_Sub_Tasks, 0)) + '' || '' + convert(nvarchar(10),isnull(tr.InfoProvided_Tasks, 0) + isnull(trs.InfoProvided_Sub_Tasks, 0)) as [Info Provided],
				convert(nvarchar(10),isnull(tra.UnReproducible_Tasks, 0) + isnull(trsa.UnReproducible_Sub_Tasks, 0)) + '' || '' + convert(nvarchar(10),isnull(tr.UnReproducible_Tasks, 0) + isnull(trs.UnReproducible_Sub_Tasks, 0)) as [Un-Reproducible],
				convert(nvarchar(10),isnull(tra.CheckedIn_Tasks, 0) + isnull(trsa.CheckedIn_Sub_Tasks, 0)) + '' || '' + convert(nvarchar(10),isnull(tr.CheckedIn_Tasks, 0) + isnull(trs.CheckedIn_Sub_Tasks, 0)) as [Checked In],
				convert(nvarchar(10),isnull(tra.Deployed_Tasks, 0) + isnull(trsa.Deployed_Sub_Tasks, 0)) + '' || '' + convert(nvarchar(10),isnull(tr.Deployed_Tasks, 0) + isnull(trs.Deployed_Sub_Tasks, 0)) as Deployed,
				convert(nvarchar(10),isnull(tra.Closed_Tasks, 0) + isnull(trsa.Closed_Sub_Tasks, 0)) + '' || '' + convert(nvarchar(10),isnull(tr.Closed_Tasks, 0) + isnull(trs.Closed_Sub_Tasks, 0)) as Closed,'
			else '' end
		when @fieldName = 'PRIORITY' then
			case when @Option = 0 then
				'isnull(sum(case when upper(wi.[PRIORITY]) = ''HIGH'' then 1 end), 0) as High_Tasks,
				isnull(sum(case when upper(wi.[PRIORITY]) = ''MED'' then 1 end), 0) as Medium_Tasks,
				isnull(sum(case when upper(wi.[PRIORITY]) = ''LOW'' then 1 end), 0) as Low_Tasks,
				isnull(sum(case when upper(wi.[PRIORITY]) = ''NA'' then 1 end), 0) as NA_Tasks,'
			when @Option = 1 then
				'isnull(sum(case when upper(wit.[PRIORITY]) = ''HIGH'' then 1 end), 0) as High_Sub_Tasks,
				isnull(sum(case when upper(wit.[PRIORITY]) = ''MED'' then 1 end), 0) as Medium_Sub_Tasks,
				isnull(sum(case when upper(wit.[PRIORITY]) = ''LOW'' then 1 end), 0) as Low_Sub_Tasks,
				isnull(sum(case when upper(wit.[PRIORITY]) = ''NA'' then 1 end), 0) as NA_Sub_Tasks,'
			when @Option = 2 then
				'isnull(tr.High_Tasks, 0) + isnull(trs.High_Sub_Tasks, 0) as High,
				isnull(tr.Medium_Tasks, 0) + isnull(trs.Medium_Sub_Tasks, 0) as Medium,
				isnull(tr.Low_Tasks, 0) + isnull(trs.Low_Sub_Tasks, 0) as Low,
				isnull(tr.NA_Tasks, 0) + isnull(trs.NA_Sub_Tasks, 0) as NA,'
			else '' end
		when @fieldName = 'ORGANIZATION (ASSIGNED TO)' then
			case when @Option = 0 then
				'isnull(sum(case when upper(wi.ORGANIZATION) = ''FOLSOM DEV'' then 1 end), 0) as FolsomDev_Tasks,
				isnull(sum(case when upper(wi.ORGANIZATION) = ''BUSINESS TEAM'' then 1 end), 0) as BusinessTeam_Tasks,
				isnull(sum(case when upper(wi.ORGANIZATION) = ''EXECUTIVE'' then 1 end), 0) as Executive_Tasks,
				isnull(sum(case when upper(wi.ORGANIZATION) = ''RCS'' then 1 end), 0) as RCS_Tasks,
				isnull(sum(case when upper(wi.ORGANIZATION) = ''SIST'' then 1 end), 0) as SIST_Tasks,'
			when @Option = 1 then
				'isnull(sum(case when upper(wit.ORGANIZATION) = ''FOLSOM DEV'' then 1 end), 0) as FolsomDev_Sub_Tasks,
				isnull(sum(case when upper(wit.ORGANIZATION) = ''BUSINESS TEAM'' then 1 end), 0) as BusinessTeam_Sub_Tasks,
				isnull(sum(case when upper(wit.ORGANIZATION) = ''EXECUTIVE'' then 1 end), 0) as Executive_Sub_Tasks,
				isnull(sum(case when upper(wit.ORGANIZATION) = ''RCS'' then 1 end), 0) as RCS_Sub_Tasks,
				isnull(sum(case when upper(wit.ORGANIZATION) = ''SIST'' then 1 end), 0) as SIST_Sub_Tasks,'
			when @Option = 2 then
				'isnull(tr.FolsomDev_Tasks, 0) + isnull(trs.FolsomDev_Sub_Tasks, 0) as [Folsom Dev],
				isnull(tr.BusinessTeam_Tasks, 0) + isnull(trs.BusinessTeam_Sub_Tasks, 0) as [Business Team],
				isnull(tr.Executive_Tasks, 0) + isnull(trs.Executive_Sub_Tasks, 0) as Executive,
				isnull(tr.RCS_Tasks, 0) + isnull(trs.RCS_Sub_Tasks, 0) as RCS,
				isnull(tr.SIST_Tasks, 0) + isnull(trs.SIST_Sub_Tasks, 0) as SIST,'
			else '' end
		else '' end;

	return @rollups;
end;

GO

