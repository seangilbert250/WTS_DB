USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[Email_Hotlist_OnDemand]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [Email_Hotlist_OnDemand]
GO
-- Change history:
-- 11-18-2016 Changed OR's to AND's where checking Tech and Bus ranks.
-- 12-2-2016  Added In Progress > Deployed/Closed durations
-- 12-12-2016 Added Close duration for Allocations


CREATE PROCEDURE [dbo].[Email_Hotlist_OnDemand]
	--Config Parameters
	@ProdStatus AS NVARCHAR(MAX) = NULL
	,@TechMin AS INT = NULL
	,@TechMax AS INT = NULL
	,@BusMin AS INT = NULL
	,@BusMax AS INT = NULL
	,@activeStatus AS NVARCHAR(MAX) = NULL
	,@activeAssigned AS NVARCHAR(MAX) = NULL
	,@activeRecipients AS NVARCHAR(MAX) = NULL --'iti.folsom.dev@infintech.com'
	,@message AS NVARCHAR(MAX) = N''
AS
BEGIN
	--setup
	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	DECLARE @count_sub int = 0;
	DECLARE @InviteHTML nvarchar(max) = '';
	DECLARE @tableHTML nvarchar(max) = '';
	DECLARE @tableHTML_temp nvarchar(max) = '';
	DECLARE @border int = 0;
	DECLARE @AllocationTableHTML nvarchar(max) = '';
	DECLARE @ResourceTableHTML nvarchar(max) = '';

	DECLARE @PriorityTableHTML nvarchar(max) = '';
	DECLARE @ClosedTableHTML nvarchar(max) = '';
	DECLARE @Top3TableHTML nvarchar(max) = '';

	DECLARE @EmailList nvarchar(max) = '';
	
	--Resources
	DECLARE @Resource nvarchar(100);
	DECLARE @Task_Count int;
	DECLARE @Sub_Count int;
	DECLARE @Email nvarchar(500);
	DECLARE @sortOrder nvarchar(5);

	--hotlist
	DECLARE @systemSort int;
	DECLARE @systemID int;
	DECLARE @system nvarchar(50);

	DECLARE @totalItems int = 0;
	DECLARE @openItems int = 0;
	DECLARE @onHoldItems int = 0;
	DECLARE @infoRequestedItems int = 0;
	DECLARE @newItems int = 0;
	DECLARE @inProgressItems int = 0;
	DECLARE @reOpenedItems int = 0;
	DECLARE @infoProvidedItems int = 0;
	DECLARE @unReproducibleItems int = 0;
	DECLARE @checkedInItems int = 0;
	DECLARE @deployedItems int = 0;
	DECLARE @closedItems int = 0;

	DECLARE @totalItemsSub int = 0;
	DECLARE @openItemsSub int = 0;
	DECLARE @onHoldItemsSub int = 0;
	DECLARE @infoRequestedItemsSub int = 0;
	DECLARE @newItemsSub int = 0;
	DECLARE @inProgressItemsSub int = 0;
	DECLARE @reOpenedItemsSub int = 0;
	DECLARE @infoProvidedItemsSub int = 0;
	DECLARE @unReproducibleItemsSub int = 0;
	DECLARE @checkedInItemsSub int = 0;
	DECLARE @deployedItemsSub int = 0;
	DECLARE @closedItemsSub int = 0;

	--count
	DECLARE @cTotal int = 0;
	DECLARE @cOpen int = 0;
	DECLARE @cOnHold int = 0;
	DECLARE @cInfoRequested int = 0;
	DECLARE @cNew int = 0;
	DECLARE @cInProgress int = 0;
	DECLARE @cReOpened int = 0;
	DECLARE @cInfoProvided int = 0;
	DECLARE @cUnReproducible int = 0;
	DECLARE @cCheckedIn int = 0;
	DECLARE @cDeployed int = 0;
	DECLARE @cClosed int = 0;
	DECLARE @cTotalSub int = 0;
	DECLARE @cOpenSub int = 0;
	DECLARE @cOnHoldSub int = 0;
	DECLARE @cInfoRequestedSub int = 0;
	DECLARE @cNewSub int = 0;
	DECLARE @cInProgressSub int = 0;
	DECLARE @cReOpenedSub int = 0;
	DECLARE @cInfoProvidedSub int = 0;
	DECLARE @cUnReproducibleSub int = 0;
	DECLARE @cCheckedInSub int = 0;
	DECLARE @cDeployedSub int = 0;
	DECLARE @cClosedSub int = 0;

	--workload
	DECLARE @workitemID int;
	DECLARE @itemSystem nvarchar(50);
	DECLARE @status nvarchar(50);
	DECLARE @title nvarchar(150);
	DECLARE @busRank nvarchar(50);
	DECLARE @techRank nvarchar(50);
	DECLARE @workArea nvarchar(50);
	DECLARE @functionality nvarchar(50);
	DECLARE @production nvarchar(50);
	DECLARE @version nvarchar(50);
	DECLARE @priority nvarchar(50);
	DECLARE @assigned nvarchar(100);
	DECLARE @primaryDeveloper nvarchar(100);
	DECLARE @progress int;
	DECLARE @sort int;
	DECLARE @openDays int;
	DECLARE @assignedDays int;

	--workload_sub
	DECLARE @subTask nvarchar(50);
	DECLARE @businessRank nvarchar(50);
	DECLARE @subTechRank int;
	DECLARE @subPriority nvarchar(50);
	DECLARE @subTitle nvarchar(50);
	DECLARE @subAssigned nvarchar(100);
	DECLARE @subPrimaryDeveloper nvarchar(100);
	DECLARE @estimatedStart nvarchar(50);
	DECLARE @actualStart nvarchar(50);
	DECLARE @plannedHours nvarchar(50);
	DECLARE @actualHours nvarchar(50);
	DECLARE @actualEnd nvarchar(50);
	DECLARE @percentComplete int;
	DECLARE @subStatus nvarchar(50);
	DECLARE @subOpenDays int;
	DECLARE @subAssignedDays int;
	DECLARE @reOpenedCount int;
	DECLARE @allocation nvarchar(150);

-- Added 11-21-16:
	DECLARE @TableSummaryHTML nvarchar(max) = '';
	DECLARE @ResName nvarchar(100) = '';
	DECLARE @ResID int;
	DECLARE @TaskCount int;
	DECLARE @Description nvarchar(200) = '';
	DECLARE @PriorityHTML nvarchar(max) = '';
	DECLARE @CriticalCount as int;
	DECLARE @HighCount as int;
	DECLARE @MediumCount as int;
	DECLARE @LowCount as int;
	DECLARE @LastThreeClosed as nvarchar(40) = '';
	DECLARE @WorkItemIDChar nvarchar(20) = '';

	-- Open Durations:
	DECLARE @SysID int = 0;
	DECLARE @SysName nvarchar(100) = '';
	DECLARE @TotalCount int = 0;
	DECLARE @DaysCount int = 0;
	DECLARE @WorkItemCount int = 0;
	DECLARE @AverageDays int = 0;
	DECLARE @DurationText nvarchar(200) = '';
	DECLARE @DurationTable nvarchar(max) = '';

	DECLARE @TotalCount2 int = 0;
	DECLARE @WorkItemCount2 int = 0;
	DECLARE @Count2 int = 0;
	DECLARE @AverageDays2 int = 0;
	DECLARE @WorkItemID2 int = 0;

	DECLARE @DurationAllocationTable nvarchar(max) = '';
	DECLARE @AllocationName nvarchar(100) = '';
	DECLARE @PreviousAllocationName nvarchar(100) = '';
	DECLARE @AllocationCount int = 0;
	DECLARE @TotalAllocationCount int = 0;
	DECLARE @LineCount int = 0;

	-- On Demand passes in the parameters.

	--DECLARE ActiveConfig_cursor CURSOR FOR
	--	SELECT TOP 1 
	--	prodStatus
	--	,techMin
	--	,techMax
	--	,busMin
	--	,busMax
	--	,[status]
	--	,assigned
	--	,recipients
	--	,message
	--	FROM Email_Hotlist_Config
	--	WHERE Active = 1;

	--	OPEN ActiveConfig_cursor
	--	FETCH NEXT FROM ActiveConfig_cursor
	--	INTO @ProdStatus
	--		,@TechMin
	--		,@TechMax
	--		,@BusMin
	--		,@BusMax
	--		,@activeStatus
	--		,@activeAssigned
	--		,@activeRecipients
	--		,@message

	--	CLOSE ActiveConfig_cursor
	--	DEALLOCATE ActiveConfig_cursor

		SET @message = CASE WHEN @message IS NOT NULL THEN @message ELSE '' END;

		--SET @TechMax = @TechMax+ 5;
		--SET @BusMax = @BusMax+ 5;

