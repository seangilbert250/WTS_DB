USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[EMailSRReport]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [EMailSRReport]
GO

-- Change history:
-- Mid November - Major overhaul

CREATE PROCEDURE [dbo].[EMailSRReport]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @SRNubers varchar(Max) = '';
	DECLARE @SRNubersSub varchar(Max) = ''; 
	DECLARE @SRNubersCombined varchar(Max) = ''; 

	DECLARE @TaskCount int; 
	DECLARE @SubTaskCount int; 
	DECLARE @TotalTaskCount int; 

	DECLARE @Summary nvarchar(max);

	DECLARE @tableHTMLResourceList nvarchar(max) = '';
	DECLARE @tableHTMLSummary nvarchar(max) = '';
	DECLARE @tableHTMLList nvarchar(max) = '';
	DECLARE @TablesCombined nvarchar(max) = '';
	DECLARE @TableDetails nvarchar(max) = '';

	DECLARE @PriorityCnt int = 0;
	DECLARE @Priority int = 0;
	DECLARE @PrioritySort int = 0;
	DECLARE @PriorityDesc nvarchar(max) = '';
	DECLARE @SRList nvarchar(max);
	DECLARE @SRListSub nvarchar(max);
	DECLARE @PriorityHeader nvarchar(max) = '';
	DECLARE @ResIDs nvarchar(max) = '';
	DECLARE @ResID int = 0;
	DECLARE @ResFirst nvarchar(max) = '';
	DECLARE @ResLast nvarchar(max) = '';
	DECLARE @ResName nvarchar(max) = '';

	DECLARE @Count1 nvarchar(50);
	DECLARE @Count2 nvarchar(50);
	DECLARE @Count3 nvarchar(50);
	DECLARE @Count4 nvarchar(50);
	DECLARE @Count5 nvarchar(50);
	DECLARE @Count6 nvarchar(50);
	DECLARE @Count7 nvarchar(50);
	DECLARE @Count8 nvarchar(50);

	DECLARE @System nvarchar(100);
	DECLARE @WorkItemID nvarchar(100);
	DECLARE @SRNumber nvarchar(100);
	DECLARE @Resource nvarchar(100);
	DECLARE @PrimBusResource nvarchar(100);
	DECLARE @Status nvarchar(100);
	DECLARE @PercentComp nvarchar(100);
	DECLARE @UpdatedDate nvarchar(100);
	DECLARE @TaskTitle nvarchar(100);
	DECLARE @SubTaskTitle nvarchar(100);

	DECLARE @tableHTML nvarchar(max);
	DECLARE @tableHTML2 nvarchar(max);
	DECLARE @SROverviewTableHTML nvarchar(max);
	DECLARE @SROverviewSubTableHTML nvarchar(max);
	DECLARE @tableHTML3 nvarchar(max);
	DECLARE @SRtableHTML nvarchar(max);
	DECLARE @IncludedInCounts nvarchar(max);

	DECLARE @EMailDistList nvarchar(max) = '';
	DECLARE @EMailAddr nvarchar(100) = '';

	--DECLARE @UnassignedCountsWHEREClause nvarchar(max) = ' AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NOT NULL AND ASSIGNEDRESOURCEID <> 0
	--		AND SR_Number IS NOT NULL AND SR_Number <> 0
	--		AND (ASSIGNEDRESOURCEID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)
	--		  OR PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)
	--		  OR SecondaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1))';

	--DECLARE @SQLStatement nvarchar(max);

	-- Now have IncludeInSRCounts in table

	-- 1-4-2017 - Removed check for existence of SR_Number/SRNumber in task/subtask also.

