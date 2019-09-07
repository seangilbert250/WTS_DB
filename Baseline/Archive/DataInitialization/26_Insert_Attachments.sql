USE WTS
GO

CREATE TABLE #WORKITEM_ATTACHMENTS(
	BUGTRACKER_ID int, AttachmentTypeId int
	, [FileName] nvarchar(100), Title nvarchar(500)
	, BT_USERNAME nvarchar(50), FIRST_NAME nvarchar(60), LAST_NAME nvarchar(60), CREATEDDATE datetime
	, ATTACHMENT_DATA VARBINARY(MAX)
	)
INSERT INTO #WORKITEM_ATTACHMENTS
SELECT
	b.bg_id AS BUGTRACKER_ID
	, 2 AS AttachmentTypeId --Supplemental Document
	, convert(nvarchar(100), bp.bp_file) AS [FileName]
	, convert(nvarchar(500), bp.bp_comment) AS [Title]
	, u.us_username AS BT_USERNAME
	, u.us_firstname AS FIRST_NAME
	, u.us_lastname AS LAST_NAME
	, bp.bp_date AS CREATEDDATE
	, bpa.bpa_content AS ATTACHMENT_DATA
FROM
	BugTracker.dbo.bugs b
		JOIN BugTracker.dbo.bug_posts bp ON b.bg_id = bp.bp_bug
			JOIN BugTracker.dbo.bug_post_attachments bpa ON bp_id = bpa.bpa_post
		JOIN BugTracker.dbo.users u ON u.us_id = bp.bp_user
WHERE
	bp.bp_type = 'file'
ORDER BY
	BP_DATE
;

SELECT COUNT(*) FROM #WORKITEM_ATTACHMENTS;

--insert Attachment records
INSERT INTO Attachment(
	AttachmentTypeId
	, FileName
	, Title
	, [Description]
	, FileData
	, CREATEDBY
	, CREATEDDATE
	, UPDATEDBY
	, UPDATEDDATE
	, BUGTRACKER_ID)
SELECT
	wa.AttachmentTypeId
	, wa.FileName
	, wa.Title
	, wa.Title AS [Description]
	, wa.ATTACHMENT_DATA
	, wa.FIRST_NAME + '.' + wa.LAST_NAME AS CREATEDBY
	, wa.CREATEDDATE
	, wa.FIRST_NAME + '.' + wa.LAST_NAME AS UPDATEDBY
	, wa.CREATEDDATE
	, wa.BUGTRACKER_ID
FROM
	#WORKITEM_ATTACHMENTS wa
;

SELECT COUNT(*) FROM Attachment;
select distinct bugtracker_id, attachmentid from Attachment;

DELETE FROM WorkItem_Attachment;

INSERT INTO WorkItem_Attachment(
	WorkItemId
	, AttachmentId
	, CreatedBy
	, CreatedDate
	, UpdatedBy
	, UpdatedDate
	, Archive
)
SELECT DISTINCT
	wi.WORKITEMID
	, a.AttachmentId
	, a.CREATEDBY
	, a.CREATEDDATE
	, a.UPDATEDBY
	, a.UPDATEDDATE
	, 0 AS Archive
FROM
	#WORKITEM_ATTACHMENTS wa
		JOIN WorkItem wi ON wa.BUGTRACKER_ID = wi.BUGTRACKER_ID
			JOIN Attachment a ON wi.BUGTRACKER_ID = a.BUGTRACKER_ID
ORDER BY
	a.CREATEDDATE
;

SELECT COUNT(*) FROM WorkItem_Attachment;


DROP TABLE #WORKITEM_ATTACHMENTS
GO
