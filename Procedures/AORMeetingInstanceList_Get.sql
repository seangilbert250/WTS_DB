USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceList_Get]    Script Date: 4/13/2018 2:40:04 PM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceList_Get]    Script Date: 4/13/2018 2:40:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[AORMeetingInstanceList_Get]
	@AORMeetingID int,
	@AORMeetingInstanceID int = 0,
	@InstanceFilterID int = 0
as
begin
	select ami.InstanceDate as [Instance Date],
		ami.AORMeetingInstanceID as [Meeting Instance #],
		ami.AORMeetingInstanceName as [Meeting Instance Name],
		ami.Notes as Notes_ID,
		ami.ActualLength as [Actual Length],
		convert(nvarchar(10), ami.Locked) as Locked_ID,
		ami.Sort,
		lower(ami.CreatedBy) as CreatedBy_ID,
		ami.CreatedDate as CreatedDate_ID,
		lower(ami.UpdatedBy) as UpdatedBy_ID,
		ami.UpdatedDate as UpdatedDate_ID,
		null as Z,
		ami.MeetingEnded,
		ami.MeetingAccepted,
		(SELECT TOP 1 mia.AttachmentID 
			FROM AORMeetingInstanceAttachment mia JOIN Attachment att ON (att.AttachmentId = mia.AttachmentID) 
			WHERE mia.AORMeetingInstanceID = ami.AORMeetingInstanceID AND att.AttachmentTypeId = 4 
			ORDER BY att.AttachmentID DESC) as LastMeetingMinutesDocumentID
	from AORMeetingInstance ami
	where ami.AORMeetingID = @AORMeetingID
	and (@AORMeetingInstanceID = 0 or ami.AORMeetingInstanceID = @AORMeetingInstanceID)
	and (@InstanceFilterID = 0 or ami.InstanceDate < (select amii.InstanceDate from AORMeetingInstance amii where amii.AORMeetingInstanceID = @InstanceFilterID))
	order by Sort, InstanceDate desc;
end;
GO