--==============================================================================================

	SET @TaskCount = (SELECT COUNT(*) FROM WORKITEM 
	  WHERE  STATUSID NOT IN (9, 10, 15, 70) 
	  AND (SR_Number IS NOT NULL AND SR_Number <> 0) 
      AND ASSIGNEDRESOURCEID != 69 
	  --AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
	  --AND PrimaryBusinessResourceID IN (SELECT DISTINCT PrimaryBusinessResourceID FROM WORKITEM WHERE SR_Number IS NOT NULL AND SR_Number <> 0)
	  AND PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1));

	SET @SubTaskCount = (SELECT COUNT(*) FROM WORKITEM_TASK 
	  WHERE  STATUSID NOT IN (9, 10, 15, 70) 
	  AND (SRNumber IS NOT NULL AND SRNumber <> 0)	  
      AND ASSIGNEDRESOURCEID != 69 
--	  AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
--	  AND PrimaryResourceID IN (SELECT DISTINCT PrimaryResourceID FROM WORKITEM WHERE SR_Number IS NOT NULL AND SR_Number <> 0)
	  AND PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1));

	SET @TotalTaskCount = @TaskCount + @SubTaskCount;

	SET  @Summary = 'OPEN SR''s as of ' + Convert(varchar, GETDATE(), 111) + ':  ' + Convert(varchar, @TotalTaskCount);

	SET @tableHTMLSummary = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';
	SET @tableHTMLSummary = @tableHTMLSummary + N'<table cellpadding="0" cellspacing="0">';
	SET @tableHTMLSummary = @tableHTMLSummary + N'<th style="border: 1px solid gray;" width="100">OPEN SR TOTAL</th>';
	SET @tableHTMLSummary = @tableHTMLSummary + N'<tr><td style="border: 1px solid gray; border-top: none; text-align: left;">&nbsp;' + @Summary + N'&nbsp;</td>';  --  border-right: none;
	SET @tableHTMLSummary = @tableHTMLSummary + N'</td></table>';

	SET @TablesCombined = @tableHTMLSummary;

------------------------  List of SR's  ---------------------------------

	SELECT @SRNubers = COALESCE(@SRNubers + ', ', '') + CONVERT(NVARCHAR(20), SR_Number) 
	FROM WORKITEM 
	WHERE SR_Number IS NOT NULL AND SR_Number <> 0 
--    AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMID)
	AND STATUSID NOT IN (9, 10, 15, 70)
    AND ASSIGNEDRESOURCEID != 69 
	AND PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)
	ORDER BY SR_Number;

	SELECT @SRNubersSub = COALESCE(@SRNubersSub + ', ', '') + CONVERT(NVARCHAR(20), SRNumber) 
	FROM WORKITEM_TASK 
	WHERE SRNumber IS NOT NULL AND SRNumber <> 0 
--    AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM.WORKITEMID)
	AND STATUSID NOT IN (9, 10, 15, 70) 
    AND ASSIGNEDRESOURCEID != 69 
	AND PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)
	ORDER BY SRNumber;

-- 1-4-2017 - Removed, seems redundant.
	--IF LEN(@SRNubers) > 2
	--BEGIN
	--	SET @SRNubers = SUBSTRING(@SRNubers, 2, LEN(@SRNubers));  -- Remove leading comma
	--END
	--SET @SRNubersCombined = @SRNubers + ', ' + @SRNubersSub;
	--IF LEN(@SRNubersCombined) > 2
	--BEGIN
	--	SET @SRNubersCombined = SUBSTRING(@SRNubersCombined, 0, LEN(@SRNubersCombined));  -- Remove last comma
	--END

	--SET @tableHTMLList = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';
	--SET @tableHTMLList = @tableHTMLList + N'<table cellpadding="0" cellspacing="0">';
	--SET @tableHTMLList = @tableHTMLList + N'<th style="border: 1px solid gray;" width="100">OPEN SR LIST</th>';
	--SET @tableHTMLList = @tableHTMLList + N'<tr><td style="border: 1px solid gray; border-top: none; text-align: left;">&nbsp;' + @SRNubersCombined + N'&nbsp;</td>';  --  border-right: none;
	--SET @tableHTMLList = @tableHTMLList + N'</td></table>';

	--SET @TablesCombined = @TablesCombined + '<br /><br />' + @tableHTMLList;

