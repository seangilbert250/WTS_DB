USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceMetrics_Get]    Script Date: 5/2/2018 10:46:57 AM ******/
DROP PROCEDURE [dbo].[AORMeetingInstanceMetrics_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstanceMetrics_Get]    Script Date: 5/2/2018 10:46:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[AORMeetingInstanceMetrics_Get]
(
	@AORMeetingID INT,
	@AORMeetingInstanceID INT
)
AS
BEGIN

IF (@AORMeetingID = 0)
	SET @AORMeetingID = (SELECT AORMeetingID FROM AORMeetingInstance WHERE AORMeetingInstanceID = @AORMeetingInstanceID)

DECLARE @AORMeetingInstanceLastID INT = (SELECT TOP 1 AORMeetingInstanceID FROM AORMeetingInstance WHERE AORMeetingID = @AORMeetingID ORDER BY InstanceDate DESC)

DECLARE @AORMeetingInstanceSecondToLastID INT = (SELECT TOP 1 AORMeetingInstanceID FROM AORMeetingInstance WHERE AORMeetingID = @AORMeetingID AND AORMeetingInstanceID <> @AORMeetingInstanceLastID ORDER BY InstanceDate DESC)
IF (@AORMeetingInstanceSecondToLastID IS NULL) SET @AORMeetingInstanceSecondToLastID = 0

DECLARE @AORMeetingInstanceThirdToLastID INT = CASE WHEN @AORMeetingInstanceSecondToLastID > 0 THEN (SELECT TOP 1 AORMeetingInstanceID FROM AORMeetingInstance WHERE AORMeetingID = @AORMeetingID AND AORMeetingInstanceID <> @AORMeetingInstanceLastID AND AORMeetingInstanceID <> @AORMeetingInstanceSecondToLastID ORDER BY InstanceDate DESC) ELSE 0 END
IF (@AORMeetingInstanceThirdToLastID IS NULL) SET @AORMeetingInstanceThirdToLastID = 0

IF (@AORMeetingID IS NULL) SET @AORMeetingID = 0
IF (@AORMeetingInstanceID IS NULL) SET @AORMeetingInstanceID = 0


SELECT *
	INTO #Meetings
	FROM AORMeetingInstance
	WHERE @AORMeetingID = 0 OR AORMeetingID = @AORMeetingID

