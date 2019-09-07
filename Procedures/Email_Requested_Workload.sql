USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Email_Requested_Workload]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE Email_Requested_Workload

GO

CREATE PROCEDURE [dbo].Email_Requested_Workload
AS
BEGIN
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	DECLARE @tableHTML nvarchar(max);
	DECLARE @taskNumber int;
	DECLARE @title nvarchar(150);
	DECLARE @createdBy nvarchar(255);
	DECLARE @createdDate datetime;
	DECLARE @workType nvarchar(50);
	DECLARE @itemType nvarchar(50);
	DECLARE @assignedTo nvarchar(50);
	DECLARE @priority nvarchar(50);
	DECLARE @primaryResource nvarchar(50);
	DECLARE @system nvarchar(50);
	DECLARE @productVersion nvarchar(50);
	DECLARE @productionStatus nvarchar(50);
	DECLARE @allocationAssign nvarchar(50);
	DECLARE @description nvarchar(max);

	SELECT @count = COUNT(*)
	FROM WORKITEM wi
		JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
	WHERE UPPER(s.[STATUS]) = UPPER('Requested');
		--AND (ISNULL(wi.Signed_Bus,0) = 0 OR ISNULL(wi.Signed_Dev,0) = 0);

	IF (ISNULL(@count,0) > 0)
		BEGIN
			DECLARE workload_cursor CURSOR FOR
			SELECT wi.WORKITEMID
				, wi.TITLE
				, wi.CREATEDBY
				, wi.CREATEDDATE
				, wt.WorkType
				, wit.WORKITEMTYPE
				, au.FIRST_NAME + ' ' + au.LAST_NAME AS AssignedResource
				, p.[PRIORITY]
				, pu.FIRST_NAME + ' ' + pu.LAST_NAME AS PrimaryResource
				, ws.WTS_SYSTEM
				, pv.ProductVersion
				, ps.[STATUS] AS ProductionStatus
				, a.ALLOCATION
				, wi.[DESCRIPTION]
			FROM WORKITEM wi
				LEFT JOIN WORKITEMTYPE wit ON wi.WORKITEMTYPEID = wit.WORKITEMTYPEID
				LEFT JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				LEFT JOIN WorkType wt ON wi.WorkTypeID = wt.WorkTypeID
				JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
				LEFT JOIN ALLOCATION a ON wi.ALLOCATIONID = a.ALLOCATIONID
				LEFT JOIN [PRIORITY] p ON wi.PRIORITYID = p.PRIORITYID
				LEFT JOIN WTS_RESOURCE au ON wi.ASSIGNEDRESOURCEID = au.WTS_RESOURCEID
				LEFT JOIN WTS_RESOURCE pu ON wi.PRIMARYRESOURCEID = pu.WTS_RESOURCEID
				LEFT JOIN ProductVersion pv ON wi.ProductVersionID = pv.ProductVersionID
				LEFT JOIN [STATUS] ps ON wi.ProductionStatusID = ps.STATUSID
			WHERE UPPER(s.[STATUS]) = UPPER('Requested')
				--AND (ISNULL(wi.Signed_Bus,0) = 0 OR ISNULL(wi.Signed_Dev,0) = 0)
			ORDER BY wi.CREATEDDATE DESC;

			SET @tableHTML = N'<style type="text/css">div,table {font-family: Arial; font-size: 12px;}</style>';

			OPEN workload_cursor

			FETCH NEXT FROM workload_cursor
			INTO @taskNumber
				, @title
				, @createdBy
				, @createdDate
				, @workType
				, @itemType
				, @assignedTo
				, @priority
				, @primaryResource
				, @system
				, @productVersion
				, @productionStatus
				, @allocationAssign
				, @description

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @tableHTML = @tableHTML +
					N'<div>' +
					N'<b>Task #: </b>' + CONVERT(nvarchar(10), @taskNumber) + N'<br />' +
					N'<b>Title: </b>' + @title + N'<br />' +
					N'<table border="1" cellpadding="2" cellspacing="0">' +
					N'<tr><td>Created</td><td>' + @createdBy + N' - ' + CONVERT(nvarchar(20), @createdDate, 22) + N'</td></tr>' +
					N'<tr><td>Resource Group</td><td>' + @workType + N'</td></tr>' +
					N'<tr><td>Work Activity</td><td>' + @itemType + N'</td></tr>' +
					N'<tr><td>Assigned To</td><td>' + @assignedTo + N'</td></tr>' +
					N'<tr><td>Priority</td><td>' + @priority + N'</td></tr>' +
					N'<tr><td>Primary Resource</td><td>' + ISNULL(@primaryResource,'&nbsp;') + N'</td></tr>' +
					N'<tr><td>System</td><td>' + @system + N'</td></tr>' +
					N'<tr><td>Product Version</td><td>' + @productVersion + N'</td></tr>' +
					N'<tr><td>Production Status</td><td>' + ISNULL(@productionStatus,'&nbsp;') + N'</td></tr>' +
					--N'<tr><td>Allocation Assign</td><td>' + @allocationAssign + N'</td></tr>' +
					N'<tr><td>Description</td><td>' + (CASE WHEN LEN(@description) > 50 THEN SUBSTRING(@description, 1, 50) + '...' ELSE ISNULL(@description,'&nbsp;') END) + N'</td></tr>' +
					N'</table>' +
					N'</div>' +
					N'<br /><br />';
				FETCH NEXT FROM workload_cursor
				INTO @taskNumber
					, @title
					, @createdBy
					, @createdDate
					, @workType
					, @itemType
					, @assignedTo
					, @priority
					, @primaryResource
					, @system
					, @productVersion
					, @productionStatus
					, @allocationAssign
					, @description
			END;
			CLOSE workload_cursor;
			DEALLOCATE workload_cursor;

			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Default'
				, @recipients = 'porubskyj@infintech.com;walkers@infintech.com;baileyn@infintech.com;harrisd@infintech.com;mendozae@infintech.com;ramose@infintech.com'
				, @copy_recipients = 'FolsomWorkload@infintech.com'
				, @subject = 'WTS: Requested Workload'
				, @body = @tableHTML
				, @body_format = 'HTML';
				
			EXEC LogEmail_Add @StatusId = 1
				, @Sender = 'FolsomWorkload@infintech.com'
				, @ToAddresses = 'porubskyj@infintech.com,walkers@infintech.com,baileyn@infintech.com,harrisd@infintech.com,mendozae@infintech.com,ramose@infintech.com'
				, @CcAddresses = 'FolsomWorkload@infintech.com'
				, @BccAddresses = ''
				, @Subject = 'WTS: Requested Workload'
				, @Body = @tableHTML
				, @SentDate = @date
				, @Procedure_Used = 'Email_Requested_Workload'
				, @ErrorMessage = ''
				, @CreatedBy = 'SQL Server'
				, @newID = null;
		END;
END;