------------------------------ Outer Loop  ----------------------------------------------

	SET @TableDetails = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';
	SET @TableDetails = @TableDetails + N'<table cellpadding="0" cellspacing="0">';
	SET @TableDetails = @TableDetails + N'<th style="border: 1px solid gray;" width="100">BY PRIORITY</th>';

	WHILE @PriorityCnt < 4
	BEGIN
		SET @PriorityCnt = @PriorityCnt + 1

		IF (@PriorityCnt = 1) 
			BEGIN
				SET @Priority = 20;
				SET @PriorityDesc = 'CRITICAL';
			END
		ELSE IF (@PriorityCnt = 2) 
			BEGIN
				SET @Priority = 1;
				SET @PriorityDesc = 'HIGH PRIORITY';
			END
		ELSE IF (@PriorityCnt = 3) 
			BEGIN
				SET @Priority = 2;
				SET @PriorityDesc = 'MEDIUM PRIORITY';
			END
		ELSE IF (@PriorityCnt = 4) 
			BEGIN
				SET @Priority = 3;
				SET @PriorityDesc = 'LOW PRIORITY';
			END

		SET @TaskCount = (SELECT COUNT (*) FROM WORKITEM WI
			  WHERE  WI.STATUSID NOT IN (9, 10, 15, 70)
			  AND (WI.SR_Number IS NOT NULL AND WI.SR_Number <> 0) 
--			  AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WI.WORKITEMID = WORKITEM_TASK.WORKITEMID)
			  AND PRIORITYID = @Priority
			  AND ASSIGNEDRESOURCEID != 69 
			  AND PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1));

		SET @SubTaskCount = (SELECT COUNT (*) FROM WORKITEM_TASK WI
			  WHERE  WI.STATUSID NOT IN (9, 10, 15, 70) 
			  AND (WI.SRNumber IS NOT NULL AND WI.SRNumber <> 0)
--			  AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WI.WORKITEMID)
			  AND PRIORITYID = @Priority
			  AND ASSIGNEDRESOURCEID != 69 
			  AND PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1));

		SET @TotalTaskCount = @TaskCount + @SubTaskCount;
		SET @PriorityHeader = @PriorityDesc + '  (' + Convert(nvarchar, @TotalTaskCount) + ')';
		SET @TableDetails = @TableDetails + N'<tr><td style="border: 1px solid gray; border-top: none; text-align: left; font-weight:bold">&nbsp;' + @PriorityHeader + N'&nbsp;</td>';  --  border-right: none;


			
	------------------------------ Inner Loop  ----------------------------------------------

		SET @IncludedInCounts = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';

		DECLARE Resource_cursor CURSOR FOR 

		SELECT WTS_RESOURCEID, FIRST_NAME + ' ' + LAST_NAME AS 'Name' FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1 ORDER BY FIRST_NAME;

		OPEN Resource_cursor

		FETCH NEXT FROM Resource_cursor
		INTO @ResID,
			@ResName

		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @IncludedInCounts = @IncludedInCounts + N'<tr><td style="border: 1px solid gray; border-top: none; text-align: left;">' + @ResName + N',&nbsp;</td>';  --  border-right: none;

			-- Now we have: @Priority, @PriorityDesc, @ResID, @ResName

			SET @TaskCount = (SELECT COUNT(*) FROM WORKITEM
				  WHERE STATUSID NOT IN (9, 10, 15, 70) 
				  AND (SR_Number IS NOT NULL AND SR_Number <> 0) 
--				  AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMID)
				  AND PRIORITYID = @Priority
				  AND ASSIGNEDRESOURCEID != 69 
				  AND PrimaryBusinessResourceID = @ResID);

			SET @SubTaskCount = (SELECT COUNT(*) FROM WORKITEM_TASK
				  WHERE  STATUSID NOT IN (9, 10, 15, 70) 
				  AND (SRNumber IS NOT NULL AND SRNumber <> 0)
--				  AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
				  AND PRIORITYID = @Priority
				  AND ASSIGNEDRESOURCEID != 69 
				  AND PrimaryResourceID = @ResID);

			SET @TotalTaskCount = @TaskCount + @SubTaskCount;

			IF @TotalTaskCount > 0 
			BEGIN
				SET @SRNubersCombined = '';
				SET @SRNubers = '';
				SET @SRNubersSub = '';

				SELECT @SRNubers = COALESCE(@SRNubers + ', ', '') + CONVERT(NVARCHAR(20), SR_Number) 
				FROM WORKITEM 
				WHERE SR_Number IS NOT NULL AND SR_Number <> 0 
				AND STATUSID NOT IN (9, 10, 15, 70)
--    		    AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMID)
				AND PRIORITYID = @Priority
		        AND ASSIGNEDRESOURCEID != 69 
				AND PrimaryBusinessResourceID = @ResID
				ORDER BY SR_Number;

				SELECT @SRNubersSub = COALESCE(@SRNubersSub + ', ', '') + CONVERT(NVARCHAR(20), SRNumber) 
				FROM WORKITEM_TASK 
				WHERE SRNumber IS NOT NULL AND SRNumber <> 0 