DECLARE @TotalMeetings INT = (SELECT COUNT(1) FROM #Meetings)
DECLARE	@TotalMeetingsWithLength INT = (SELECT COUNT(1) FROM #Meetings WHERE ActualLength IS NOT NULL)

DECLARE @AvgLength NUMERIC(18,2) =
	(
		SELECT CONVERT(NUMERIC(18,2), SUM(ActualLength)) / CONVERT(NUMERIC(18,2), @TotalMeetingsWithLength)
		FROM #Meetings
		WHERE ActualLength IS NOT NULL
	)
IF @AvgLength IS NULL SET @AvgLength = 0

SELECT 
	amr.AORMeetingInstanceID_Add,
	SUM(CASE WHEN amra.WTS_RESOURCEID IS NOT NULL THEN 1 ELSE 0 END) AS ResourcesAttended,
	COUNT(1) AS TotalResources,
	CONVERT(NUMERIC(18,2), SUM(CASE WHEN amra.WTS_RESOURCEID IS NOT NULL THEN 1 ELSE 0 END)) / CONVERT(NUMERIC(18,2), COUNT(1)) AS PercentAttended
INTO #MeetingResources
FROM AORMeetingResource amr
	LEFT JOIN AORMeetingResourceAttendance amra ON (amra.AORMeetingInstanceID = amr.AORMeetingInstanceID_Add and amra.WTS_RESOURCEID = amr.WTS_RESOURCEID)
WHERE
	(@AORMeetingID = 0 OR amr.AORMeetingID = @AORMeetingID)
	AND amr.AORMeetingInstanceID_Remove IS NULL
GROUP BY amr.AORMeetingInstanceID_Add

-- meeting metrics (table 1) (meetings with less than 2 resources aren't counted; the IF EXISTS statement is used in case there are no qualifying meetings at all so we at least get total meetings and average length data
IF EXISTS (SELECT 1 FROM #MeetingResources WHERE ResourcesAttended >= 2)
BEGIN
	SELECT 
		@TotalMeetings TotalMeetings,
		@AvgLength AvgLength,
		CONVERT(NUMERIC(18,2), SUM(ResourcesAttended)) / CONVERT(NUMERIC(18,2), COUNT(1)) AS AvgAttendedCount,
		CONVERT(NUMERIC(18,2), SUM(TotalResources)) / CONVERT(NUMERIC(18,2), COUNT(1)) AS AvgResourcesCount,
		CONVERT(NUMERIC(18,2), SUM(ResourcesAttended)) / CONVERT(NUMERIC(18,2), SUM(TotalResources)) AS AvgAttendedPct,
		MAX(PercentAttended) AS MaxAttendedPct
	FROM #MeetingResources
	WHERE
		ResourcesAttended >= 2
END
ELSE
BEGIN
	SELECT @TotalMeetings TotalMeetings, @AvgLength AvgLength, 0.0 AvgAttendedCount, 0.0 AvgResourcesCount, 0.0 AvgAttendedPct, 0.0 MaxAttendedPct
END
-- note total metrics (table 2)
SELECT 
	amn.AORNoteTypeID, 
	COUNT(DISTINCT amn.NoteGroupID) NoteTypeCount, 
	SUM(CASE WHEN amn.STATUSID = 93 AND amn.AORMeetingInstanceID_Add = @AORMeetingInstanceLastID THEN 1 ELSE 0 END) NoteTypeClosed
FROM AORMeetingNotes amn
WHERE (@AORMeetingID = 0 OR amn.AORMeetingID = @AORMeetingID) and amn.CreatedDate >= '2/12/2018' -- 2/12/2018 is the date we started using note groups; we are only going to count notes as of that date or our data will be off
GROUP BY amn.AORNoteTypeID

-- special stats just for action items (we look at last two meetings only for action item metrics)
SELECT *
INTO #ActionItemNotesLast
FROM AORMeetingNotes amn
WHERE amn.AORMeetingInstanceID_Add = @AORMeetingInstanceLastID
AND amn.AORNoteTypeID = 14 -- action items

SELECT *
INTO #ActionItemNotesSecondToLast
FROM AORMeetingNotes amn
WHERE amn.AORMeetingInstanceID_Add = @AORMeetingInstanceSecondToLastID
AND @AORMeetingInstanceSecondToLastID <> 0
AND amn.AORNoteTypeID = 14 -- action items

SELECT *
INTO #ActionItemNotesThirdToLast
FROM AORMeetingNotes amn
WHERE amn.AORMeetingInstanceID_Add = @AORMeetingInstanceThirdToLastID
AND @AORMeetingInstanceThirdToLastID <> 0
AND amn.AORNoteTypeID = 14 -- action items

-- last meeting status (table 3)
SELECT MAX(@AORMeetingInstanceLastID) LastMeetingID, COUNT(1) AllNotes, SUM(CASE WHEN a.STATUSID = 92 THEN 1 ELSE 0 END) OpenNotes, SUM(CASE WHEN a.STATUSID = 93 THEN 1 ELSE 0 END) ClosedNotes
FROM #ActionItemNotesLast a

-- second to last meeting status (table 4)
SELECT MAX(@AORMeetingInstanceSecondToLastID) SecondToLastMeetingID, COUNT(1) AllNotes, SUM(CASE WHEN a.STATUSID = 92 THEN 1 ELSE 0 END) OpenNotes, SUM(CASE WHEN a.STATUSID = 93 THEN 1 ELSE 0 END) ClosedNotes
FROM #ActionItemNotesSecondToLast a

-- new items in last meeting (table 5)
SELECT COUNT(*) NewItems
FROM #ActionItemNotesLast a
WHERE NOT EXISTS (SELECT 1 FROM #ActionItemNotesSecondToLast b WHERE b.NoteGroupID = a.NoteGroupID)

-- new items in second to last meeting (table 6)
SELECT COUNT(*) NewItems
FROM #ActionItemNotesSecondToLast a
WHERE NOT EXISTS (SELECT 1 FROM #ActionItemNotesThirdToLast b WHERE b.NoteGroupID = a.NoteGroupID)

DROP TABLE #Meetings
DROP TABLE #MeetingResources
DROP TABLE #ActionItemNotesLast
DROP TABLE #ActionItemNotesSecondToLast
DROP TABLE #ActionItemNotesThirdToLast

END
GO