--=======================================================================================================
-- Per Resource - Counts by Priority and last 3 closed - Below
--=======================================================================================================

		SET @TableSummaryHTML = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';
		SET @TableSummaryHTML = @TableSummaryHTML + N'<table cellpadding="0" cellspacing="0">';
		SET @TableSummaryHTML = @TableSummaryHTML + N'<th style="border: 1px solid gray;" width="95">Resource</th>';
		SET @TableSummaryHTML = @TableSummaryHTML + N'<th style="border: 1px solid gray;" width="300">Top 3 (At most) per Resource - Title</th>';
		SET @TableSummaryHTML = @TableSummaryHTML + N'<th style="border: 1px solid gray;" width="65">WorkItemID</th>';

		SET @PriorityHTML = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';
		SET @PriorityHTML = @PriorityHTML + N'<table cellpadding="0" cellspacing="0">';
		SET @PriorityHTML = @PriorityHTML + N'<th style="border: 1px solid gray;" width="95">Resource</th>';
		SET @PriorityHTML = @PriorityHTML + N'<th style="border: 1px solid gray;" width="65">Critical</th>';
		SET @PriorityHTML = @PriorityHTML + N'<th style="border: 1px solid gray;" width="65">High</th>';
		SET @PriorityHTML = @PriorityHTML + N'<th style="border: 1px solid gray;" width="65">Medium</th>';
		SET @PriorityHTML = @PriorityHTML + N'<th style="border: 1px solid gray;" width="65">Low</th>';
		SET @PriorityHTML = @PriorityHTML + N'<th style="border: 1px solid gray;" width="65">Last 3 Closed</th>';

		WHILE LEN(@activeAssigned) > 0
		-- Loop through each resource

		BEGIN
			SET @ResID = left(@activeAssigned, charindex(',', @activeAssigned+',')-1);
			SET @ResName = (SELECT FIRST_NAME + ' ' + LAST_NAME AS Name FROM WTS_RESOURCE WHERE WTS_RESOURCEID = @ResID);

			SET @TaskCount = (SELECT COUNT (*)
				FROM WORKITEM WI 
				JOIN WTS_RESOURCE RES ON WI.ASSIGNEDRESOURCEID = RES.WTS_RESOURCEID
				WHERE WI.STATUSID IN (SELECT STATUSID FROM STATUS WHERE STATUSTYPEID = 1 AND ARCHIVE = 0 AND STATUSID NOT IN (7, 8, 9, 10, 15, 70, 72)) 
				-- AND WI.ProductVersionID IN (27, 28, 29, 30)
				AND WI.ARCHIVE = 0 
				AND WI.WorkTypeID IN (3, 14) 
				AND WI.PRIORITYID IN (20, 1) 
				AND WI.ASSIGNEDRESOURCEID = @ResID)

				IF @TaskCount > 0 
				BEGIN

					DECLARE Summary_cursor CURSOR FOR 

						-- TOP 3 Per resource (Critical or high, etc...)
						SELECT TOP 3 RES.FIRST_NAME + ' ' + RES.LAST_NAME AS Name, WTS.WTS_SYSTEM + ' - ' + Title AS Title, WORKITEMID AS 'Task ID'  --, PRIORITYID, PrimaryBusinessRank, RESOURCEPRIORITYRANK, ProductVersionID 
						--SELECT TOP 3 RES.FIRST_NAME + ' ' + RES.LAST_NAME AS Name, REPLACE(Title, '&', 'and'), REPLACE([Description], '&', 'and'), WORKITEMID AS 'Task ID'  --, PRIORITYID, PrimaryBusinessRank, RESOURCEPRIORITYRANK, ProductVersionID 
						FROM WORKITEM WI 
						JOIN WTS_RESOURCE RES ON WI.ASSIGNEDRESOURCEID = RES.WTS_RESOURCEID
						
						JOIN WTS_SYSTEM WTS ON WI.WTS_SYSTEMID = WTS.WTS_SYSTEMID

						WHERE WI.STATUSID IN (SELECT STATUSID FROM STATUS WHERE STATUSTYPEID = 1 AND ARCHIVE = 0 AND STATUSID NOT IN (7, 8, 9, 10, 15, 70, 72)) 
						-- AND WI.ProductVersionID IN (27, 28, 29, 30)
						AND WI.ARCHIVE = 0 
						AND WI.WorkTypeID IN (3, 14) 
						AND WI.PRIORITYID IN (20, 1) 
						AND WI.ASSIGNEDRESOURCEID = @ResID
						ORDER BY WI.PRIORITYID DESC, WI.PrimaryBusinessRank, WI.RESOURCEPRIORITYRANK;   -- RES.FIRST_NAME, RES.LAST_NAME, 

						OPEN Summary_cursor

						FETCH NEXT FROM Summary_cursor
						INTO @ResName
						,@Title
						--,@Description
						,@WorkitemID

						WHILE @@FETCH_STATUS = 0
						BEGIN
						-- Description contains HTML, remove for now
							SET @TableSummaryHTML = @TableSummaryHTML + N'<tr>';
							SET @TableSummaryHTML = @TableSummaryHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">' + @ResName + N'</td>';
							SET @TableSummaryHTML = @TableSummaryHTML + N'<td style="border: 1px solid gray; border-top: none; text-align: left;">' + @Title + N'</td>';
							SET @TableSummaryHTML = @TableSummaryHTML + N'<td style="border: 1px solid gray; border-top: none; text-align: center;">' + CAST(@WorkitemID AS NVARCHAR(50)) + N'</td>';
							SET @TableSummaryHTML = @TableSummaryHTML + N'</tr>';

							FETCH NEXT FROM Summary_cursor
							INTO @ResName
							,@Title
							--,@Description
							,@WorkitemID
						END;

					CLOSE Summary_cursor
					DEALLOCATE Summary_cursor

				END;  -- Resource has at least 1 task

				DECLARE LastThree_cursor CURSOR FOR 

					SELECT TOP 3 WORKITEMID FROM WORKITEM 
					WHERE STATUSID IN (10, 70) AND ASSIGNEDRESOURCEID = @ResID
					ORDER BY UPDATEDDATE DESC;

					OPEN LastThree_cursor

					SET @LastThreeClosed = '';

					FETCH NEXT FROM LastThree_cursor
					INTO @WorkItemIDChar

					WHILE @@FETCH_STATUS = 0
					BEGIN

						SET @LastThreeClosed = @LastThreeClosed + @WorkItemIDChar + ';';
							
						FETCH NEXT FROM LastThree_cursor
					INTO @WorkItemIDChar
					END;

				CLOSE LastThree_cursor
				DEALLOCATE LastThree_cursor

				SET @CriticalCount = (SELECT COUNT (*) AS 'Critical' FROM WORKITEM WHERE PRIORITYID = 20 
				AND STATUSID IN (SELECT STATUSID FROM STATUS WHERE STATUSTYPEID = 1 AND ARCHIVE = 0 AND STATUSID NOT IN (7, 8, 9, 10, 15, 70, 72)) AND ASSIGNEDRESOURCEID = @ResID);
				SET @HighCount = (SELECT COUNT (*) AS 'Critical' FROM WORKITEM WHERE PRIORITYID = 1 
				AND STATUSID IN (SELECT STATUSID FROM STATUS WHERE STATUSTYPEID = 1 AND ARCHIVE = 0 AND STATUSID NOT IN (7, 8, 9, 10, 15, 70, 72)) AND ASSIGNEDRESOURCEID = @ResID);
				SET @MediumCount = (SELECT COUNT (*) AS 'Critical' FROM WORKITEM WHERE PRIORITYID = 2 
				AND STATUSID IN (SELECT STATUSID FROM STATUS WHERE STATUSTYPEID = 1 AND ARCHIVE = 0 AND STATUSID NOT IN (7, 8, 9, 10, 15, 70, 72)) AND ASSIGNEDRESOURCEID = @ResID);
				SET @LowCount = (SELECT COUNT (*) AS 'Critical' FROM WORKITEM WHERE PRIORITYID = 3 
				AND STATUSID IN (SELECT STATUSID FROM STATUS WHERE STATUSTYPEID = 1 AND ARCHIVE = 0 AND STATUSID NOT IN (7, 8, 9, 10, 15, 70, 72)) AND ASSIGNEDRESOURCEID = @ResID);

				SET @PriorityHTML = @PriorityHTML + N'<tr>';
				SET @PriorityHTML = @PriorityHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">' + @ResName + N'</td>';
				SET @PriorityHTML = @PriorityHTML + N'<td style="border: 1px solid gray; border-top: none; text-align: center;">' + CAST(@CriticalCount AS NVARCHAR(50)) + N'</td>';
				SET @PriorityHTML = @PriorityHTML + N'<td style="border: 1px solid gray; border-top: none; text-align: center;">' + CAST(@HighCount AS NVARCHAR(50)) + N'</td>';
				SET @PriorityHTML = @PriorityHTML + N'<td style="border: 1px solid gray; border-top: none; text-align: center;">' + CAST(@MediumCount AS NVARCHAR(50)) + N'</td>';
				SET @PriorityHTML = @PriorityHTML + N'<td style="border: 1px solid gray; border-top: none; text-align: center;">' + CAST(@LowCount AS NVARCHAR(50)) + N'</td>';
				SET @PriorityHTML = @PriorityHTML + N'<td style="border: 1px solid gray; border-top: none; text-align: left;">' + @LastThreeClosed + N'</td>';
				SET @PriorityHTML = @PriorityHTML + N'</tr>';

			SET @activeAssigned = STUFF(@activeAssigned, 1, CharIndex(',', @activeAssigned+','), '');
		END  -- Resource loop

		SET @PriorityHTML = @PriorityHTML + N'</table><br />';
		SET @TableSummaryHTML = @TableSummaryHTML + N'</table><br />';
		SET @TableSummaryHTML = @TableSummaryHTML + @PriorityHTML;