--				AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
				AND STATUSID NOT IN (9, 10, 15, 70) 
				AND PRIORITYID = @Priority
		        AND ASSIGNEDRESOURCEID != 69 
				AND PrimaryResourceID = @ResID
				ORDER BY SRNumber;

				-- Remove outer commas:
				IF @SRNubers = '' 
				BEGIN
					SET @SRNubersCombined = @SRNubersSub;
				END
				ELSE
				BEGIN
					SET @SRNubersCombined = @SRNubers + ', ' + @SRNubersSub;
				END

				IF SUBSTRING(@SRNubersCombined, 1, 2) = ', '
				BEGIN
					SET @SRNubersCombined = SUBSTRING(@SRNubersCombined, 3, LEN(@SRNubersCombined) - 2);
				END

				IF SUBSTRING(@SRNubersCombined, LEN(@SRNubersCombined), 1) = ','  
				BEGIN
					SET @SRNubersCombined = SUBSTRING(@SRNubersCombined, 1, LEN(@SRNubersCombined) - 1);
				END
 
				SET @PriorityDesc =  @ResName + '  (' + Convert(nvarchar, @TotalTaskCount) + ')';

				SET @TableDetails = @TableDetails + N'<tr><td style="border: 1px solid gray; border-top: none; text-align: left;">&nbsp;' + @PriorityDesc + N'&nbsp;</td>';  --  border-right: none;
				SET @TableDetails = @TableDetails + N'<tr><td style="border: 1px solid gray; border-top: none; text-align: left;">&nbsp;&nbsp;&nbsp;&nbsp;' + @SRNubersCombined + N'&nbsp;</td>';  --  border-right: none;
			END;  --> @TotalTaskCount > 0 

			FETCH NEXT FROM Resource_cursor
			INTO @ResID, 
				@ResName
		END;  --> fETCH

		CLOSE Resource_cursor;
		DEALLOCATE Resource_cursor;

		SET @TableDetails = @TableDetails + N'<tr><td style="border: 1px solid gray; border-top: none; text-align: left;">&nbsp;&nbsp;</td>';  --  border-right: none;
		
		SET @IncludedInCounts = @IncludedInCounts + N'<tr><td style="border: 1px solid gray; border-top: none; text-align: left;">&nbsp;&nbsp;</td>';  --  border-right: none;

	END; -->>  @PriorityCnt < 4  -- END Inner, Priority loop

	SET @IncludedInCounts = @IncludedInCounts + N'</td></table><br /><br />';

	SET @TableDetails = @TableDetails + N'</td></table><br /><br />';
	SET @TablesCombined = @TablesCombined + '<br /><br />' + @TableDetails;

--=========== TASK Overview  =====================================================================

	SET @SROverviewTableHTML = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';

	SELECT @Count1 = COUNT (*) FROM WORKITEM WHERE PRIORITYID = 20 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NOT NULL AND ASSIGNEDRESOURCEID <> 0
		AND SR_Number IS NOT NULL AND SR_Number <> 0
--        AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
		AND PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)

	SELECT @Count2 = COUNT (*) FROM WORKITEM WHERE PRIORITYID = 20 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NULL OR ASSIGNEDRESOURCEID = 0
		AND SR_Number IS NOT NULL AND SR_Number <> 0
--        AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
		AND PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)

	SELECT @Count3 = COUNT (*) FROM WORKITEM WHERE PRIORITYID = 1 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NOT NULL AND ASSIGNEDRESOURCEID <> 0
		AND SR_Number IS NOT NULL AND SR_Number <> 0
--        AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
		AND PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)

	SELECT @Count4 = COUNT (*) FROM WORKITEM WHERE PRIORITYID = 1 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NULL OR ASSIGNEDRESOURCEID = 0
		AND SR_Number IS NOT NULL AND SR_Number <> 0
--        AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
		AND PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)

	SELECT @Count5 = COUNT (*) FROM WORKITEM WHERE PRIORITYID = 2 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NOT NULL AND ASSIGNEDRESOURCEID <> 0
		AND SR_Number IS NOT NULL AND SR_Number <> 0
--        AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
		AND PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)

	SELECT @Count6 = COUNT (*) FROM WORKITEM WHERE PRIORITYID = 2 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NULL OR ASSIGNEDRESOURCEID = 0
		AND SR_Number IS NOT NULL AND SR_Number <> 0
--        AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
		AND PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)

	SELECT @Count7 = COUNT (*) FROM WORKITEM WHERE PRIORITYID = 3 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NOT NULL AND ASSIGNEDRESOURCEID <> 0
		AND SR_Number IS NOT NULL AND SR_Number <> 0
--        AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
		AND PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)

	SELECT @Count8 = COUNT (*) FROM WORKITEM WHERE PRIORITYID = 3 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NULL OR ASSIGNEDRESOURCEID = 0
		AND SR_Number IS NOT NULL AND SR_Number <> 0
