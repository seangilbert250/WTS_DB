USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_CR_Get_Columns]    Script Date: 5/17/2018 9:10:16 AM ******/
DROP FUNCTION [dbo].[AOR_CR_Get_Columns]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_CR_Get_Columns]    Script Date: 5/17/2018 9:10:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE function [dbo].[AOR_CR_Get_Columns]
(
	@ColumnName nvarchar(100),
	@Option int = 0,
	@AORID int,
	@ID nvarchar(100) = '',
	@Sort nvarchar(100) = ''
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
		case when @colName = 'CR CUSTOMER TITLE' or @colName = 'CR_ID' then
			case when @Option = 0 then (case when @AORID > 0 then 'arc.AORReleaseCRID, ' else '' end) + 'acr.CRID as CR_ID, acr.CRName as [CR Customer Title], acr.Sort, case when acr.Imported = 1 then ''Yes'' else ''No'' end as Imported, wsc.SRCount'
			when @Option = 1 then 'acr.CRID = ' + @ID + ' and '
			when @Option = 2 then 'acr.Sort, acr.CRName ' + @colSort
			else '[CR Customer Title]' end
		when @colName = 'CR INTERNAL TITLE' then
			case when @Option = 0 then 'acr.Title as [CR Internal Title]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.Title ' + @colSort
			else '[CR Internal Title]' end
		when @colName = 'CR DESCRIPTION' then
			case when @Option = 0 then 'acr.Notes AS [CR Description]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.Notes ' + @colSort
			else '[CR Description]' end
		when @colName = 'CR WEBSYSTEM' then
			case when @Option = 0 then 'acr.Websystem as [CR Websystem]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.Websystem ' + @colSort
			else '[CR Websystem]' end
		when @colName = 'CR CONTRACT' then
			case when @Option = 0 then 'STUFF((SELECT DISTINCT '', '' + c2.[CONTRACT] FROM AORCR acr2
											left join AORSR asr2 on acr2.CRID = asr2.CRID
											left join AORReleaseCR arc2 on acr2.CRID = arc2.CRID
											left join AORRelease arl2 on arc2.AORReleaseID = arl2.AORReleaseID
											left join AORReleaseSystem ars2 on arl2.AORReleaseID = ars2.AORReleaseID
											left join WTS_SYSTEM_CONTRACT wc2 on ars2.WTS_SYSTEMID = wc2.WTS_SYSTEMID
											left join [CONTRACT] c2 on wc2.ContractID = c2.CONTRACTID
											where acr2.CRID = acr.CRID
											FOR XML PATH('''')), 1, 2, '''') as [Contract]'
			when @Option = 1 then ''
			when @Option = 2 then '[Contract] ' + @colSort
			else '[Contract]' end
		when @colName = 'CSD REQUIRED NOW' then
			case when @Option = 0 then 'case when acr.CSDRequiredNow = 1 then ''Yes'' else ''No'' end as [CSD Required Now]'
			when @Option = 1 then ''
			when @Option = 2 then 'case when acr.CSDRequiredNow = 1 then ''Yes'' else ''No'' end ' + @colSort
			else '[CSD Required Now]' end
		when @colName = 'RELATED RELEASE' then
			case when @Option = 0 then 'acr.RelatedRelease as [Related Release]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.RelatedRelease ' + @colSort
			else '[Related Release]' end
		when @colName = 'SUBGROUP' then
			case when @Option = 0 then 'acr.Subgroup'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.Subgroup ' + @colSort
			else 'Subgroup' end
		when @colName = 'DESIGN REVIEW' then
			case when @Option = 0 then 'acr.DesignReview as [Design Review]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.DesignReview ' + @colSort
			else '[Design Review]' end
		when @colName = 'CR ITI POC' then
			case when @Option = 0 then 'lower(acr.ITIPOC) as [CR ITI POC]'
			when @Option = 1 then ''
			when @Option = 2 then 'lower(acr.ITIPOC) ' + @colSort
			else '[CR ITI POC]' end
		when @colName = 'CUSTOMER PRIORITY LIST' then
			case when @Option = 0 then 'acr.CustomerPriorityList as [Customer Priority List]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.CustomerPriorityList ' + @colSort
			else '[Customer Priority List]' end
		when @colName = 'GOVERNEMNT CSRD #' then
			case when @Option = 0 then 'acr.GovernmentCSRD as [Government CSRD #]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.GovernmentCSRD ' + @colSort
			else '[Government CSRD #]' end
		when @colName = 'CR #' then
			case when @Option = 0 then 'acr.PrimarySR as [CR #]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.PrimarySR ' + @colSort
			else '[CR #]' end
		when @colName = 'CRITICALITY' then
			case when @Option = 0 then 'p.[PRIORITY] as Criticality'
			when @Option = 1 then ''
			when @Option = 2 then 'p.[PRIORITY] ' + @colSort
			else 'Criticality' end
		when @colName = 'CAM PRIORITY' then
			case when @Option = 0 then 'acr.CAMPriority as [CAM Priority]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.CAMPriority ' + @colSort
			else '[CAM Priority]' end
		when @colName = 'LCMB PRIORITY' then
			case when @Option = 0 then 'acr.LCMBPriority as [LCMB Priority]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.LCMBPriority ' + @colSort
			else '[LCMB Priority]' end
		when @colName = 'AIRSTAFF PRIORITY' then
			case when @Option = 0 then 'acr.AirstaffPriority as [Airstaff Priority]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.AirstaffPriority ' + @colSort
			else '[Airstaff Priority]' end
		when @colName = 'ITI PRIORITY' then
			case when @Option = 0 then 'acr.ITIPriority as [ITI Priority]'
			when @Option = 1 then ''
			when @Option = 2 then 'acr.ITIPriority ' + @colSort
			else '[ITI Priority]' end
		when @colName = 'CR COORDINATION' then
			case when @Option = 0 then 's.[STATUS] as [CR Coordination]'
			when @Option = 1 then ''
			when @Option = 2 then 's.[STATUS] ' + @colSort
			else '[CR Coordination]' end
		when @colName = 'SR #' or @colName = 'SR_ID' then
			case when @Option = 0 then 'asr.SRID as SR_ID, asr.SRID as [SR #], wtc.TaskCount'
			when @Option = 1 then 'isnull(asr.SRID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'asr.SRID ' + @colSort
			else '[SR #]' end
		when @colName = 'SUBMITTED BY' then
			case when @Option = 0 then 'lower(asr.SubmittedBy) as [Submitted By]'
			when @Option = 1 then ''
			when @Option = 2 then 'lower(asr.SubmittedBy) ' + @colSort
			else '[Submitted By]' end
		when @colName = 'SUBMITTED DATE' then
			case when @Option = 0 then 'asr.SubmittedDate as [Submitted Date]'
			when @Option = 1 then ''
			when @Option = 2 then 'asr.SubmittedDate ' + @colSort
			else '[Submitted Date]' end
		when @colName = 'KEYWORDS' then
			case when @Option = 0 then 'asr.Keywords'
			when @Option = 1 then ''
			when @Option = 2 then 'asr.Keywords ' + @colSort
			else 'Keywords' end
		when @colName = 'SR WEBSYSTEM' then
			case when @Option = 0 then 'asr.Websystem as [SR Websystem]'
			when @Option = 1 then ''
			when @Option = 2 then 'asr.Websystem ' + @colSort
			else '[SR Websystem]' end
		when @colName = 'STATUS' then
			case when @Option = 0 then 'asr.[Status]'
			when @Option = 1 then ''
			when @Option = 2 then 'asr.[Status] ' + @colSort
			else '[Status]' end
		when @colName = 'SR TYPE' then
			case when @Option = 0 then 'asr.SRType as [SR Type]'
			when @Option = 1 then ''
			when @Option = 2 then 'asr.SRType ' + @colSort
			else '[SR Type]' end
		when @colName = 'PRIORITY' then
			case when @Option = 0 then 'asr.[Priority]'
			when @Option = 1 then ''
			when @Option = 2 then 'asr.[Priority] ' + @colSort
			else '[Priority]' end
		when @colName = 'LCMB' then
			case when @Option = 0 then 'case when asr.LCMB = 1 then ''Yes'' else ''No'' end as LCMB'
			when @Option = 1 then ''
			when @Option = 2 then 'case when asr.LCMB = 1 then ''Yes'' else ''No'' end ' + @colSort
			else 'LCMB' end
		when @colName = 'ITI' then
			case when @Option = 0 then 'case when asr.ITI = 1 then ''Yes'' else ''No'' end as ITI'
			when @Option = 1 then ''
			when @Option = 2 then 'case when asr.ITI = 1 then ''Yes'' else ''No'' end ' + @colSort
			else 'ITI' end
		when @colName = 'SR ITI POC' then
			case when @Option = 0 then 'lower(asr.ITIPOC) as [SR ITI POC]'
			when @Option = 1 then ''
			when @Option = 2 then 'lower(asr.ITIPOC) ' + @colSort
			else '[SR ITI POC]' end
		when @colName = 'DESCRIPTION' then
			case when @Option = 0 then 'asr.[Description]'
			when @Option = 1 then ''
			when @Option = 2 then 'asr.[Description] ' + @colSort
			else '[Description]' end
		when @colName = 'LAST REPLY' then
			case when @Option = 0 then 'asr.LastReply as [Last Reply]'
			when @Option = 1 then ''
			when @Option = 2 then 'asr.LastReply ' + @colSort
			else '[Last Reply]' end
		when @colName = 'AOR NAME' or @colName = 'AOR_ID' then
			case when @Option = 0 then 'AOR.AORID as AOR_ID, AOR.AORID as [AOR #], arl.AORName as [AOR Name], arl.[Description] as [AOR Description]'
			when @Option = 1 then 'isnull(AOR.AORID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'arl.AORName ' + @colSort
			else '[AOR Name]' end
		when @colName = 'PRIMARY TASK' then
			case when @Option = 0 then 'wi.WORKITEMID as [Primary Task]'
			when @Option = 1 then ''
			when @Option = 2 then 'wi.WORKITEMID ' + @colSort
			else '[Primary Task]' end
		when @colName = 'PRIMARY TASK TITLE' then
			case when @Option = 0 then 'wi.TITLE as [Primary Task Title]'
			when @Option = 1 then ''
			when @Option = 2 then 'wi.TITLE ' + @colSort
			else '[Primary Task Title]' end
		when @colName = 'SYSTEM(TASK)' then
			case when @Option = 0 then 'ws.WTS_SYSTEM as [System(Task)]'
			when @Option = 1 then ''
			when @Option = 2 then 'ws.WTS_SYSTEM ' + @colSort
			else '[System(Task)]' end
		when @colName = 'PRODUCT VERSION' then
			case when @Option = 0 then 'pv.ProductVersion as [Product Version]'
			when @Option = 1 then ''
			when @Option = 2 then 'pv.ProductVersion ' + @colSort
			else '[Product Version]' end
		when @colName = 'PRODUCTION STATUS' then
			case when @Option = 0 then 'ps.[STATUS] as [Production Status]'
			when @Option = 1 then ''
			when @Option = 2 then 'ps.[STATUS] ' + @colSort
			else '[Production Status]' end
		when @colName = 'TASK PRIORITY' then
			case when @Option = 0 then 'pr.[PRIORITY] as [Task Priority]'
			when @Option = 1 then ''
			when @Option = 2 then 'pr.[PRIORITY] ' + @colSort
			else '[Task Priority]' end
		when @colName = 'ASSIGNED TO' then
			case when @Option = 0 then 'ato.USERNAME as [Assigned To]'
			when @Option = 1 then ''
			when @Option = 2 then 'ato.USERNAME ' + @colSort
			else '[Assigned To]' end
		when @colName = 'PRIMARY RESOURCE' then
			case when @Option = 0 then 'ptr.USERNAME as [Primary Resource]'
			when @Option = 1 then ''
			when @Option = 2 then 'ptr.USERNAME ' + @colSort
			else '[Primary Resource]' end
		when @colName = 'SECONDARY TECH. RESOURCE' then
			case when @Option = 0 then 'str.USERNAME as [Secondary Tech. Resource]'
			when @Option = 1 then ''
			when @Option = 2 then 'str.USERNAME ' + @colSort
			else '[Secondary Tech. Resource]' end
		when @colName = 'PRIMARY BUS. RESOURCE' then
			case when @Option = 0 then 'pbr.USERNAME as [Primary Bus. Resource]'
			when @Option = 1 then ''
			when @Option = 2 then 'pbr.USERNAME ' + @colSort
			else '[Primary Bus. Resource]' end
		when @colName = 'SECONDARY BUS. RESOURCE' then
			case when @Option = 0 then 'sbr.USERNAME as [Secondary Bus. Resource]'
			when @Option = 1 then ''
			when @Option = 2 then 'sbr.USERNAME ' + @colSort
			else '[Secondary Bus. Resource]' end
		when @colName = 'TASK STATUS' then
			case when @Option = 0 then 'st.[STATUS] as [Task Status]'
			when @Option = 1 then ''
			when @Option = 2 then 'st.[STATUS] ' + @colSort
			else '[Task Status]' end
		when @colName = 'PERCENT COMPLETE' then
			case when @Option = 0 then 'wi.COMPLETIONPERCENT as [Percent Complete]'
			when @Option = 1 then ''
			when @Option = 2 then 'wi.COMPLETIONPERCENT ' + @colSort
			else '[Percent Complete]' end
		else '' end;

	return @columns;
end;



GO