--=======================================================================================================
-- Per Resource - Counts by Priority and last 3 closed - Above
--=======================================================================================================

--=======================================================================================================
--   Last 10 Closed table below
--=======================================================================================================

		DECLARE CLosed_cursor CURSOR FOR 
		
		--SELECT TOP 10 TITLE, WORKITEMID FROM WORKITEM 
		--WHERE STATUSID IN (10, 70)
		--ORDER BY UPDATEDDATE DESC;

		SELECT TOP 10  WTS_SYSTEM + ' - ' + TITLE AS TITLE, WORKITEMID FROM WORKITEM WI 
		JOIN WTS_SYSTEM SYS ON WI.WTS_SYSTEMID = SYS.WTS_SYSTEMID
		WHERE STATUSID IN (10, 70)
		ORDER BY WI.UPDATEDDATE DESC;
		OPEN CLosed_cursor

		FETCH NEXT FROM CLosed_cursor
		INTO @Resource
		,@allocation


		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @count += 1;
			SET @ClosedTableHTML = @ClosedTableHTML + N'<tr><td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">' + @Resource + N'</td>';
			SET @ClosedTableHTML = @ClosedTableHTML + N'<td style="border: 1px solid gray; border-top: none; text-align: center;">' + @allocation + N'</td></tr>';

			FETCH NEXT FROM CLosed_cursor
			INTO @Resource
			,@allocation
		END;

		CLOSE CLosed_cursor
		DEALLOCATE CLosed_cursor

		SET @tableHTML = @tableHTML + N'<table cellpadding="0" cellspacing="0">';
		SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="300">Last Ten Closed - Title</th>';
		SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="100">WorkItem ID</th>';
		SET @tableHTML = @tableHTML + @ClosedTableHTML + N'</table><br /><br />';

--=======================================================================================================
--   Last 10 Closed table above		
--=======================================================================================================

--=======================================================================================================
--  Open Duration below 
--=======================================================================================================

	SET @DurationTable = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';
	SET @DurationTable = @DurationTable + N'<table cellpadding="0" cellspacing="0">';
	SET @DurationTable = @DurationTable + N'<th style="border: 1px solid gray;" width="95">Average Open Duration (Days)</th>';
	SET @DurationTable = @DurationTable + N'<tr>';

	DECLARE WTSSystemCursor CURSOR FOR 

	SELECT WTS_SYSTEMID, WTS_SYSTEM FROM WTS_SYSTEM 
	WHERE WTS_SYSTEMID IN (4, 5, 7, 8, 11, 14, 17, 18, 21, 25, 29, 32, 38) 
	AND ARCHIVE = 0
	ORDER BY SORT_ORDER; 

	OPEN WTSSystemCursor

	FETCH NEXT FROM WTSSystemCursor
	INTO @SysID,
		@SysName

	WHILE @@FETCH_STATUS = 0
	BEGIN
	-- WTS_System loop begin --------------------------------------------------

	DECLARE CountCursor CURSOR FOR 

   	 SELECT WORKITEMID,  
		IsnULL(DATEDIFF(d, (SELECT MIN(UPDATEDDATE) FROM WorkItem_History 
		WHERE WORKITEMID = WT.WORKITEMID 
		AND ITEM_UPDATETYPEID = 5
		AND UPPER(FieldChanged) = 'STATUS' 
		AND UPPER(NewValue) in ('IN PROGRESS'))
		, 
		(SELECT MAX(UPDATEDDATE) FROM WorkItem_History 
		WHERE WORKITEMID = WT.WORKITEMID 
		AND ITEM_UPDATETYPEID = 5 
		AND UPPER(FieldChanged) = 'STATUS' 
		AND UPPER(NewValue) in ('CLOSED'))), 0) 
	FROM WORKITEM WT
		WHERE WTS_SYSTEMID = @SysID
		AND WT.STATUSID IN (9, 10, 15, 70)

	SET @TotalCount = 0;
	SET @WorkItemCount = 0;

	OPEN CountCursor

	FETCH NEXT FROM CountCursor
	INTO @WorkItemID,
		@DaysCount

	WHILE @@FETCH_STATUS = 0
	BEGIN
	-- Count loop begin  -----------------------------------------------------

	IF @DaysCount > 0
	BEGIN
	  SET @TotalCount = @TotalCount + @DaysCount;
	  SET @WorkItemCount = @WorkItemCount + 1;
	END;

	-- Count loop end  -------------------------------------------------------

	FETCH NEXT FROM CountCursor
	INTO @WorkItemID,
		@DaysCount
	END;  --> Fetch

	CLOSE CountCursor;
	DEALLOCATE CountCursor;


--=========  In Progress to Deployed - Below  ============================

	DECLARE CountCursor2 CURSOR FOR 

   	 SELECT WORKITEMID,  
		IsnULL(DATEDIFF(d, (SELECT MIN(UPDATEDDATE) FROM WorkItem_History 
		WHERE WORKITEMID = WT.WORKITEMID 
		AND ITEM_UPDATETYPEID = 5
		AND UPPER(FieldChanged) = 'STATUS' 
		AND UPPER(NewValue) in ('IN PROGRESS'))
		, 
		(SELECT MAX(UPDATEDDATE) FROM WorkItem_History 
		WHERE WORKITEMID = WT.WORKITEMID 
		AND ITEM_UPDATETYPEID = 5 
		AND UPPER(FieldChanged) = 'STATUS' 
		AND UPPER(NewValue) in ('DEPLOYED'))), 0) 
		AS 'Days Open'
	FROM WORKITEM WT
		WHERE WTS_SYSTEMID = @SysID
		AND WT.STATUSID IN (9, 10, 15, 70)
		

	SET @TotalCount2 = 0;
	SET @WorkItemCount2 = 0;

	OPEN CountCursor2
	
	FETCH NEXT FROM CountCursor2
	INTO @WorkItemID2,
		@Count2

	WHILE @@FETCH_STATUS = 0
	BEGIN
	-- Count loop begin  -----------------------------------------------------

	IF @Count2 > 0
	BEGIN
	  SET @TotalCount2 = @TotalCount2 + @Count2;
	  SET @WorkItemCount2 = @WorkItemCount2 + 1;
	END;

	-- Count loop end  -------------------------------------------------------

	FETCH NEXT FROM CountCursor2
	INTO @WorkItemID2,
		@Count2
	END;  --> Fetch

	CLOSE CountCursor2;
	DEALLOCATE CountCursor2;


	IF @WorkItemCount2 > 0
	BEGIN
		SET @AverageDays2 = @TotalCount2 / @WorkItemCount2;
		IF @AverageDays2 > 0
		BEGIN
			SET @DurationText = 'Average time to Deploy for ' + @SysName + ' was ' + CAST(@AverageDays2 AS VARCHAR(100)) + ' days.';
			SET @DurationTable = @DurationTable + N'<td style="border: 1px solid gray; border-top: none; text-align: left;">' + @DurationText + N'</td></tr>';
		END;
	END;

--========= In Progress to Deployed - ABOVE ==============================

	IF @WorkItemCount > 0
	BEGIN
		SET @AverageDays = @TotalCount / @WorkItemCount;
		IF @AverageDays > 0
		BEGIN
			SET @DurationText = 'Average time to Close for ' + @SysName + ' was ' + CAST(@AverageDays AS VARCHAR(100)) + ' days.';
			SET @DurationTable = @DurationTable + N'<td style="border: 1px solid gray; border-top: none; text-align: left;">' + @DurationText + N'</td></tr>';
		END;
	END;

	-- WTS_System loop end ----------------------------------------------------

	FETCH NEXT FROM WTSSystemCursor
	INTO @SysID, 
		@SysName
	END;  --> Fetch

	CLOSE WTSSystemCursor;
	DEALLOCATE WTSSystemCursor;

	SET @DurationTable = @DurationTable + N'<td style="border: 1px solid gray; border-top: none; text-align: left;">' + ' ' + N'</td></tr>';
	SET @DurationTable = @DurationTable + N'</table><br /><br />';

--=======================================================================================================
--  Open Duration above
--=======================================================================================================