--        AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMid)
		AND PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)

	SET @SROverviewTableHTML = @SROverviewTableHTML + N'<tr style="border-bottom: 1px solid gray;"><td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center; overflow: visible">&nbsp;' + @Count1 + N'&nbsp;</td>';
	SET @SROverviewTableHTML = @SROverviewTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count2 + N'</td>';
	SET @SROverviewTableHTML = @SROverviewTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count3 + N'</td>';
	SET @SROverviewTableHTML = @SROverviewTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count4 + N'</td>';
	SET @SROverviewTableHTML = @SROverviewTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count5 + N'</td>';
	SET @SROverviewTableHTML = @SROverviewTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count6 + N'</td>';
	SET @SROverviewTableHTML = @SROverviewTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count7 + N'</td>';
	SET @SROverviewTableHTML = @SROverviewTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-bottom: 1px solid gray; text-align: center;">' + @Count8 + N'</td></tr>';

	SET @tableHTML2 = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';
	SET @tableHTML2 = @tableHTML2 + N'<table cellpadding="0" cellspacing="0">';
	SET @tableHTML2 = @tableHTML2 + N'<th style="border: 1px solid gray;" width="100">TASK<br />Asssigned Critical Priority</th>';
	SET @tableHTML2 = @tableHTML2 + N'<th style="border: 1px solid gray;" width="100">TASK<br />Unassigned Critical Priority</th>';
	SET @tableHTML2 = @tableHTML2 + N'<th style="border: 1px solid gray;" width="100">TASK<br />Asssigned High Priority</th>';
	SET @tableHTML2 = @tableHTML2 + N'<th style="border: 1px solid gray;" width="100">TASK<br />Unassigned High Priority</th>';
	SET @tableHTML2 = @tableHTML2 + N'<th style="border: 1px solid gray;" width="100">TASK<br />Asssigned Medium Priority</th>';
	SET @tableHTML2 = @tableHTML2 + N'<th style="border: 1px solid gray;" width="100">TASK<br />Unasssigned Medium Priority</th>';
	SET @tableHTML2 = @tableHTML2 + N'<th style="border: 1px solid gray;" width="100">TASK<br />Asssigned Low Priority</th>';
	SET @tableHTML2 = @tableHTML2 + N'<th style="border: 1px solid gray;" width="100">TASK<br />Unasssigned Low Priority</th>';
	SET @tableHTML2 = @tableHTML2 + @SROverviewTableHTML + N'</table><br /><br />';

--=========== SUB TASK Overview  =====================================================================

	SET @SROverviewSubTableHTML = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';

	SELECT @Count1 = COUNT (*) FROM WORKITEM_TASK WHERE PRIORITYID = 20 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NOT NULL AND ASSIGNEDRESOURCEID <> 0
		AND SRNumber IS NOT NULL AND SRNumber <> 0 
--		AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMID)
		AND PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1);

	SELECT @Count2 = COUNT (*) FROM WORKITEM_TASK WHERE PRIORITYID = 20 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NULL OR ASSIGNEDRESOURCEID = 0
		AND SRNumber IS NOT NULL AND SRNumber <> 0
--		AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMID)
		AND PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1);

	SELECT @Count3 = COUNT (*) FROM WORKITEM_TASK WHERE PRIORITYID = 1 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NOT NULL AND ASSIGNEDRESOURCEID <> 0
		AND SRNumber IS NOT NULL AND SRNumber <> 0
--		AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMID)
		AND PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1);

	SELECT @Count4 = COUNT (*) FROM WORKITEM_TASK WHERE PRIORITYID = 1 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NULL OR ASSIGNEDRESOURCEID = 0
		AND SRNumber IS NOT NULL AND SRNumber <> 0
--		AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMID)
		AND PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1);

	SELECT @Count5 = COUNT (*) FROM WORKITEM_TASK WHERE PRIORITYID = 2 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NOT NULL AND ASSIGNEDRESOURCEID <> 0
		AND SRNumber IS NOT NULL AND SRNumber <> 0
--		AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMID)
		AND PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1);

	SELECT @Count6 = COUNT (*) FROM WORKITEM_TASK WHERE PRIORITYID = 2 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NULL OR ASSIGNEDRESOURCEID = 0
		AND SRNumber IS NOT NULL AND SRNumber <> 0
--		AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMID)
		AND PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1);

	SELECT @Count7 = COUNT (*) FROM WORKITEM_TASK WHERE PRIORITYID = 3 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NOT NULL AND ASSIGNEDRESOURCEID <> 0
		AND SRNumber IS NOT NULL AND SRNumber <> 0
