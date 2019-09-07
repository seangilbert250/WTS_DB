USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_Meeting_Get_Tables]    Script Date: 4/11/2018 2:39:50 PM ******/
DROP FUNCTION [dbo].[AOR_Meeting_Get_Tables]
GO

/****** Object:  UserDefinedFunction [dbo].[AOR_Meeting_Get_Tables]    Script Date: 4/11/2018 2:39:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE function [dbo].[AOR_Meeting_Get_Tables]
(
	@ColumnName nvarchar(100),
	@Option int = 0
)
returns nvarchar(1000)
as
begin
	declare @colName nvarchar(100);
	declare @tables nvarchar(1000);

	set @colName = upper(@ColumnName);

	set @tables = 
		case when @colName = '# OF AORS INVOLVED' or @colName = 'AORSINVOLVEDCOUNT_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = '# OF MEETINGS' or @colName = 'MEETINGCOUNT_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = '# OF MEETING INSTANCES' or @colName = 'MEETINGINSTANCECOUNT_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = '# OF RESOURCES INVOLVED' or @colName = 'RESOURCESINVOLVEDCOUNT_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'ACTUAL LENGTH' or @colName = 'ACTUALLENGTH_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'AOR #' or @colName = 'AOR_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'AOR NAME' or @colName = 'AORNAME_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'MEETING NAME' or @colName = 'AORMEETING_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'AVG # OF ATTENDEES' or @colName = 'AVGATTENDEECOUNT_ID' then
			case when @Option = 0 then 'left join w_meeting_attendance wma on aom.AORMeetingID = wma.AORMeetingID'
			else '' end
		when @colName = 'FREQUENCY' or @colName = 'FREQUENCY_ID' then
			case when @Option = 0 then 'left join AORFrequency afr on aom.AORFrequencyID = afr.AORFrequencyID'
			else '' end
		when @colName = 'INSTANCE DATE' or @colName = 'INSTANCEDATE_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'LAST MEETING' or @colName = 'LASTMEETING_ID' then
			case when @Option = 0 then 'left join w_last_meeting wlm on aom.AORMeetingID = wlm.AORMeetingID'
			else '' end
		when @colName = 'MAX # OF ATTENDEES' or @colName = 'MAXATTENDEECOUNT_ID' then
			case when @Option = 0 then 'left join w_meeting_attendance wma on aom.AORMeetingID = wma.AORMeetingID'
			else '' end
		when @colName = 'MEETING INSTANCE NAME' or @colName = 'MEETINGINSTANCENAME_ID' then
			case when @Option = 0 then ''
				else '' end
		when @colName = 'MEETING STATUS' or @colName = 'MEETINGSTATUS_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'MEETING WEEK END' or @colName = 'MEETINGWEEKEND_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'MEETING WEEK START' or @colName = 'MEETINGWEEKSTART_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'MIN # OF ATTENDEES' or @colName = 'MINATTENDEECOUNT_ID' then
			case when @Option = 0 then 'left join w_meeting_attendance wma on aom.AORMeetingID = wma.AORMeetingID'
			else '' end
		when @colName = 'NEXT MEETING' or @colName = 'NEXTMEETING_ID' then
			case when @Option = 0 then 'left join w_next_meeting wnm on aom.AORMeetingID = wnm.AORMeetingID'
			else '' end
		when @colName = 'PRIVATE' or @colName = 'PRIVATE_ID' then
			case when @Option = 0 then ''
			else '' end
		when @colName = 'RESOURCE' or @colName = 'RESOURCE_ID' then
			case when @Option = 0 then 'left join WTS_RESOURCE res on amr.WTS_RESOURCEID = res.WTS_RESOURCEID'
			else '' end
		else '' end;

	return @tables;
end;
GO


GO