--=======================================================================================================
--  Open Duration BY ALLOCATION - Below
--=======================================================================================================

	SET @DurationAllocationTable = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';
	SET @DurationAllocationTable = @DurationAllocationTable + N'<table cellpadding="0" cellspacing="0">';
	SET @DurationAllocationTable = @DurationAllocationTable + N'<th style="border: 1px solid gray;" width="95">Average Open Duration - By Allocation (Days)</th>';
	SET @DurationAllocationTable = @DurationAllocationTable + N'<tr>';

	SET @TotalAllocationCount= 0;
	SET @LineCount= 0;
	SET @PreviousAllocationName = '';

	DECLARE AllocDurCursor CURSOR FOR 

   	 SELECT LTRIM(RTRIM(A.ALLOCATION)) AS Allocation, 
		IsnULL(DATEDIFF(d, (SELECT MIN(UPDATEDDATE) FROM WorkItem_History 
		WHERE WORKITEMID = WT.WORKITEMID 
		AND ITEM_UPDATETYPEID = 5
		AND UPPER(FieldChanged) = 'STATUS' 
		AND UPPER(NewValue) in ('IN PROGRESS'))
		, 
		(SELECT MAX(UPDATEDDATE) FROM WorkItem_History 
		WHERE WORKITEMID = WT.WORKITEMID 
		AND ITEM_UPDATETYPEID = 5 
		AND UPPER(FieldChanged) = 'STATUS' 
		AND UPPER(NewValue) in ('CLOSED'))), 0) AS [Count]
	FROM WORKITEM WT
		LEFT JOIN ALLOCATION A ON WT.ALLOCATIONID = A.ALLOCATIONID 
		WHERE WTS_SYSTEMID = 1
		AND WT.STATUSID IN (9, 10, 15, 70) 
		GROUP BY ALLOCATION, WORKITEMID 
		ORDER BY ALLOCATION;

	OPEN AllocDurCursor

	FETCH NEXT FROM AllocDurCursor
	INTO @AllocationName,
		@AllocationCount

	WHILE @@FETCH_STATUS = 0
	BEGIN  -- Level 1
		-- Alloc Duration loop begin --------------------------------------------------

		IF @PreviousAllocationName = ''  -- First time through  -- Level 2
			BEGIN
				SET @PreviousAllocationName = @AllocationName;
			
				SET @TotalAllocationCount = @AllocationCount;
				SET @LineCount = 1;
			END;
		ELSE  -- Level 2
			BEGIN
				IF @PreviousAllocationName <> @AllocationName  -- New Allocation. 
					BEGIN
						IF @TotalAllocationCount > 0  -- Won't ever have devide by 0 error then.
						BEGIN
							SET @AverageDays = @TotalAllocationCount / @LineCount;
							IF @AverageDays > 0
							BEGIN
								SET @DurationText = 'Average time to Close for [' + @PreviousAllocationName + '] was ' + CAST(@AverageDays AS VARCHAR(100)) + ' days.';
								SET @DurationAllocationTable = @DurationAllocationTable + N'<td style="border: 1px solid gray; border-top: none; text-align: left;">' + @DurationText + N'</td></tr>';
							END
						END;
						-- Start new accumulations
						SET @PreviousAllocationName = @AllocationName;
						SET @TotalAllocationCount = @AllocationCount;
						SET @LineCount = 1;
					END;
				ELSE -- IF @PreviousAllocationName = @AllocationName  -- Same Allocation, accumulate counts  -- Level 3
					BEGIN
						SET @TotalAllocationCount = @TotalAllocationCount + @AllocationCount;
						SET @LineCount = @LineCount + 1;
					END;
		END; -- Level 1
		-- Alloc Duration loop end --------------------------------------------------
		FETCH NEXT FROM AllocDurCursor
		INTO @AllocationName,
			@AllocationCount
	END;  --> Fetch

	CLOSE AllocDurCursor;
	DEALLOCATE AllocDurCursor;


	SET @DurationAllocationTable = @DurationAllocationTable + N'<td style="border: 1px solid gray; border-top: none; text-align: left;">' + ' ' + N'</td></tr>';
	SET @DurationAllocationTable = @DurationAllocationTable + N'</table><br /><br />';

--=======================================================================================================
--  Open Duration BY ALLOCATION - Above
--=======================================================================================================

--==========================================================================================================================
--  MAIN Table below
--==========================================================================================================================

		 DECLARE hotlist_cursor CURSOR FOR
		WITH w_Filtered AS (
			SELECT
				wi.*
			FROM
				WORKITEM wi
			WHERE (@ProdStatus IS NULL OR wi.ProductionStatusID IN (SELECT * FROM Split(@ProdStatus, ',')))
				AND (
					(@TechMin IS NULL OR @TechMax IS NULL OR wi.RESOURCEPRIORITYRANK BETWEEN @TechMin AND @TechMax) AND (@BusMin IS NULL OR @BusMax IS NULL OR wi.PrimaryBusinessRank BETWEEN @BusMin AND @BusMax)
					-- SCB Changed from OR's to AND's to limit to only 1's - as currently set.
					--(@TechMin IS NULL OR @TechMax IS NULL OR wi.RESOURCEPRIORITYRANK BETWEEN @TechMin AND @TechMax) OR (@BusMin IS NULL OR @BusMax IS NULL OR wi.PrimaryBusinessRank BETWEEN @BusMin AND @BusMax)
					--(@TechMin IS NULL OR @TechMax IS NULL OR wi.RESOURCEPRIORITYRANK BETWEEN @TechMin + 4 AND @TechMax + 4) OR (@BusMin IS NULL OR @BusMax IS NULL OR wi.PrimaryBusinessRank BETWEEN @BusMin + 4 AND @BusMax + 4)
					)
				AND (@activeAssigned IS NULL OR wi.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@activeAssigned, ',')))
				AND (@activeStatus IS NULL OR wi.STATUSID IN (SELECT * FROM Split(@activeStatus, ',')))
		)
		, w_Sub_Task_Count AS (
			SELECT
				wi.WORKITEMID
				, ISNULL(SUM(1),0) AS Total_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.STATUSID NOT IN (3,6,10) THEN 1 END),0) AS Open_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.STATUSID = 6 THEN 1 END),0) AS OnHold_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.STATUSID = 3 THEN 1 END),0) AS InfoRequested_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.STATUSID = 1 THEN 1 END),0) AS New_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.STATUSID = 5 THEN 1 END),0) AS InProgress_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.STATUSID = 2 THEN 1 END),0) AS ReOpened_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.STATUSID = 4 THEN 1 END),0) AS InfoProvided_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.STATUSID = 7 THEN 1 END),0) AS UnReproducible_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.STATUSID = 8 THEN 1 END),0) AS CheckedIn_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.STATUSID = 9 THEN 1 END),0) AS Deployed_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.STATUSID = 10 THEN 1 END),0) AS Closed_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.PRIORITYID = 1 THEN 1 END),0) AS High_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.PRIORITYID = 2 THEN 1 END),0) AS Medium_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.PRIORITYID = 3 THEN 1 END),0) AS Low_Items_Sub
				, ISNULL(SUM(CASE WHEN wit.PRIORITYID = 4 THEN 1 END),0) AS NA_Items_Sub
			FROM
				WORKITEM wi
					JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
					JOIN WORKITEM_TASK wit ON wi.WORKITEMID = wit.WORKITEMID
					JOIN [STATUS] s ON wit.STATUSID = s.STATUSID
			WHERE (
				(@BusMin IS NULL OR @BusMax IS NULL OR wit.BusinessRank BETWEEN @BusMin AND @BusMax)
				--(@TechMin IS NULL OR @TechMax IS NULL OR wit.SORT_ORDER BETWEEN @TechMin AND @TechMax) AND (@BusMin IS NULL OR @BusMax IS NULL OR wit.BusinessRank BETWEEN @BusMin AND @BusMax)
				--(@TechMin IS NULL OR @TechMax IS NULL OR wit.SORT_ORDER BETWEEN @TechMin AND @TechMax) OR (@BusMin IS NULL OR @BusMax IS NULL OR wit.BusinessRank BETWEEN @BusMin AND @BusMax)
				)
				AND (@activeAssigned IS NULL OR wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@activeAssigned, ',')))
				AND (@activeStatus IS NULL OR wit.STATUSID IN (SELECT * FROM Split(@activeStatus, ',')))
			GROUP BY wi.WORKITEMID
		)
		SELECT DISTINCT
			ws.SORT_ORDER AS System_Sort
			, ws.WTS_SYSTEMID
			, ws.WTS_SYSTEM
			, ISNULL(SUM(1),0) AS Total_Items
			, ISNULL(SUM(CASE WHEN wi.STATUSID NOT IN (3,6,10) THEN 1 END),0) AS Open_Items
			, ISNULL(SUM(CASE WHEN wi.STATUSID = 6 THEN 1 END),0) AS OnHold_Items
			, ISNULL(SUM(CASE WHEN wi.STATUSID = 3 THEN 1 END),0) AS InfoRequested_Items
			, ISNULL(SUM(CASE WHEN wi.STATUSID = 1 THEN 1 END),0) AS New_Items
			, ISNULL(SUM(CASE WHEN wi.STATUSID = 5 THEN 1 END),0) AS InProgress_Items
			, ISNULL(SUM(CASE WHEN wi.STATUSID = 2 THEN 1 END),0) AS ReOpened_Items
			, ISNULL(SUM(CASE WHEN wi.STATUSID = 4 THEN 1 END),0) AS InfoProvided_Items
			, ISNULL(SUM(CASE WHEN wi.STATUSID = 7 THEN 1 END),0) AS UnReproducible_Items
			, ISNULL(SUM(CASE WHEN wi.STATUSID = 8 THEN 1 END),0) AS CheckedIn_Items
			, ISNULL(SUM(CASE WHEN wi.STATUSID = 9 THEN 1 END),0) AS Deployed_Items
			, ISNULL(SUM(CASE WHEN wi.STATUSID = 10 THEN 1 END),0) AS Closed_Items
			, ISNULL(SUM(wst.Total_Items_Sub),0) AS Total_Items_Sub
			, ISNULL(SUM(wst.Open_Items_Sub),0) AS Open_Items_Sub
			, ISNULL(SUM(wst.OnHold_Items_Sub),0) AS OnHold_Items_Sub
			, ISNULL(SUM(wst.InfoRequested_Items_Sub),0) AS InfoRequested_Items_Sub
			, ISNULL(SUM(wst.New_Items_Sub),0) AS New_Items_Sub
			, ISNULL(SUM(wst.InProgress_Items_Sub),0) AS InProgress_Items_Sub
			, ISNULL(SUM(wst.ReOpened_Items_Sub),0) AS ReOpened_Items_Sub
			, ISNULL(SUM(wst.InfoProvided_Items_Sub),0) AS InfoProvided_Items_Sub
			, ISNULL(SUM(wst.UnReproducible_Items_Sub),0) AS UnReproducible_Items_Sub
			, ISNULL(SUM(wst.CheckedIn_Items_Sub),0) AS CheckedIn_Items_Sub
			, ISNULL(SUM(wst.Deployed_Items_Sub),0) AS Deployed_Items_Sub
			, ISNULL(SUM(wst.Closed_Items_Sub),0) AS Closed_Items_Sub
		FROM
			w_Filtered wi
				JOIN WTS_System ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
				JOIN w_Filtered wf ON wi.WORKITEMID = wf.WORKITEMID
				LEFT JOIN w_Sub_Task_Count wst on wi.WORKITEMID = wst.WORKITEMID
		GROUP BY ws.SORT_ORDER, ws.WTS_SYSTEMID, ws.WTS_SYSTEM
		HAVING ISNULL(SUM(CASE WHEN wi.STATUSID NOT IN (3,6,10) THEN 1 END),0) > 0
		ORDER BY System_Sort, ws.WTS_SYSTEM;

