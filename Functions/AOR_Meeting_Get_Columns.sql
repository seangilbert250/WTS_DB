USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_Meeting_Get_Columns]    Script Date: 6/29/2018 11:53:29 AM ******/
DROP FUNCTION [dbo].[AOR_Meeting_Get_Columns]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_Meeting_Get_Columns]    Script Date: 6/29/2018 11:53:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[AOR_Meeting_Get_Columns]
(
	@ColumnName nvarchar(100),
	@Option int = 0,
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
		case when @colName = '# OF AORS INVOLVED' or @colName = 'AORSINVOLVEDCOUNT_ID' then
			case when @Option = 0 then 'count(distinct arl.AORID) as AORsInvolvedCount_ID, count(distinct arl.AORID) as [# of AORs Involved]'
			when @Option = 1 then ''
			when @Option = 2 then 'null'
			when @Option = 3 then 'a.[# of AORs Involved] ' + @colSort
			else '[# of AORs Involved]' end
		when @colName = '# OF MEETINGS' or @colName = 'MEETINGCOUNT_ID' then
			case when @Option = 0 then 'isnull(count(distinct aom.AORMeetingID), 0) as MeetingCount_ID, isnull(count(distinct aom.AORMeetingID), 0) as [# of Meetings]'
			when @Option = 1 then ''
			when @Option = 2 then 'null'
			when @Option = 3 then 'a.[# of Meetings] ' + @colSort
			else '[# of Meetings]' end
		when @colName = '# OF MEETING INSTANCES' or @colName = 'MEETINGINSTANCECOUNT_ID' then
			case when @Option = 0 then 'isnull(count(distinct ami.AORMeetingInstanceID), 0) as MeetingInstanceCount_ID, isnull(count(distinct ami.AORMeetingInstanceID), 0) as [# of Meeting Instances]'
			when @Option = 1 then ''
			when @Option = 2 then 'null'
			when @Option = 3 then 'a.[# of Meeting Instances] ' + @colSort
			else '[# of Meeting Instances]' end
		when @colName = '# OF RESOURCES INVOLVED' or @colName = 'RESOURCESINVOLVEDCOUNT_ID' then
			case when @Option = 0 then 'count(distinct amr.WTS_RESOURCEID) as ResourcesInvolvedCount_ID, count(distinct amr.WTS_RESOURCEID) as [# of Resources Involved]'
			when @Option = 1 then ''
			when @Option = 2 then 'null'
			when @Option = 3 then 'a.[# of Resources Involved] ' + @colSort
			else '[# of Resources Involved]' end
		when @colName = 'AOR #' or @colName = 'AOR_ID' then
			case when @Option = 0 then 'AOR.AORID as AOR_ID, AOR.AORID as [AOR #]'
			when @Option = 1 then 'isnull(AOR.AORID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'AOR.AORID'
			when @Option = 3 then 'a.[AOR #] ' + @colSort
			else '[AOR #]' end
		when @colName = 'AOR NAME' or @colName = 'AORNAME_ID' then
			case when @Option = 0 then 'AOR.AORID as AORName_ID, arl.AORName as [AOR Name]'
			when @Option = 1 then 'isnull(AOR.AORID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'AOR.AORID, arl.AORName'
			when @Option = 3 then 'a.[AOR Name] ' + @colSort
			else '[AOR Name]' end
		when @colName = 'ACTUAL LENGTH' or @colName = 'ACTUALLENGTH_ID' then
			case when @Option = 0 then 'ami.ActualLength as ActualLength_ID, ami.ActualLength as [Actual Length]'
			when @Option = 1 then 'isnull(ami.ActualLength, 0) = ' + @ID + ' and '
			when @Option = 2 then 'ami.ActualLength'
			when @Option = 3 then 'a.[Actual Length] ' + @colSort
			else '[Actual Length]' end
		when @colName = 'MEETING STATUS' or @colName = 'MEETINGSTATUS_ID' then
			case when @Option = 0 then '(CONVERT(CHAR(1), ami.Locked) + CONVERT(CHAR(1), ami.MeetingEnded) + CONVERT(CHAR(1), ami.MeetingAccepted)) as MeetingStatus_ID, (CONVERT(CHAR(1), ami.Locked) + CONVERT(CHAR(1), ami.MeetingEnded) + CONVERT(CHAR(1), ami.MeetingAccepted)) as [Meeting Status]'
			when @Option = 1 then 'isnull(CONVERT(CHAR(1), ami.Locked) + CONVERT(CHAR(1), ami.MeetingEnded) + CONVERT(CHAR(1), ami.MeetingAccepted), 0) = ' + @ID + ' and '
			when @Option = 2 then '(CONVERT(CHAR(1), ami.Locked) + CONVERT(CHAR(1), ami.MeetingEnded) + CONVERT(CHAR(1), ami.MeetingAccepted))'
			when @Option = 3 then 'a.[Meeting Status] ' + @colSort
			else '[Meeting Status]' end
		when @colName = 'MEETING NAME' or @colName = 'AORMEETING_ID' then
			case when @Option = 0 then 'aom.AORMeetingID as AORMeeting_ID, aom.AORMeetingID as [Meeting #], aom.AORMeetingName as [Meeting Name], aom.[Description], aom.Sort'
			when @Option = 1 then 'aom.AORMeetingID = ' + @ID + ' and '
			when @Option = 2 then 'aom.AORMeetingID, aom.AORMeetingName, aom.[Description], aom.Sort'
			when @Option = 3 then 'a.Sort, upper(a.[Meeting Name]) ' + @colSort
			else '[Meeting Name]' end
		when @colName = 'AVG # OF ATTENDEES' or @colName = 'AVGATTENDEECOUNT_ID' then
			case when @Option = 0 then 'wma.AvgCount as AvgAttendeeCount_ID, wma.AvgCount as [Avg # of Attendees]'
			when @Option = 1 then 'isnull(wma.AvgCount, 0) = ' + @ID + ' and '
			when @Option = 2 then 'wma.AvgCount'
			when @Option = 3 then 'a.[Avg # of Attendees] ' + @colSort
			else '[Avg # of Attendees]' end
		when @colName = 'FREQUENCY' or @colName = 'FREQUENCY_ID' then
			case when @Option = 0 then 'afr.AORFrequencyID as Frequency_ID, afr.AORFrequencyName as Frequency'
			when @Option = 1 then 'isnull(afr.AORFrequencyID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'afr.AORFrequencyID, afr.AORFrequencyName'
			when @Option = 3 then 'a.Frequency ' + @colSort
			else 'Frequency' end
		when @colName = 'INSTANCE DATE' or @colName = 'INSTANCEDATE_ID' then
			case when @Option = 0 then 'ami.InstanceDate as InstanceDate_ID, ami.InstanceDate as [Instance Date]'
			when @Option = 1 then 'ami.InstanceDate = ''' + @ID + ''' and '
			when @Option = 2 then 'ami.InstanceDate'
			when @Option = 3 then 'a.[Instance Date] ' + @colSort
			else '[Instance Date]' end
		when @colName = 'LAST MEETING' or @colName = 'LASTMEETING_ID' then
			case when @Option = 0 then 'wlm.LastMeeting as LastMeeting_ID, wlm.LastMeeting as [Last Meeting]'
			when @Option = 1 then 'isnull(wlm.LastMeeting, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'wlm.LastMeeting'
			when @Option = 3 then 'a.[Last Meeting] ' + @colSort
			else '[Last Meeting]' end
		when @colName = 'MAX # OF ATTENDEES' or @colName = 'MAXATTENDEECOUNT_ID' then
			case when @Option = 0 then 'wma.MaxCount as MaxAttendeeCount_ID, wma.MaxCount as [Max # of Attendees]'
			when @Option = 1 then 'isnull(wma.MaxCount, 0) = ' + @ID + ' and '
			when @Option = 2 then 'wma.MaxCount'
			when @Option = 3 then 'a.[Max # of Attendees] ' + @colSort
			else '[Max # of Attendees]' end
		when @colName = 'MEETING INSTANCE NAME' or @colName = 'MEETINGINSTANCENAME_ID' then
			case when @Option = 0 then 'ami.AORMeetingID as AORMeetingInstanceMeeting_ID, ami.AORMeetingInstanceID as AORMeetingInstance_ID, ami.AORMeetingInstanceID as [Meeting Instance #], ami.AORMeetingInstanceName as [Meeting Instance Name], ami.Sort'
			when @Option = 1 then 'ami.AORMeetingInstanceID = ' + @ID + ' and '
			when @Option = 2 then 'ami.AORMeetingID, ami.AORMeetingInstanceID, ami.AORMeetingInstanceName, ami.Sort'
			when @Option = 3 then 'a.Sort, upper(a.[Meeting Instance Name]) ' + @colSort
			else '[Meeting Instance Name]' end
		when @colName = 'MEETING WEEK END' or @colName = 'MEETINGWEEKEND_ID' then
			case when @Option = 0 then 'cast(dateadd(dd, 7 - (datepart(dw, ami.InstanceDate) - 1), ami.InstanceDate) as date) as MeetingWeekEnd_ID, cast(dateadd(dd, 7 - (datepart(dw, ami.InstanceDate) - 1), ami.InstanceDate) as date) as [Meeting Week End]'
			when @Option = 1 then 'isnull(cast(dateadd(dd, 7 - (datepart(dw, ami.InstanceDate) - 1), ami.InstanceDate) as date), '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'cast(dateadd(dd, 7 - (datepart(dw, ami.InstanceDate) - 1), ami.InstanceDate) as date)'
			when @Option = 3 then 'a.[Meeting Week End] ' + @colSort
			else '[Meeting Week End]' end
		when @colName = 'MEETING WEEK START' or @colName = 'MEETINGWEEKSTART_ID' then
			case when @Option = 0 then 'cast(dateadd(dd, -(datepart(dw, ami.InstanceDate) - 2), ami.InstanceDate) as date) as MeetingWeekStart_ID, cast(dateadd(dd, -(datepart(dw, ami.InstanceDate) - 2), ami.InstanceDate) as date) as [Meeting Week Start]'
			when @Option = 1 then 'isnull(cast(dateadd(dd, -(datepart(dw, ami.InstanceDate) - 2), ami.InstanceDate) as date), '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'cast(dateadd(dd, -(datepart(dw, ami.InstanceDate) - 2), ami.InstanceDate) as date)'
			when @Option = 3 then '(case when a.[Meeting Week Start] is null then 0 else 1 end), a.[Meeting Week Start] ' + @colSort
			else '[Meeting Week Start]' end
		when @colName = 'MIN # OF ATTENDEES' or @colName = 'MINATTENDEECOUNT_ID' then
			case when @Option = 0 then 'wma.MinCount as MinAttendeeCount_ID, wma.MinCount as [Min # of Attendees]'
			when @Option = 1 then 'isnull(wma.MinCount, 0) = ' + @ID + ' and '
			when @Option = 2 then 'wma.MinCount'
			when @Option = 3 then 'a.[Min # of Attendees] ' + @colSort
			else '[Min # of Attendees]' end
		when @colName = 'NEXT MEETING' or @colName = 'NEXTMEETING_ID' then
			case when @Option = 0 then 'wnm.NextMeeting as NextMeeting_ID, wnm.NextMeeting as [Next Meeting]'
			when @Option = 1 then 'isnull(wnm.NextMeeting, '''') = ''' + @ID + ''' and '
			when @Option = 2 then 'wnm.NextMeeting'
			when @Option = 3 then 'a.[Next Meeting] ' + @colSort
			else '[Next Meeting]' end
		when @colName = 'PRIVATE' or @colName = 'PRIVATE_ID' then
			case when @Option = 0 then 'case aom.[Private] when 1 then ''1'' else ''0'' end as Private_ID, case aom.[Private] when 1 then ''Yes'' else ''No'' end as [Private]'
			when @Option = 1 then 'isnull(aom.[Private], 0) = ' + @ID + ' and '
			when @Option = 2 then 'aom.[Private]'
			when @Option = 3 then 'a.[Private] ' + @colSort
			else '[Private]' end
		when @colName = 'RESOURCE' or @colName = 'RESOURCE_ID' then
			case when @Option = 0 then 'res.WTS_RESOURCEID as Resource_ID, res.USERNAME as [Resource]'
			when @Option = 1 then 'isnull(res.WTS_RESOURCEID, 0) = ' + @ID + ' and '
			when @Option = 2 then 'res.WTS_RESOURCEID, res.USERNAME'
			when @Option = 3 then 'a.[Resource] ' + @colSort
			else '[Resource]' end
		else '' end;

	return @columns;
end;
GO
GO