--		AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMID)
		AND PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1);

	SELECT @Count8 = COUNT (*) FROM WORKITEM_TASK WHERE PRIORITYID = 3 AND STATUSID NOT IN (9, 10, 15, 70) AND ASSIGNEDRESOURCEID != 69 AND ASSIGNEDRESOURCEID IS NULL OR ASSIGNEDRESOURCEID = 0
		AND SRNumber IS NOT NULL AND SRNumber <> 0
--		AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WORKITEM_TASK.WORKITEMID)
		AND PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1);

	SET @SROverviewSubTableHTML = @SROverviewSubTableHTML + N'<tr style="border-bottom: 1px solid gray;"><td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center; overflow: visible">&nbsp;' + @Count1 + N'&nbsp;</td>';
	SET @SROverviewSubTableHTML = @SROverviewSubTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count2 + N'</td>';
	SET @SROverviewSubTableHTML = @SROverviewSubTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count3 + N'</td>';
	SET @SROverviewSubTableHTML = @SROverviewSubTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count4 + N'</td>';
	SET @SROverviewSubTableHTML = @SROverviewSubTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count5 + N'</td>';
	SET @SROverviewSubTableHTML = @SROverviewSubTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count6 + N'</td>';
	SET @SROverviewSubTableHTML = @SROverviewSubTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @Count7 + N'</td>';
	SET @SROverviewSubTableHTML = @SROverviewSubTableHTML + N'<td style="border: 1px solid gray; border-top: none; border-bottom: 1px solid gray; text-align: center;">' + @Count8 + N'</td></tr>';

	SET @tableHTML3 = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';
	SET @tableHTML3 = @tableHTML3 + N'<table cellpadding="0" cellspacing="0">';
	SET @tableHTML3 = @tableHTML3 + N'<th style="border: 1px solid gray;" width="100">SUBTASK Asssigned Critical Priority</th>';
	SET @tableHTML3 = @tableHTML3 + N'<th style="border: 1px solid gray;" width="100">SUBTASK Unasssigned Critical Priority</th>';
	SET @tableHTML3 = @tableHTML3 + N'<th style="border: 1px solid gray;" width="100">SUBTASK Asssigned High Priority</th>';
	SET @tableHTML3 = @tableHTML3 + N'<th style="border: 1px solid gray;" width="100">SUBTASK Unassigned High Priority</th>';
	SET @tableHTML3 = @tableHTML3 + N'<th style="border: 1px solid gray;" width="100">SUBTASK Asssigned Medium Priority</th>';
	SET @tableHTML3 = @tableHTML3 + N'<th style="border: 1px solid gray;" width="100">SUBTASK Unasssigned Medium Priority</th>';
	SET @tableHTML3 = @tableHTML3 + N'<th style="border: 1px solid gray;" width="100">SUBTASK Asssigned Low Priority</th>';
	SET @tableHTML3 = @tableHTML3 + N'<th style="border: 1px solid gray;" width="100">SUBTASK Unasssigned Low Priority</th>';

	SET @tableHTML3 = @tableHTML3 + @SROverviewSubTableHTML + N'</table><br /><br />';

--===========  Details  ======================================================================

	SET @SRtableHTML = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';

	DECLARE SR_Cursor CURSOR FOR 

	SELECT 
		SYS.WTS_SYSTEM, P.PRIORITY, 
		CAST(WI.WORKITEMID AS nvarchar(50)) AS 'Task ID',
		 WI.SR_Number AS 'SR Number', 
		RES.FIRST_NAME + ' ' + RES.LAST_NAME AS 'Assigned To', 
		IsNull((SELECT FIRST_NAME + ' ' + LAST_NAME FROM WTS_RESOURCE WHERE WTS_RESOURCEID = WI.PrimaryBusinessResourceID), '') as 'Primary Bus. Res.', 
		ST.STATUS AS Status, 
		WI.COMPLETIONPERCENT AS '% Complete', 
		CAST(WI.UPDATEDDATE AS date) AS 'Last Updated', 
		WI.TITLE AS 'Task Title',
		'' AS 'Subtask Title' ,
		P.PRIORITYID ,
		P.SORT_ORDER 
	FROM WORKITEM WI
		JOIN WTS_RESOURCE RES ON WI.ASSIGNEDRESOURCEID = RES.WTS_RESOURCEID 
		JOIN STATUS ST ON WI.STATUSID = ST.STATUSID 
		JOIN PRIORITY P ON WI.PRIORITYID = P.PRIORITYID
		JOIN WTS_SYSTEM SYS ON SYS.WTS_SYSTEMID = WI.WTS_SYSTEMID
	WHERE SR_Number IS NOT NULL AND SR_Number <> 0