-- 11-21-16 Moved this from above:
--		SET @tableHTML = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';

		SET @tableHTML = @tableHTML + N'<table cellpadding="0" cellspacing="0"><tr>';

		SET @tableHTML = @tableHTML + N'<th colspan="2" style="border: 1px solid gray;" width="115">System</th>';
		SET @tableHTML = @tableHTML + N'<th rowspan="2" style="border: 1px solid gray; border-left: none;" width="65"># Tasks_temp2</th>';
		SET @tableHTML = @tableHTML + N'<th rowspan="2" style="border: 1px solid gray; border-left: none;" width="65">Open_temp2</th>';
		SET @tableHTML = @tableHTML + N'<th colspan="2" style="border: 1px solid gray; border-left: none;" width="170">On Hold_temp1</th>';
		SET @tableHTML = @tableHTML + N'<th colspan="5" style="border: 1px solid gray; border-left: none;" width="420">Open_temp1</th>';
		SET @tableHTML = @tableHTML + N'<th colspan="2" style="border: 1px solid gray; border-left: none;" width="150">Awaiting Closure_temp1</th>';
		SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none;" width="60">Closed_temp1</th>';
		SET @tableHTML = @tableHTML + N'<th rowspan="2" style="border: 1px solid gray; border-left: none;" width="70">% On Hold</th>';
		SET @tableHTML = @tableHTML + N'<th rowspan="2" style="border: 1px solid gray; border-left: none;" width="65">% Open</th>';
		SET @tableHTML = @tableHTML + N'<th rowspan="2" style="border: 1px solid gray; border-left: none;" width="65">% Closed</th>';

		SET @tableHTML = @tableHTML + N'</tr><tr>';

		SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-top: none;" width="65">Priority</th><th style="border: 1px solid gray; border-left: none; border-top: none;" width="50">System</th>';
		SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; border-top: none;" width="65">On Hold_temp2</th><th style="border: 1px solid gray; border-left: none; border-top: none;" width="105">Info Requested_temp2</th>';
		SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; border-top: none;" width="45">New_temp2</th><th style="border: 1px solid gray; border-left: none; border-top: none;" width="85">In Progress_temp2</th><th style="border: 1px solid gray; border-left: none; border-top: none;" width="85">Re-Opened_temp2</th><th style="border: 1px solid gray; border-left: none; border-top: none;" width="95">Info Provided_temp2</th><th style="border: 1px solid gray; border-left: none; border-top: none;" width="115">Un-Reproducible_temp2</th>';
		SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; border-top: none;" width="80">Checked In_temp2</th><th style="border: 1px solid gray; border-left: none; border-top: none;" width="70">Deployed_temp2</th>';
		SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; border-top: none;" width="60">Closed_temp2</th>';

		SET @tableHTML = @tableHTML + N'</tr>';

		OPEN hotlist_cursor

		FETCH NEXT FROM hotlist_cursor
		INTO @systemSort
			, @systemID
			, @system
			, @totalItems
			, @openItems
			, @onHoldItems
			, @infoRequestedItems
			, @newItems
			, @inProgressItems
			, @reOpenedItems
			, @infoProvidedItems
			, @unReproducibleItems
			, @checkedInItems
			, @deployedItems
			, @closedItems
			, @totalItemsSub
			, @openItemsSub
			, @onHoldItemsSub
			, @infoRequestedItemsSub
			, @newItemsSub
			, @inProgressItemsSub
			, @reOpenedItemsSub
			, @infoProvidedItemsSub
			, @unReproducibleItemsSub
			, @checkedInItemsSub
			, @deployedItemsSub
			, @closedItemsSub

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @count += 1;

			SET @tableHTML = @tableHTML + N'<tr>';
			SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), ISNULL(@systemSort, '&nbsp;')) + N'</td><td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + '">' + @system + N'</td>';
			SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @totalItems) + N' / ' + convert(nvarchar(10), @totalItemsSub) + N'</td><td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @openItems) + N' / ' + convert(nvarchar(10), @openItemsSub) + N'</td>';
			SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @onHoldItems) + N' / ' + convert(nvarchar(10), @onHoldItemsSub) + N'</td><td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @infoRequestedItems) + N' / ' + convert(nvarchar(10), @infoRequestedItemsSub) + N'</td>';
			SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @newItems) + N' / ' + convert(nvarchar(10), @newItemsSub) + N'</td><td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @inProgressItems) + N' / ' + convert(nvarchar(10), @inProgressItemsSub) + N'</td><td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @reOpenedItems) + N' / ' + convert(nvarchar(10), @reOpenedItemsSub) + N'</td><td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @infoProvidedItems) + N' / ' + convert(nvarchar(10), @infoProvidedItemsSub) + N'</td><td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @unReproducibleItems) + N' / ' + convert(nvarchar(10), @unReproducibleItemsSub) + N'</td>';
			SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @checkedInItems) + N' / ' + convert(nvarchar(10), @checkedInItemsSub) + N'</td><td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @deployedItems) + N' / ' + convert(nvarchar(10), @deployedItemsSub) + N'</td>';
			SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), @closedItems) + N' / ' +convert(nvarchar(10),  @closedItemsSub) + N'</td>';
			SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), case when @totalItems = 0 then 0 else round((@onHoldItems / @totalItems) * 100, 1) end) + N' / ' + convert(nvarchar(10), case when @totalItemsSub = 0 then 0 else round((@onHoldItemsSub / @totalItemsSub) * 100, 1) end) + N'</td><td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), case when @totalItems = 0 then 0 else round((@openItems / @totalItems) * 100, 1) end) + N' / ' + convert(nvarchar(10), case when @totalItemsSub = 0 then 0 else round((@openItemsSub / @totalItemsSub) * 100, 1) end) + N'</td><td style="border: 1px solid gray; border-left: none; ' + (case when @count = 1 then 'border-top: none; ' else '' end) + 'text-align: center;">' + convert(nvarchar(10), case when @totalItems = 0 then 0 else round((@closedItems / @totalItems) * 100, 1) end) + N' / ' + convert(nvarchar(10), case when @totalItemsSub = 0 then 100 else round((@closedItemsSub / @totalItemsSub) * 100, 1) end) + N'</td>';
			SET @tableHTML = @tableHTML + N'</tr>';

				DECLARE workload_cursor CURSOR FOR
				WITH w_Filtered AS (
					SELECT
						wi.*
						,prodStatus.STATUS AS 'Production Status'
					FROM
						WORKITEM wi
							--JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
							--JOIN [PRIORITY] pt ON wi.RESOURCEPRIORITYRANK = pt.PRIORITYID
							LEFT JOIN [STATUS] AS prodStatus ON wi.ProductionStatusID = prodStatus.STATUSID
					WHERE  wi.WTS_SYSTEMID = @systemID
					AND (@ProdStatus IS NULL OR wi.ProductionStatusID IN (SELECT * FROM Split(@ProdStatus, ',')))
				AND (
					(@TechMin IS NULL OR @TechMax IS NULL OR wi.RESOURCEPRIORITYRANK BETWEEN @TechMin AND @TechMax) AND (@BusMin IS NULL OR @BusMax IS NULL OR wi.PrimaryBusinessRank BETWEEN @BusMin AND @BusMax)
					--(@TechMin IS NULL OR @TechMax IS NULL OR wi.RESOURCEPRIORITYRANK BETWEEN @TechMin AND @TechMax) OR (@BusMin IS NULL OR @BusMax IS NULL OR wi.PrimaryBusinessRank BETWEEN @BusMin AND @BusMax)
					--(@TechMin IS NULL OR @TechMax IS NULL OR wi.RESOURCEPRIORITYRANK BETWEEN @TechMin + 4 AND @TechMax + 4) OR (@BusMin IS NULL OR @BusMax IS NULL OR wi.PrimaryBusinessRank BETWEEN @BusMin + 4 AND @BusMax + 4)
					)
				AND (@activeAssigned IS NULL OR wi.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@activeAssigned, ',')))
				AND (@activeStatus IS NULL OR wi.STATUSID IN (SELECT * FROM Split(@activeStatus, ',')))
						/*AND ((UPPER(s.STATUS) IN ('IN PROGRESS','NEW','ON HOLD','RE-OPENED','UN-REPRODUCIBLE')
						AND pt.[PRIORITY] = '1') OR wi.WORKITEMID IN (
							SELECT
								wit.WORKITEMID
							FROM
								WORKITEM_TASK wit
									JOIN [STATUS] s on wit.STATUSID = s.STATUSID
							WHERE
								UPPER(s.[STATUS]) IN ('IN PROGRESS','NEW','ON HOLD','RE-OPENED','UN-REPRODUCIBLE')
								AND wit.SORT_ORDER = 1
						))*/
				)
				,AssignedTo_Developer AS(
					SELECT 
					 hs.WORKITEMID
					,hs.UPDATEDDATE 
					FROM WorkItem_History as hs
					LEFT JOIN WTS_RESOURCE AS wr ON wr.FIRST_NAME + ' ' + wr.LAST_NAME = hs.NewValue
					WHERE FieldChanged = 'Assigned To' AND wr.ORGANIZATIONID = 2
				)
				,MostRecentAssigned_Change AS(
					SELECT WORKITEMID
					,MAX([Assigned Date]) AS 'Assigned Date'
					FROM (
						SELECT wi.WORKITEMID
						,ISNULL(assignD.UPDATEDDATE, wi.CREATEDDATE) AS 'Assigned Date'
						,wr.ORGANIZATIONID
						FROM WORKITEM wi
						LEFT JOIN AssignedTo_Developer assignD ON assignD.WORKITEMID = wi.WORKITEMID
						LEFT JOIN WTS_RESOURCE wr ON wr.WTS_RESOURCEID = wi.ASSIGNEDRESOURCEID
						WHERE wr.ORGANIZATIONID = 2 OR assignD.WORKITEMID IS NOT NULL  
						) AS ID_ORGANIZATION_ASSIGNED
					GROUP BY WORKITEMID
				)
				SELECT
					wi.WORKITEMID
					, ws.WTS_SYSTEM
					, s.[STATUS]
					, wi.TITLE
					,bpt.[PRIORITY] AS PrimaryBusinessRank
					, PT.[PRIORITY] AS RESOURCEPRIORITYRANK
					, wa.WorkArea
					, wg.WorkloadGroup
					, wi.[Production Status]
					, pv.ProductVersion
					, p.[PRIORITY]
					, ar.FIRST_NAME + ' ' + ar.LAST_NAME AS Assigned
					, pd.FIRST_NAME + ' ' + pd.LAST_NAME AS Primary_Developer
					, ISNULL(wi.COMPLETIONPERCENT,0) AS Progress
					, CASE UPPER(s.[STATUS]) WHEN 'TRAVEL' THEN 0 WHEN 'REQUESTED' THEN 1 WHEN 'INFO REQUESTED' THEN 2 WHEN 'ON HOLD' THEN 4 ELSE 3 END AS Status_Sort
					, DATEDIFF(DAY, wi.CREATEDDATE, GETDATE()) AS 'Open'
					,ISNULL(DATEDIFF(DAY, ac.[Assigned Date], GETDATE()), 0) AS 'Assigned'
				FROM
					w_Filtered wi
						LEFT JOIN WorkArea wa ON wi.WorkAreaID = wa.WorkAreaID
						LEFT JOIN WorkloadGroup wg ON wi.WorkloadGroupID = wg.WorkloadGroupID
						JOIN WTS_SYSTEM ws ON wi.WTS_SYSTEMID = ws.WTS_SYSTEMID
						LEFT JOIN ProductVersion pv ON wi.ProductVersionID = pv.ProductVersionID
						JOIN [PRIORITY] p ON wi.PRIORITYID = p.PRIORITYID
						LEFT JOIN [PRIORITY] pt ON wi.RESOURCEPRIORITYRANK = pt.PRIORITYID
						LEFT JOIN [PRIORITY] bpt ON wi.PrimaryBusinessRank = bpt.PRIORITYID
						LEFT JOIN WTS_RESOURCE ar ON wi.ASSIGNEDRESOURCEID = ar.WTS_RESOURCEID
						JOIN [STATUS] s ON wi.STATUSID = s.STATUSID
						LEFT JOIN WTS_RESOURCE pd ON wi.PRIMARYRESOURCEID = pd.WTS_RESOURCEID
						LEFT JOIN MostRecentAssigned_Change ac ON wi.WORKITEMID = ac.WORKITEMID
				ORDER BY 
					Status_Sort ASC
					, CASE WHEN ISNUMERIC(PT.[PRIORITY]) = 1 THEN CONVERT(int, PT.[PRIORITY]) ELSE 11 END ASC
					, wi.WORKITEMID DESC
				;

				SET @tableHTML = @tableHTML + N'<tr><td colspan="17" style="padding: 10px; padding-left: 20px;"><table cellpadding="0" cellspacing="0"><tr>';

				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; padding: 3px;">Task #</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">System</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Status</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Title</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Primary Bus. Rank</th>'
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Primary Tech. Rank</th>';;
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Assigned To</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Primary Developer</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Work Area</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Functionality</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Production</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Version</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Priority</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Progress</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">d.Open</th>';
				SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">d.Assigned</th>';

				SET @tableHTML = @tableHTML + N'</tr>';

				OPEN workload_cursor

				FETCH NEXT FROM workload_cursor
				INTO @workitemID
					, @itemSystem
					, @status
					, @title
					, @busRank
					, @techRank
					, @workArea
					, @functionality
					, @production
					, @version
					, @priority
					, @assigned
					, @primaryDeveloper
					, @progress
					, @sort
					, @openDays
					, @assignedDays

				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @tableHTML = @tableHTML + N'<tr bgcolor="#fbfcc5">';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + 'text-align: center;">' + convert(nvarchar(10), @workitemID) + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + '">' + @itemSystem + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + '">' + @status + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + '">' + CASE WHEN LEN(@title) > 30 THEN SUBSTRING(@title, 1, 30) + '...' ELSE @title END + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + 'text-align: center;">' + convert(nvarchar(10), ISNULL(@busRank, '&nbsp;')) + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + 'text-align: center;">' + convert(nvarchar(10), ISNULL(@techRank, '&nbsp;')) + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + '">' + ISNULL(@assigned, '&nbsp;') + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + '">' + ISNULL(@primaryDeveloper, '&nbsp;') + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + '">' + ISNULL(@workArea, '&nbsp;') + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + '">' + ISNULL(@functionality, '&nbsp;') + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + '">' + CASE WHEN @production = 'Production' THEN 'Yes' ELSE 'No' END + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + '">' + ISNULL(@version, '&nbsp;') + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + '">' + ISNULL(@priority, '&nbsp;') + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + 'text-align: center;">' + convert(nvarchar(10), @progress) + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + 'text-align: center;">' + convert(nvarchar(10), @openDays) + N'</td>';
					SET @tableHTML = @tableHTML + N'<td style="border: 1px solid gray; border-left: none; ' + (case when @border = 1 then '' else 'border-top: none; ' end) + 'text-align: center;">' + convert(nvarchar(10), @assignedDays) + N'</td>';
					SET @tableHTML = @tableHTML + N'</tr>';
					SET @border = 0;

					DECLARE workload_sub_cursor CURSOR FOR
				WITH AssignedTo_Developer AS(
					SELECT 
					 hs.WORKITEM_TASKID
					,hs.UPDATEDDATE 
					FROM WORKITEM_TASK_HISTORY as hs
					LEFT JOIN WTS_RESOURCE AS wr ON wr.FIRST_NAME + ' ' + wr.LAST_NAME = hs.NewValue
					WHERE FieldChanged = 'Assigned To' AND wr.ORGANIZATIONID = 2
				)
				,MostRecentAssigned_Change AS(
					SELECT WORKITEM_TASKID
					,MAX([Assigned Date]) AS 'Assigned Date'
					FROM (
						SELECT wit.WORKITEM_TASKID
						,ISNULL(assignD.UPDATEDDATE, wit.CREATEDDATE) AS 'Assigned Date'
						,wr.ORGANIZATIONID
						FROM WORKITEM_TASK wit
						LEFT JOIN AssignedTo_Developer assignD ON assignD.WORKITEM_TASKID = wit.WORKITEM_TASKID
						LEFT JOIN WTS_RESOURCE wr ON wr.WTS_RESOURCEID = wit.ASSIGNEDRESOURCEID
						WHERE wr.ORGANIZATIONID = 2 OR assignD.WORKITEM_TASKID IS NOT NULL  
						) AS ID_ORGANIZATION_ASSIGNED
					GROUP BY WORKITEM_TASKID
				)
						SELECT
						convert(nvarchar(10), wit.WORKITEMID) + ' - ' + convert(nvarchar(10), wit.TASK_NUMBER) AS SubTask
						, wit.BusinessRank
						, wit.SORT_ORDER AS TechRank
						, p.[PRIORITY]
						, wit.TITLE
						, au.FIRST_NAME + ' ' + au.LAST_NAME AS AssignedResource
						, pu.FIRST_NAME + ' ' + pu.LAST_NAME AS PrimaryResource
						, CONVERT(VARCHAR(10), wit.ESTIMATEDSTARTDATE, 101) AS ESTIMATEDSTARTDATE
						, CONVERT(VARCHAR(10), wit.ACTUALSTARTDATE, 101) AS ACTUALSTARTDATE
						, (Select EffortSize From EffortSize Where wit.EstimatedEffortID = EffortSizeID) AS PLANNEDHOURS
						, (Select EffortSize From EffortSize Where wit.ActualEffortID = EffortSizeID) AS ACTUALHOURS
						, CONVERT(VARCHAR(10), wit.ACTUALENDDATE, 101) AS ACTUALENDDATE
						, ISNULL(wit.COMPLETIONPERCENT,0) AS COMPLETIONPERCENT
						, s.[STATUS]
						, DATEDIFF(DAY, wit.CREATEDDATE, GETDATE()) AS 'Open'
						,ISNULL(DATEDIFF(DAY, ac.[Assigned Date], GETDATE()), 0) AS 'Assigned'
						, (SELECT COUNT(1) FROM WORKITEM_TASK_HISTORY WHERE WORKITEM_TASKID = wit.WORKITEM_TASKID AND ITEM_UPDATETYPEID = 5 AND UPPER(FieldChanged) = 'STATUS' AND UPPER(OldValue) != 'RE-OPENED' AND UPPER(NewValue) = 'RE-OPENED') AS ReOpenedCount
					FROM
						WORKITEM_TASK wit
							LEFT JOIN [PRIORITY] p ON wit.PRIORITYID = p.PRIORITYID
							LEFT JOIN WTS_RESOURCE au ON wit.ASSIGNEDRESOURCEID = au.WTS_RESOURCEID
							LEFT JOIN WTS_RESOURCE pu ON wit.PRIMARYRESOURCEID = pu.WTS_RESOURCEID
							LEFT JOIN [STATUS] s on wit.STATUSID = s.STATUSID
							LEFT JOIN MostRecentAssigned_Change ac ON ac.WORKITEM_TASKID = wit.WORKITEM_TASKID
					WHERE
						wit.WORKITEMID = @workitemID
						AND(
						 (@BusMin IS NULL OR @BusMax IS NULL OR wit.BusinessRank BETWEEN @BusMin AND @BusMax)
						 --(@TechMin IS NULL OR @TechMax IS NULL OR wit.SORT_ORDER BETWEEN @TechMin AND @TechMax) AND (@BusMin IS NULL OR @BusMax IS NULL OR wit.BusinessRank BETWEEN @BusMin AND @BusMax)
						 --(@TechMin IS NULL OR @TechMax IS NULL OR wit.SORT_ORDER BETWEEN @TechMin AND @TechMax) OR (@BusMin IS NULL OR @BusMax IS NULL OR wit.BusinessRank BETWEEN @BusMin AND @BusMax)
						)
						AND (@activeAssigned IS NULL OR wit.ASSIGNEDRESOURCEID IN (SELECT * FROM Split(@activeAssigned, ',')))
						AND (@activeStatus IS NULL OR wit.STATUSID IN (SELECT * FROM Split(@activeStatus, ',')))
					;

					SET @tableHTML_temp = N'<tr><td colspan="17" style="padding: 10px; padding-left: 20px;"><table cellpadding="0" cellspacing="0"><tr>';

					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; padding: 3px;">Sub-Task #</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Bus. Rank</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Tech. Rank</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Priority</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Title</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Assigned To</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Primary Resource</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Planned Start Date</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Actual Start Date</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Estimated Effort</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Actual Effort</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Actual End Date</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Percent Complete</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Status</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">d.Open</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">d.Assigned</th>';
					SET @tableHTML_temp = @tableHTML_temp + N'<th style="border: 1px solid gray; border-left: none; padding: 3px;">Times Re-Opened</th>';

					SET @tableHTML_temp = @tableHTML_temp + N'</tr>';

					OPEN workload_sub_cursor

					FETCH NEXT FROM workload_sub_cursor
					INTO @subTask
						, @businessRank
						, @subTechRank
						, @subPriority
						, @subTitle
						, @subAssigned
						, @subPrimaryDeveloper
						, @estimatedStart
						, @actualStart
						, @plannedHours
						, @actualHours
						, @actualEnd
						, @percentComplete
						, @subStatus
						, @subOpenDays
						, @subAssignedDays
						, @reOpenedCount
					WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @count_sub += 1;

						SET @tableHTML_temp = @tableHTML_temp + N'<tr bgcolor="#e6e6e6">';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-top: none; text-align: center;">' + @subTask + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none; text-align: center;">' + convert(nvarchar(10), ISNULL(@businessRank, '&nbsp;')) + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none; text-align: center;">' + convert(nvarchar(10), ISNULL(@subTechRank, '&nbsp;')) + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none;">' + ISNULL(@subPriority, '&nbsp;') + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none;">' + (CASE WHEN LEN(@subTitle) > 30 THEN SUBSTRING(@subTitle, 1, 30) + '...' ELSE @subTitle END) + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none;">' + ISNULL(@subAssigned, '&nbsp;') + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none;">' + ISNULL(@subPrimaryDeveloper, '&nbsp;') + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none;">' + ISNULL(@estimatedStart, '&nbsp;') + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none;">' + ISNULL(@actualStart, '&nbsp;') + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none;">' + ISNULL(@plannedHours, '&nbsp;') + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none;">' + ISNULL(@actualHours, '&nbsp;') + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none;">' + ISNULL(@actualEnd, '&nbsp;') + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none; text-align: center;">' + convert(nvarchar(10), @percentComplete) + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none;">' + @subStatus + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none; text-align: center;">' + convert(nvarchar(10), ISNULL(@subOpenDays, '&nbsp;')) + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none; text-align: center;">' + convert(nvarchar(10), ISNULL(@subAssignedDays, '&nbsp;')) + N'</td>';
						SET @tableHTML_temp = @tableHTML_temp + N'<td style="border: 1px solid gray; border-left: none; border-top: none; text-align: center;">' + convert(nvarchar(10), ISNULL(@reOpenedCount, '&nbsp;')) + N'</td>';

						SET @tableHTML_temp = @tableHTML_temp + N'</tr>';

						FETCH NEXT FROM workload_sub_cursor
						INTO @subTask
							, @businessRank
							, @subTechRank
							, @subPriority
							, @subTitle
							, @subAssigned
							, @subPrimaryDeveloper
							, @estimatedStart
							, @actualStart
							, @plannedHours
							, @actualHours
							, @actualEnd
							, @percentComplete
							, @subStatus
							, @subOpenDays
							, @subAssignedDays
							, @reOpenedCount
					END;
					CLOSE workload_sub_cursor;
					DEALLOCATE workload_sub_cursor;

					IF (ISNULL(@count_sub,0) > 0)
						BEGIN
							SET @tableHTML = @tableHTML + @tableHTML_temp + N'</tr>';
							SET @tableHTML = @tableHTML + N'</table></td></tr>';
							SET @border = 1;
						END;

					SET @count_sub = 0;

					FETCH NEXT FROM workload_cursor
					INTO @workitemID
						, @itemSystem
						, @status
						, @title
						, @busRank
						, @techRank
						, @workArea
						, @functionality
						, @production
						, @version
						, @priority
						, @assigned
						, @primaryDeveloper
						, @progress
						, @sort
						, @openDays
						, @assignedDays
				END;
				CLOSE workload_cursor;
				DEALLOCATE workload_cursor;
				
				SET @tableHTML = @tableHTML + N'</table></td></tr>';
				SET @border = 0;

				SET @cTotal += @totalItems;
				SET @cOpen += @openItems;
				SET @cOnHold += @onHoldItems;
				SET @cInfoRequested += @infoRequestedItems;
				SET @cNew += @newItems;
				SET @cInProgress += @inProgressItems;
				SET @cReOpened += @reOpenedItems;
				SET @cInfoProvided += @infoProvidedItems;
				SET @cUnReproducible += @unReproducibleItems;
				SET @cCheckedIn += @checkedInItems;
				SET @cDeployed += @deployedItems;
				SET @cClosed += @closedItems;
				SET @cTotalSub += @totalItemsSub;
				SET @cOpenSub += @openItemsSub;
				SET @cOnHoldSub += @onHoldItemsSub;
				SET @cInfoRequestedSub += @infoRequestedItemsSub;
				SET @cNewSub += @newItemsSub;
				SET @cInProgressSub += @inProgressItemsSub;
				SET @cReOpenedSub += @reOpenedItemsSub;
				SET @cInfoProvidedSub += @infoProvidedItemsSub;
				SET @cUnReproducibleSub += @unReproducibleItemsSub;
				SET @cCheckedInSub += @checkedInItemsSub;
				SET @cDeployedSub += @deployedItemsSub;
				SET @cClosedSub += @closedItemsSub;

			FETCH NEXT FROM hotlist_cursor
			INTO @systemSort
				, @systemID
				, @system
				, @totalItems
				, @openItems
				, @onHoldItems
				, @infoRequestedItems
				, @newItems
				, @inProgressItems
				, @reOpenedItems
				, @infoProvidedItems
				, @unReproducibleItems
				, @checkedInItems
				, @deployedItems
				, @closedItems
				, @totalItemsSub
				, @openItemsSub
				, @onHoldItemsSub
				, @infoRequestedItemsSub
				, @newItemsSub
				, @inProgressItemsSub
				, @reOpenedItemsSub
				, @infoProvidedItemsSub
				, @unReproducibleItemsSub
				, @checkedInItemsSub
				, @deployedItemsSub
				, @closedItemsSub
		END;
		CLOSE hotlist_cursor;
		DEALLOCATE hotlist_cursor;

		SET @tableHTML = @tableHTML + N'</table>';
		SET @tableHTML = REPLACE(@tableHTML, '# Tasks_temp2', '# Tasks<br>(' + convert(nvarchar(10), @cTotal) + ' / ' + convert(nvarchar(10), @cTotalSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'Open_temp2', 'Open<br>(' + convert(nvarchar(10), @cOpen) + ' / ' + convert(nvarchar(10), @cOpenSub) + ')');

		SET @tableHTML = REPLACE(@tableHTML, 'On Hold_temp1', 'On Hold<br>(' + convert(nvarchar(10), @cOnHold + @cInfoRequested) + ' / ' + convert(nvarchar(10), @cOnHoldSub + @cInfoRequestedSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'Open_temp1', 'Open<br>(' + convert(nvarchar(10), @cNew + @cInProgress + @cReOpened + @cInfoProvided + @cUnReproducible) + ' / ' + convert(nvarchar(10), @cNewSub + @cInProgressSub + @cReOpenedSub + @cInfoProvidedSub + @cUnReproducibleSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'Awaiting Closure_temp1', 'Awaiting Closure<br>(' + convert(nvarchar(10), @cCheckedIn + @cDeployed) + ' / ' + convert(nvarchar(10), @cCheckedInSub + @cDeployedSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'Closed_temp1', 'Closed<br>(' + convert(nvarchar(10), @cClosed) + ' / ' + convert(nvarchar(10), @cClosedSub) + ')');

		SET @tableHTML = REPLACE(@tableHTML, 'On Hold_temp2', 'On Hold<br>(' + convert(nvarchar(10), @cOnHold) + ' / ' + convert(nvarchar(10), @cOnHoldSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'Info Requested_temp2', 'Info Requested<br>(' + convert(nvarchar(10), @cInfoRequested) + ' / ' + convert(nvarchar(10), @cInfoRequestedSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'New_temp2', 'New<br>(' + convert(nvarchar(10), @cNew) + ' / ' + convert(nvarchar(10), @cNewSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'In Progress_temp2', 'In Progress<br>(' + convert(nvarchar(10), @cInProgress) + ' / ' + convert(nvarchar(10), @cInProgressSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'Re-Opened_temp2', 'Re-Opened<br>(' + convert(nvarchar(10), @cReOpened) + ' / ' + convert(nvarchar(10), @cReOpenedSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'Info Provided_temp2', 'Info Provided<br>(' + convert(nvarchar(10), @cInfoProvided) + ' / ' + convert(nvarchar(10), @cInfoProvidedSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'Un-Reproducible_temp2', 'Un-Reproducible<br>(' + convert(nvarchar(10), @cUnReproducible) + ' / ' + convert(nvarchar(10), @cUnReproducibleSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'Checked In_temp2', 'Checked In<br>(' + convert(nvarchar(10), @cCheckedIn) + ' / ' + convert(nvarchar(10), @cCheckedInSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'Deployed_temp2', 'Deployed<br>(' + convert(nvarchar(10), @cDeployed) + ' / ' + convert(nvarchar(10), @cDeployedSub) + ')');
		SET @tableHTML = REPLACE(@tableHTML, 'Closed_temp2', 'Closed<br>(' + convert(nvarchar(10), @cClosed) + ' / ' + convert(nvarchar(10), @cClosedSub) + ')');

--==========================================================================================================================
--==========================================================================================================================
--  MAIN Table above
--==========================================================================================================================
--==========================================================================================================================


--==========================================================================================================================
--  Combine everything

		SET @InviteHTML = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';
		SET @InviteHTML = @InviteHTML + N' <div>' + @message + N'</div>' + N'<br />';
		SET @InviteHTML = @InviteHTML + N'<a href="mailto:' + @EmailList + N'?Subject=Hotlist Meeting" target="_top">Setup Meeting</a><br /><br />';
		SET @InviteHTML = @InviteHTML + @tableHTML + N'</table><br /><br />';  -- @tableHTML includes Allocation table
		SET @tableHTML = @InviteHTML;
		
		SET @tableHTML = @tableHTML + @TableSummaryHTML + @DurationTable + @DurationAllocationTable + '<br /><div font-family: Arial; font-size: 12px;>WTS Generated Email - Infinite Technologies, Inc.</div>';  

--==========================================================================================================================

	--	IF (ISNULL(@count,0) > 0)
	--		BEGIN
	--			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Default'
	--				, @recipients = 'BadgleyS@infintech.com'  -- @activeRecipients 
	--				, @copy_recipients = '' -- 'FolsomWorkload@infintech.com'
	--				, @subject = 'TEST - WTS: Production Hotlist'
	--				, @body = @tableHTML
	--				, @body_format = 'HTML';
				
	--			EXEC LogEmail_Add @StatusId = 1
	--				, @Sender = 'FolsomWorkload@infintech.com'
	--				, @ToAddresses = 'BadgleyS@infintech.com' -- @activeRecipients
	--				, @CcAddresses = ''  --'FolsomWorkload@infintech.com'
	--				, @BccAddresses = ''
	--				, @Subject = 'TEST - WTS: Production Hotlist'
	--				, @Body = @tableHTML
	--				, @SentDate = @date
	--				, @Procedure_Used = 'Email_Hotlist'
	--				, @ErrorMessage = ''
	--				, @CreatedBy = 'SQL Server'
	--				, @newID = null;
	--END;

	IF (ISNULL(@count,0) > 0)
		BEGIN
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Default'
				, @recipients = @activeRecipients 
				, @copy_recipients = ''  -- 'FolsomWorkload@infintech.com'
				, @subject = 'WTS: Production Hotlist (On demand)'
				, @body = @tableHTML
				, @body_format = 'HTML';
				
			EXEC LogEmail_Add @StatusId = 1
				, @Sender = 'FolsomWorkload@infintech.com'
				, @ToAddresses = @activeRecipients
				, @CcAddresses = ''  -- 'FolsomWorkload@infintech.com'
				, @BccAddresses = ''
				, @Subject = 'WTS: Production Hotlist (On demand)'
				, @Body = @tableHTML
				, @SentDate = @date
				, @Procedure_Used = 'Email_Hotlist'
				, @ErrorMessage = ''
				, @CreatedBy = 'SQL Server'
				, @newID = null;
	END;
END;