--        AND SR_Number NOT IN (SELECT SRNumber FROM WORKITEM_TASK WHERE WI.WORKITEMID = WORKITEM_TASK.WORKITEMid)
		AND WI.STATUSID NOT IN (9, 10, 15, 70)
		AND WI.ASSIGNEDRESOURCEID != 69
	    AND WI.PrimaryBusinessResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)

	UNION

	SELECT 
		SYS.WTS_SYSTEM
		, P.PRIORITY, 
		(SELECT CASE WIT.TASK_NUMBER
			WHEN NULL THEN CAST(WI.WORKITEMID AS nvarchar(50))
			ELSE CAST(WI.WORKITEMID AS nvarchar(50)) + ' - ' + CAST(WIT.TASK_NUMBER AS nvarchar(50))
		END) AS 'Task',
		 WIT.SRNumber AS 'SR Number',   
		RES.FIRST_NAME + ' ' + RES.LAST_NAME AS 'Assigned To', 
		IsNull((SELECT FIRST_NAME + ' ' + LAST_NAME FROM WTS_RESOURCE WHERE WTS_RESOURCEID = WI.PrimaryBusinessResourceID), '') as 'Primary Bus. Res.', 
		ST.STATUS AS Status, 
		WI.COMPLETIONPERCENT AS '% Complete', 
		CAST(WI.UPDATEDDATE AS date) AS 'Last Updated', 
		WI.TITLE AS 'Task Title',
		IsNull(WIT.TITLE, '') AS 'Subtask Title',
		P.PRIORITYID, 
		P.SORT_ORDER 
	FROM WORKITEM_TASK WIT
		JOIN WORKITEM WI ON WI.WORKITEMID = WIT.WORKITEMID
		JOIN WTS_RESOURCE RES ON WI.ASSIGNEDRESOURCEID = RES.WTS_RESOURCEID 
		JOIN STATUS ST ON WI.STATUSID = ST.STATUSID 
		JOIN PRIORITY P ON WIT.PRIORITYID = P.PRIORITYID
		JOIN WTS_SYSTEM SYS ON SYS.WTS_SYSTEMID = WI.WTS_SYSTEMID
	WHERE SRNumber IS NOT NULL AND SRNumber <> 0
--		AND SRNumber NOT IN (SELECT SR_Number FROM WORKITEM WHERE WORKITEM.WORKITEMID = WIT.WORKITEMID)
		AND WIT.STATUSID NOT IN (9, 10, 15, 70) 
		AND WIT.ASSIGNEDRESOURCEID != 69
	    AND WIT.PrimaryResourceID IN (SELECT WTS_RESOURCEID FROM WTS_RESOURCE WHERE IncludeInSRCounts = 1)
	ORDER BY P.SORT_ORDER, 'SR Number' DESC;

	OPEN SR_Cursor

	FETCH NEXT FROM SR_Cursor
	INTO @System
	,@PriorityDesc
	,@WorkItemID
	,@SRNumber
	,@Resource
	,@PrimBusResource
	,@Status
	,@PercentComp
	,@UpdatedDate
	,@TaskTitle
	,@SubTaskTitle
	,@Priority
	,@PrioritySort

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @SRtableHTML = @SRtableHTML + N'<tr><td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">&nbsp;' + @System + N'&nbsp;</td>';
		SET @SRtableHTML = @SRtableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">' + @PriorityDesc + N'</td>';
		SET @SRtableHTML = @SRtableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">' + @WorkItemID + N'</td>';
		SET @SRtableHTML = @SRtableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">' + @SRNumber + N'</td>';
		SET @SRtableHTML = @SRtableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">' + @Resource + N'</td>';
		SET @SRtableHTML = @SRtableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">' + @PrimBusResource + N'</td>';
		SET @SRtableHTML = @SRtableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">' + @Status + N'</td>';
		SET @SRtableHTML = @SRtableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: center;">' + @PercentComp + N'</td>';
		SET @SRtableHTML = @SRtableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">' + @UpdatedDate + N'</td>';
		SET @SRtableHTML = @SRtableHTML + N'<td style="border: 1px solid gray; border-top: none; border-right: none; text-align: left;">' + @TaskTitle + N'</td>';
			
		SET @SRtableHTML = @SRtableHTML + N'<td style="border: 1px solid gray; border-top: none; text-align: left;">' + @SubTaskTitle + N'</td></tr>';

		FETCH NEXT FROM SR_Cursor
	INTO @System
	,@PriorityDesc
	,@WorkItemID
	,@SRNumber
	,@Resource
	,@PrimBusResource
	,@Status
	,@PercentComp
	,@UpdatedDate
	,@TaskTitle
	,@SubTaskTitle
	,@Priority
	,@PrioritySort
	
	END;

	CLOSE SR_Cursor
	DEALLOCATE SR_Cursor

	SET @tableHTML = N'<style type="text/css">table {font-family: Arial; font-size: 12px;} th {background-color: #d7daf2;} td {padding: 3px;}</style> ';
	SET @tableHTML = @tableHTML + N'<table cellpadding="0" cellspacing="0">';
	SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="20">System</th>';
	SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="20">Priority</th>';
	SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="90">Work Item ID</th>';
	SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="40">SR Number</th>';
	SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="80">Assigned</th>';
	SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="100">Prim. Bus. Res.</th>';
	SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="70">Status</th>';
	SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="30">% Comp</th>';
	SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="60">Last Updated</th>';
	SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="100">Task Title</th>';
	SET @tableHTML = @tableHTML + N'<th style="border: 1px solid gray;" width="120">Sub Task Title</th>';

	SET @tableHTML = @tableHTML + @SRtableHTML + N'</table><br /><div font-family: Arial; font-size: 12px;>WTS Generated Email - Infinite Technologies, Inc.</div>';

	SET @tableHTML = @tableHTML + N'<br /><div font-family: Arial; font-size: 12px;>Criteria 1) Status not Deployed, Closed, Complete or Approved/Closed, </div>';
	SET @tableHTML = @tableHTML + N'<div font-family: Arial; font-size: 12px;>Criteria 2) Not assigned to IT.Backlog, </div>';
	SET @tableHTML = @tableHTML + N'<div font-family: Arial; font-size: 12px;>Criteria 3) Counts only for Resources set to be included in counts (Administration > SR Configuration): </div><br />';
	
--=========  Combine Tables  ===========================================================================================================

SET @TablesCombined = @TablesCombined + '<br /><br />' + @tableHTML2 + @tableHTML3 + @tableHTML + @IncludedInCounts; 

--=========  EMail Distribution list  ==================================================================================================

	DECLARE EMail_cursor CURSOR FOR 

		SELECT EMAIL FROM WTS_RESOURCE WHERE ReceiveSREMail = 1;

		OPEN EMail_cursor

		FETCH NEXT FROM EMail_cursor
		INTO @EMailAddr

		WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @EMailDistList = @EMailDistList + @EMailAddr + ';'

			FETCH NEXT FROM EMail_cursor
			INTO @EMailAddr 
		END; 

	CLOSE EMail_cursor;
	DEALLOCATE EMail_cursor;

--=========  Send Email  ===============================================================================================================

--==============================================================  Test  ============================================================

	--EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Default'
	--	, @recipients = 'BadgleyS@infintech.com'  -- @EMailDistList 
	--	, @copy_recipients = '' -- 'FolsomWorkload@infintech.com'
	--	, @subject = 'TEST - SR Report'
	--	, @body = @TablesCombined
	--	, @body_format = 'HTML';
				
	--EXEC LogEmail_Add @StatusId = 1
	--	, @Sender = 'FolsomWorkload@infintech.com'
	--	, @ToAddresses = 'BadgleyS@infintech.com' -- @activeRecipients
	--	, @CcAddresses = ''  --'FolsomWorkload@infintech.com'
	--	, @BccAddresses = ''
	--	, @Subject = 'TEST - SR Report'
	--	, @Body = @TablesCombined
	--	, @SentDate = @date
	--	, @Procedure_Used = 'EMailSRReport'
	--	, @ErrorMessage = ''
	--	, @CreatedBy = 'SQL Server'
	--	, @newID = null;

	--=========================================================  Production  ===========================================================

	EXEC msdb.dbo.sp_send_dbmail @profile_name = 'Default'
		, @recipients = @EMailDistList
		, @copy_recipients = ''
		, @subject = 'Open SR Summary'
		, @body = @TablesCombined 
		, @body_format = 'HTML';

	EXEC LogEmail_Add @StatusId = 1
		, @Sender = 'FolsomWorkload@infintech.com'
		, @ToAddresses = @EMailDistList
		, @CcAddresses = ''
		, @BccAddresses = ''
		, @Subject = 'Open SR Summary'
		, @Body = @TablesCombined 
		, @SentDate = @date
		, @Procedure_Used = 'EMailSRReport'
		, @ErrorMessage = ''
		, @CreatedBy = 'SQL Server'
		, @newID = null;

END
