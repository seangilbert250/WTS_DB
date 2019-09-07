USE WTS
GO

:On Error Exit
SET XACT_ABORT ON
GO

/*
="SELECT " & A2 & " AS WORKITEMID,
'" & B2 & "' AS TITLE,
'" & C2 & "' AS AssignedTo,
" & D2 & " AS CompletionPercent,
'" & E2 & "' AS Status,
" & F2 & " AS Sort_Order UNION ALL "
*/

CREATE TABLE #TaskList(
	WORKITEMID INT
	, TITLE nvarchar(500)
	, AssignedTo nvarchar(50)
	, CompletionPercent int
	, Status nvarchar(25)
	, Sort_Order int
);
INSERT INTO #TaskList(WORKITEMID
	, TITLE
	, AssignedTo
	, CompletionPercent
	, Status
	, Sort_Order)
SELECT WORKITEMID, TITLE, AssignedTo, CompletionPercent, [Status], Sort_Order 
FROM (
	SELECT 11451 AS WORKITEMID,
	'Sort Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'Reorder Column Icon (Removed)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'Excel Icon  ' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'Refresh' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'Year Dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'Resource Types Combo Box' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'Parent Source Checkboxes' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'Amount Only Chekcbox' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'quick Filter Dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'Review/Edit PCN Task Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'Cancel Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'Save Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11451 AS WORKITEMID,
	'Related Items Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	13 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Left Align Resource Type Labels in child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'There should be 0s under the USP/EISP, QTY RQMT and RQMT columns for the Resource Types in the child grid. Merge the resource type label with these cells' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'If MCO, Success or Failure are selected from the Resource Type dropdown, then the only editable fields are QTY RQMT and RQMT/RT RQMT ' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Add EOY OBS to parent grid; see design slide' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Rename Funds Holder to CMD(OAC)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Remove the time stamp from the Funding Updated Date colum. (This will be removed when Taylor changes to a link)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Compress columns in Child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Move WCN column to the left of PCN/Task' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Incorporate new Resource Child Grid layout per Erin. See Screenshot, New Resource Child Grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Add Other option to Resource Type dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Incorporate new parent grid. see screenshot' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Default sort on child grid to: WCN, PEC and then Resource Type(RQMT Gross should be first, then PEACE/Peace, PEACE/Topline, SUPP/OCO, SUPP/TWCF)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Move Approved USP to the right of RESOURCE TYPE in WCN Grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	13 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Rename UnOblig to UnObl in WCN Grid under Resource Type section' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	14 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Added RQMT and Funded to Peace and Supp section in WCN grid OBE' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	15 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Add OOC Status column in the WCN grid when the data call supports OOC' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	16 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Add OOC Status column in parent grid when the data call supports OOC' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	17 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Add Attachment indicator to WCN Level grid for WCNs with attachments' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	18 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Add indicator when saving if a RQMT change causes an OOC.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	19 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Change color of RQMT Gross highlight; Per Erin: Current color is too dark.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	20 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Add indicator that dollar amounts are in 000s k' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	21 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'WCN grid isnt filtering if PCN/Task is in the parent level' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	22 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Add UPDATED DATE section and add RQMT UPDATED DATE and FUNDING UPDATED DATE to parent grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	23 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Make sure dummy data is calculation correcting in the parent and child grids.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	24 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Make sure all text is not wrapped' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	25 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Add UPDATED DATE section and add RQMT UPDATED DATE and FUNDING UPDATED DATE to child grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	26 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Input boxes...remove the border around it' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	27 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'For the Gross column compulation, default to total all resource types for the WCNs regardless of the resource type(s) filtered through the resource type combo box.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	28 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Rename EOY OBS to EOY' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	29 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Rename UnObl to Uncommitted for current and future years and UnObligated for historical years.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	30 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Remove QTY RQMT and RQMT from GROSS section on parent grid; Add QTY RQMT and RQMT under its new section called, RQMT' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	31 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Rename RQMT GROSS to REQUIREMENT under the Resource Type Column in the child grid for the GROSS gray rows' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	32 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Rename QTY and Amount TY in the PEACE and SUPP Section in the child grid to....QTY FUNDED and FUNDED' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	33 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Rename UnCommitted to UnProjected (UnProjected = EOY - Resource Type Funding)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	34 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Remove QTY RQMT and RQMT from GROSS section on child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	35 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Move UnProjected to the left of EOY in the GROSS section on the child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	36 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'If Amount TY = 0, then hide Resource Type. Only show Resource Types where Amount TY > 0.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	37 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Add Add Resource Type link to add Resource Types to desired WCNs so users can add funding.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	38 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Move USPs into one column in child grid; seperate them by a /; rename column to Apprd/Adj USP' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	39 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'If a WCN doesnt have a USP leave the Apprd/Adj USP column blank' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	40 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Default PEACE/Peace, PEACE/Topline and SUPP/OCO resource types in child grid. All other resource types will display on the grid in any amounts are greater than 0' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	41 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Move COORDINATION column before RQMT for the parent grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	42 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Rename Approved/ADJ USP to APRVD/ADJ USP' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	43 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Hyperlink the APRVD/ADJ USP column in child grid. Hyperlink will bring up textbox giving definitions for Approved and Adjusted USP' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	44 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Adopt new Child grid layout; See attached screenshot New RFM Child grid layout' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	45 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Grid and Resource Type Combo Box >> Rename Resource Types       ' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	46 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Switch QTY and Amount around; QTY Needs to come first.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	47 AS Sort_Order UNION ALL 
	SELECT 11452 AS WORKITEMID,
	'Total QTY and Amount TY in Total row under Funded section' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	48 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Parent Grid Layout' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Child Grid Layout' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Add Resource Type link (OBE, see 19)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Remove Gross from the column field names under Gross section' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Default check Peace, Peace Topline, Supp OCO, Supp TWCF ' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'If a Resource Type isnt checked in the Resource Type dropdown, remove the resource type row from the child grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Only display Gross, Peace and Supp on parent grid if the respective checkbox is checked in the parameters window.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Highlight Gross row in blue; see design slide' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'QTY Funded and Funded should be editable for Peace/Base, Peace/Topline, Supp/OCO and Supp/TWCF in child grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'QTY RQMT and RQMT/RT RQMT should be editable in Gross row in child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Left Align Resource Type Labels in child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'There should be 0s under the USP/EISP, QTY RQMT and RQMT columns for the Resource Types in the child grid. Merge the resource type label with these cells.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'If MCO, Success or Failure are selected from the Resource Type dropdown, then the only editable fields are QTY RQMT and RQMT/RT RQMT ' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	13 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Remove EOY OBS from parent grid; see design slide' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	14 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Rename Funds Holder to CMD(OAC)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	15 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Remove the time stamp from the Funding Updated Date colum. (This will be removed when Taylor changes to a link)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	16 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Compress columns in Child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	17 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Move WCN column to the left of PCN/Task' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	18 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Incorporate new Resource Child Grid layout per Erin. See Screenshot, New Resource Child Grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	19 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Add Other option to Resource Type dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	20 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Incorporate new parent grid layout; see screenshot' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	21 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Default sort on child grid to WCN, PEC and then Resource Type(RQMT Gross should be first, then PEACE/Peace, PEACE/Topline, SUPP?OCO, SUPP/TWCF)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	22 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Move Approved USP to the right of RESOURCE TYPE in WCN Grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	23 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Added RQMT and Funded to Peace and Supp section in WCN grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	24 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Add Attachment indicator to WCN Level grid for WCNs with attachments' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	25 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Add indicator when saving if a RQMT change causes an OOC.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	26 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Change color of RQMT Gross highlight; Per Erin: Current color is too dark.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	27 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Add indicator that dollar amounts are in 000s k.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	28 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'WCN grid isnt filtering if PCN/Task is in the parent level' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	29 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Add UPDATED DATE section and add RQMT UPDATED DATE and FUNDING UPDATED DATE to parent grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	30 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Make sure dummy data is calculating correcting in the parent and child grids' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	31 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Make sure all text is not wrapped' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	32 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Add UPDATED DATE section and add RQMT UPDATED DATE and FUNDING UPDATED DATE to child grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	33 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Input boxes...remove the border around it' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	34 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'For the Gross column compulation, default to total all resource types for the WCNs regardless of the resource type(s) filtered through the resource type combo box' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	35 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Remove QTY RQMT and RQMT from GROSS section on parent grid; Add QTY RQMT and RQMT under its new section called, RQMT' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	36 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Rename RQMT GROSS to REQUIREMENT under the Resource Type Column in the child grid for the GROSS gray rows' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	37 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Rename QTY and Amount TY in the PEACE and SUPP Section in the child grid to....QTY FUNDED and FUNDED' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	38 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Remove QTY RQMT and RQMT from GROSS section on child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	39 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'If Amount TY = 0, then hide Resource Type. Only show Resource Types where Amount TY > 0.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	40 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Add Add Resource Type link to add Resource Types to desired WCNs so users can add funding' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	41 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Move USPs into one column in child grid; seperate them by a /; rename column to Apprd/Adj USP' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	42 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'If a WCN doesnt have a USP leave the Apprd/Adj USP column blank' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	43 AS Sort_Order UNION ALL 
	SELECT 11474 AS WORKITEMID,
	'Default PEACE/Peace, PEACE/Topline and SUPP/OCO resource types in child grid. All other resource types will display on the grid in any amounts are greater than 0' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	44 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Sort Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Reorder Column Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Excel Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Refresh' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Year Dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Resource Types Combo Box' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Parent Source Checkboxes' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Amount Only Chekcbox' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Quick Filter Dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Review/Edit PCN Task Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Cancel Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Save Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11459 AS WORKITEMID,
	'Related Items Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	13 AS Sort_Order UNION ALL 
	SELECT 11444 AS WORKITEMID,
	'Update Parameters tab based on new design ***See screenshot below***' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11444 AS WORKITEMID,
	'WCN Details Tab >> Default uncheck all. No Gross, Peace or Supp in the child' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11444 AS WORKITEMID,
	'Move CRIS File, CRIS RPT Date, Thru QTR dropdown to advanced parameters page above the Filter Resource Type list box OBE' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11444 AS WORKITEMID,
	'Move Add Row Total For checkboxes from parameters to advanced parameters tab. Place it in the Susbtotal(Parent Grid) tab above the Select subtotal Fields list box' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11444 AS WORKITEMID,
	'Load Custom View label -> Rename to Grid Layout' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11444 AS WORKITEMID,
	'Subtotal Field List Box -> Add Risk Category' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11444 AS WORKITEMID,
	'Move CRIS File, CRIS RPT Date and Thru QTR to Parameters tab.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11444 AS WORKITEMID,
	'WCN Details >> Add Checkboxes for what the user wants to file maintain(RQMT, Funding, Obligations);Default check all (See RFM Parameters)' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11444 AS WORKITEMID,
	'Under the Select Subtotal Fields list box >> Rename /OACTarget OAC to CMD(OAC)' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11444 AS WORKITEMID,
	'Advanced Parameters >> Rename Resource Types' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11444 AS WORKITEMID,
	'Add to WCN Details tab a checkbox when user can decide to show/hide the APRVD/ADJ USP column in the child grid; default unchecked. If checked the column is shown.' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Sort Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Reorder Column Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Excel Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Refresh' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Parent Source Checkboxes' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Amount Only Chekcbox' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Quick Filter Dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Review/Edit PCN Task Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Thru QTR Dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Save Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Related Items Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Report Wizard Link' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'CRIS File Dropdown' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	13 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Resource Types Combo Box' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	14 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Crosswalk Columns Combo Box' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	15 AS Sort_Order UNION ALL 
	SELECT 11446 AS WORKITEMID,
	'Generate Default Report' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	16 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Parent Grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Child Grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'CRIS Details Link' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Add Resource Type Link (OBE)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Default check Peace, Peace Topline, Supp OCO  Resource Types' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Create new Resource Type Grid. See New Resource Child Grid Per Erin Screenshot' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'REQUIREMENT row in child grid needs to be grayed(See RFM Grid)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Combined USP columns into one(See RFM Grid)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Remove RQMT from the Gross section in the parent and have the RQMT column by itself before the Gross section on the parent grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Remove RQMT section in child grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Obligation columns in child grid in the REQUIREMENT row should not be editable.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Add Add Resource Type button.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Peace, Topline and OCO resource types need to default show for all WCNs in the child grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	13 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Rename the Obligations section in the Child grid to COMMITS/OBLIGATION' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	14 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Widen the Width of the Obligation months' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	15 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Change the obligation qtr label to mirror the parent labels. Both should say QTR# Obs or QTR# Proj Commits' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	16 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Add the total of the Obs QTRs under the QTR OBS# label' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	17 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Dont show decimals unless the user has typed in a decimal value' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	18 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Fix column alignment' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	19 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'For the Obligation qtr labels, the labels need to say QTR# OBS if the QTR is historical, if the QTR is current or future the label needs to say QTR# Proj Commits in the child grid and parent grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	20 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Rename Funds Holder to CMD(OAC)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	21 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Update Child grid layout using the attached screenshot, New Obs Cross Child Layout' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	22 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Grid and Resource Combo Box >> Rename Resource Types' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	23 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Add Excess formula to excess column in child grid.' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	24 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Center Align the CRIS Details Link' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	25 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Rename APPRD/ADJ USP to APRVD/ADJ USP' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	26 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Add Blue Quetion mark for definitions (See Obligation Grid)' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	27 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Add WCN Count to + column' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	28 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Rename UnObl RQMT to UnProjected on Parent grid and add formula in blue question mark(See Obligation grid)' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	29 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Add coloring to + column' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	30 AS Sort_Order UNION ALL 
	SELECT 11447 AS WORKITEMID,
	'Add Formula to Unprojected column in child and parent grid. ' AS TITLE,
	'Selva.Sebastian' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	31 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Parameters Tab ' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Scenario Dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Parent Source Checkboxes; Default checked all ' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Advanced Parameters Tab' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Need to add column selection list box for the child grid to the advanced parameters tabs.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Add Crosswalk List Box to select multiple crosswalk columns; default Crosswalk Unspread Target:Funding and Crosswalk Deferred RQMT:Funding' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Add Unfunded RQMT:Funding and Deferred RQMT:Target to crosswalk selection list box' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Add abilitity to select and deselect Gross, Peace and Supp section in the child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Update parameters based on the new design ***See screenshot below***' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Move Add row total from parameters tab to Advanced Parameters tab. Place above Select Subtotal Fields list box on Subtotal(Parent Grid) tab.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Default check Gross only for the parent and child Add row total for check boxes' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Load Custom View label -> Rename to Grid Layout' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11495 AS WORKITEMID,
	'Advanced Parameters >> Rename Resource Types' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	13 AS Sort_Order UNION ALL 
	SELECT 11498 AS WORKITEMID,
	'Target Grid (Parent Grid)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11498 AS WORKITEMID,
	'Target Details Grid (Child Grid)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11498 AS WORKITEMID,
	'Add Resource Type Link OBE' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11498 AS WORKITEMID,
	'Default check Peace, Peace Topline, Supp OCO and Supp TWCF Resource Types' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11498 AS WORKITEMID,
	'Add RQMT column to the right of Resource Type in child grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11498 AS WORKITEMID,
	'RQMT Gross resource type gray line becomes Total amounts.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11498 AS WORKITEMID,
	'Remove Gross section in child grid and move totals under the Resource type section' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11498 AS WORKITEMID,
	'Remove RQMT Gross as a resource type option in the combo box on top of the grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11498 AS WORKITEMID,
	'Make sure parent and child grid text is unwrapped' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11498 AS WORKITEMID,
	'Removed Border around input boxes' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11498 AS WORKITEMID,
	'Grid and Resource Type Combo Box >> Rename Resource Types' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Sort Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Reorder Column Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Excel Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Refresh' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Year Dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Resource Types Combo Box' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Parent Source Checkboxes' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Amount Only Chekcbox' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Quick Filter Dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Cancel Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Save Button' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11497 AS WORKITEMID,
	'Related Items' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'WCN Level Layout' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Resource Type Child Layout' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Add Resource Type link in Resource Type Child grid (OBE, see # 13)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Default Check Peace, Peace Topline, Supp OCO and Supp TWCF Resource types.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Remove Target Column and Crosswalk columns from WCN Level' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Remove Program Group and Program from WCN Level' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Add Target Level above WCN Child level' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'If MCO, Success or Failure are selected from the Resource Type dropdown, then the only editable fields are QTY RQMT and RQMT/RT' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Only Selected Parent Source checkboxes should appear on the WCN level' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Only display selected Resource Types selected in Resource Type dropdown in Resource Type Child grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Add multiple Crosswalk section if multiple parent source checkboxes are checked from parameters window. Ex: If Gross and Peace are selected, then there needs to be a Crosswalk(Gross) section after the Gross section and a Crosswalk(Peace) section after the Peace section' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Funding Updated Date Needs to be a link' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Incorporate new Resource Type grid layout per Erin. See New Resource Type Grid screenshot' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	13 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Add gear icon, as Taylor did in the RFM grid, which will include the parameters window when clicked, so users can change parameters' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	14 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Add Other option to Resource Type dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	15 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Compress columns in the Resource Type grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	16 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Center Align column headers' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	17 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Rename UnObl RQMT to UnObl' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	18 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Default sort on child grid to: WCN, PEC and then Resource Type(RQMT Gross should be first, then PEACE/Peace, PEACE/Topline, SUPP/OCO, SUPP/TWCF)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	19 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Add OOC Status column in the WCN grid when the data call supports OOC' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	20 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Highlight Gross rows in blue; See Taylors RFM grid in AXE' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	21 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Add Attachment indicator to WCN Level grid for WCNs with attachments' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	22 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Change color of RQMT Gross highlight; Per Erin: Current color is too dark.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	23 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Add indicator that dollar amounts are in 000s.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	24 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Move Approved USP to the right of Resource Type column' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	25 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Hide border around textbox for input fields' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	26 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Fix compulation columns in child and parent grid so numbers are totaling correctly' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	27 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Rename EOY OBS to EOY' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	28 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Rename UnObl to Uncommitted for current and future years and Unobligated in historical years.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	29 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Do not wrap text in child and parent grids' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	30 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Remove RQMT from GROSS section on parent grid; Add RQMT under its new section called, RQMT' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	31 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Rename RQMT GROSS to REQUIREMENT under the Resource Type Column in the child grid for the GROSS gray rows' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	32 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Rename UnCommitted to UnProjected (UnProjected = EOY - Resource Type Funding)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	33 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Remove QTY RQMT and RQMT from GROSS section on child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	34 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Move EOY to the left of UNFUNDED in the GROSS, PEACE and SUPP sections on the child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	35 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'If Amount TY = 0, then hide Resource Type. Only show Resource Types where Amount TY > 0.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	36 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Add Add Resource Type link to add Resource Types to desired WCNs so users can add funding.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	37 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Move USPs into one column in child grid; seperate them by a /; rename column to Apprd/Adj USP' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	38 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'If a WCN doesnt have a USP leave the Apprd/Adj USP column blank' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	39 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Default PEACE/Peace, PEACE/Topline and SUPP/OCO resource types in child grid. All other resource types will display on the grid in any amounts are greater than 0' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	40 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Rename APPRD/ADJ USP to APRVD/ADJ USP' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	41 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Hyperlink the APRVD/ADJ USP column in child grid. Hyperlink will bring up textbox giving definitions for Approved and Adjusted USP' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	42 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Add UnProjected formula to column label in parent and child.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	43 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Adopt new Child grid layout; See attached screenshot New RFM Crosswalk Child grid' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	44 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Grid and Resource Type Combo Box >> Rename Resource Types' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	45 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Grid needs to support decimals in user enters in decimals. ' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	46 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Only caculate UNFUNDED on Total row' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	47 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Updated Date Rename to UPDATED' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	48 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'UPDATED column on Total Row must pull most recent update date; No matter what is being file maintained.' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	49 AS Sort_Order UNION ALL 
	SELECT 11456 AS WORKITEMID,
	'Update APRVD/ADJ USP blue ? narrative' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	50 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Create Menu Item for RFM Crosswalk Grid under Quick Maintenance in all Data Call Categories except RQMTs Report' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Create New Parameters Pop Up Window' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Get Data Button Opens Up to New RFM Crosswalk Grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Add Checkbox option to Crosswalk to CRIS;Default unchecked (Only available for Execution DCs) ' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Parameters Tab' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Advanced Parameters Tab' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Remove Do you want to Crosswalk to CRIS checkbox from Parameters Tab' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Create New Advanced Parameters tab, See screenshot below' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Rename AFEEIC SAFFM to AFEEIC' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Move Other Parameters section above the Select Fields to Display on WCN Grid section' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Set a 7 selection limit on the Select PCN Details To Display section' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Default Parent Source selection on parameters tab to: Gross, Peace and Supp' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Remove MCO, Success and Failure from Other Resource Type selection list in Select Resource Type To Display section' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	13 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Disable Crosswalk Columns Section Dropdowns' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	14 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Change Select PCN Details to Display to Select WCN Details to Display' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	15 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Lock CMD(OAC) and PEC in the Select WCN Details to Display' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	16 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Add Ability to add/remove the Gross, Peace and Supp sections in the child grid on the advanced parameters tab' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	17 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Change Crosswalk Section into list box; Default selected Crosswalk Unspread Target: Funding and Crosswalk Deferred RQMT:Funding; limit to three selections' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	18 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Add Apply Resource Type Filter to Gross Calculation checkbox' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	19 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Add ALL option to quick filter dropdown. Default this option as well' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	20 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Add Checkboxes for what the user wants to file maintain(RQMT, Funding,);Default check all' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	21 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Default check only Gross for the child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	22 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Move Add row total from parameters tab to Advanced Parameters tab. Place above Select Subtotal Fields list box on Subtotal(Parent Grid) tab.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	23 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Default check Gross only for the parent and child Add row total for check boxes' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	24 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Load Custom View label -> Rename to Grid Layout' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	25 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Advanced Parameters >> Rename Resource Types' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	26 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Add Risk Category to the Subtotal Parent Grid list box' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	27 AS Sort_Order UNION ALL 
	SELECT 11467 AS WORKITEMID,
	'Uncheck Gross section on WCN Details tab.' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	28 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Sort Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Reorder Column Icon' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Refresh' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Year Dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Resource Types Combo Box' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Parent Source Checkboxes' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Amount Only Checkbox' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Excel Icon' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Quick Filter Dropdown' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Review/Edit PCN Task Button' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Cancel Button' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Save Button' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11455 AS WORKITEMID,
	'Related Items Button' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	13 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'WCN Level Layout' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	1 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Resource Type Child Layout' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	2 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Add Resource Type link in Resource Type Child grid (OBE, see # 13)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	3 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Default Check Peace, Peace Topline, Supp OCO and Supp TWCF Resource types.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	4 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Remove Target Column and Crosswalk columns from WCN Level' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	5 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Remove Program Group and Program from WCN Level' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	6 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Add Target Level above WCN Child level' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	7 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'If MCO, Success or Failure are selected from the Resource Type dropdown, then the only editable fields are QTY RQMT and RQMT/RT' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	8 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Only Selected Parent Source checkboxes should appear on the WCN level' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	9 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Only display selected Resource Types selected in Resource Type dropdown in Resource Type Child grid.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	10 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Add multiple Crosswalk section if multiple parent source checkboxes are checked from parameters window. Ex: If Gross and Peace are selected, then there needs to be a Crosswalk(Gross) section after the Gross section and a Crosswalk(Peace) section after the Peace section' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	11 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Funding Updated Date Needs to be a link' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	12 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Incorporate new Resource Type grid layout per Erin. See New Resource Type Grid screenshot' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	13 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Add gear icon, as Taylor did in the RFM grid, which will include the parameters window when clicked, so users can change parameters' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	14 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Add Other option to Resource Type dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	15 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Compress Columns in the Resource Type dropdown' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	16 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Center align column headers' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	17 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Rename UnObl RQMT to UnObl' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	18 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Default sort on child grid to: WCN, PEC and then Resource Type(RQMT Gross should be first, then PEACE/Peace, PEACE/Topline, SUPP/OCO, SUPP/TWCF)' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	19 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Highlight Gross Rows in blue; see Taylors RFM Grid in AXE' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	20 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Add Attachment indicator to WCN Level grid for WCNs with attachments ' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	21 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Change color of RQMT Gross highlight; Per Erin: Current color is too dark' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	22 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Add indicator that dollar amounts are in 000s.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	23 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Move Approved USP to the right of Resource Type column' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	24 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Hide border around textbox for input fields' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	25 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Fix compulation columns in child and parent grid so numbers are totaling correctly' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	26 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Do not wrap text in child and parent grids.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	27 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Remove RQMT from GROSS section on parent grid; Add RQMT under its new section called, RQMT' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	28 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Rename RQMT GROSS to REQUIREMENT under the Resource Type Column in the child grid for the GROSS gray rows' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	29 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Remove QTY RQMT and RQMT from GROSS section on child grid' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	30 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'If Amount TY = 0, then hide Resource Type. Only show Resource Types where Amount TY > 0.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	31 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Add Add Resource Type link to add Resource Types to desired WCNs so users can add funding.' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	32 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Move USPs into one column in child grid; seperate them by a /; rename column to Apprd/Adj USP' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	33 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'If a WCN doesnt have a USP leave the Apprd/Adj USP column blank' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	34 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Default PEACE/Peace, PEACE/Topline and SUPP/OCO resource types in child grid. All other resource types will display on the grid in any amounts are greater than 0' AS TITLE,
	'Business.Complete' AS AssignedTo,
	100 AS CompletionPercent,
	'Complete' AS Status,
	35 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Rename APPRD/ADJ USP to APRVD/ADJ USP' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	36 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Add blue ? mark for APRVD/ADJ USP column in child grid. Hyperlink will bring up textbox giving definitions for Approved and Adjusted USP' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	37 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Adopt new Child grid layout; See attached screenshot New RFM Crosswalk Child grid' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	38 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Grid and Resource Type Combo Box >> Rename Resource Types' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	39 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Only caculate UNFUNDED on Total row' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	40 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'Updated Date Rename to UPDATED' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	41 AS Sort_Order UNION ALL 
	SELECT 11470 AS WORKITEMID,
	'UPDATED column on Total Row must pull most recent update date; No matter what is being file maintained.' AS TITLE,
	'Esel.Ramos' AS AssignedTo,
	0 AS CompletionPercent,
	'New' AS Status,
	42 AS Sort_Order 
) a;

GO

DECLARE @count int = 0;
select @count = count(*) from #TaskList;-- AS TaskList_Count
PRINT CONVERT(nvarchar(3), @count) + ' #TaskList count';
GO

DECLARE @count int = 0;
select @count = count(*) from WORKITEM_TASK;-- AS WorkItem_Task_CountBeforeInsert
PRINT CONVERT(nvarchar(3), @count) + ' WorkItem Task Count Before Insert';
GO

BEGIN TRANSACTION taskInsert

INSERT INTO WORKITEM_TASK(WORKITEMID, TITLE, [DESCRIPTION], ASSIGNEDRESOURCEID, COMPLETIONPERCENT, STATUSID, SORT_ORDER, TASK_NUMBER, CREATEDBY, UPDATEDBY)
SELECT
	WORKITEMID
	, CASE WHEN LEN(TITLE) > 150
		THEN LEFT(TITLE,150)
		ELSE TITLE END TITLE
	, TITLE AS [DESCRIPTION]
	, wr.WTS_RESOURCEID AS ASSIGNEDRESOURCEID
	, tl.CompletionPercent AS COMPLETIONPERCENT
	, s.STATUSID AS STATUSID
	, tl.Sort_Order AS SORT_ORDER
	, tl.Sort_Order AS TASK_NUMBER
	, 'Joseph.Porubsky' AS CREATEDBY
	, 'Joseph.Porubsky' AS UPDATEDBY
FROM
	#TaskList tl
		JOIN WTS_RESOURCE wr ON tl.AssignedTo = wr.USERNAME
		JOIN [STATUS] s ON tl.Status = s.[STATUS]
EXCEPT SELECT WORKITEMID, TITLE, [DESCRIPTION], ASSIGNEDRESOURCEID, COMPLETIONPERCENT, STATUSID, SORT_ORDER, TASK_NUMBER, CREATEDBY, UPDATEDBY FROM WORKITEM_TASK
;

GO

DECLARE @count int = 0;
select @count = count(*) from WORKITEM_TASK;-- AS WorkItem_Task_CountAfterInsert
PRINT CONVERT(nvarchar(3), @count) + ' WorkItem Task Count After Insert';
GO


/*
If Xact_State()=1
Begin
    Print 'Committing Tranaction...';
    Commit tran;
	
	DECLARE @count int = 0;
	select @count = count(*) from WORKITEM_TASK;-- AS WorkItem_Task_CountAfterInsert
	PRINT CONVERT(nvarchar(3), @count) + ' WorkItem Task Count After commit';
	GO

End
Else If Xact_State()=-1
Begin
    Print 'Rolling Back Transaction...'
    rollback tran;

	DECLARE @count int = 0;
	select @count = count(*) from WORKITEM_TASK;-- AS WorkItem_Task_CountAfterInsert
	PRINT CONVERT(nvarchar(3), @count) + ' WorkItem Task Count After Rollback';
	GO

End
*/

--ROLLBACK tran;
COMMIT tran;

DECLARE @count int = 0;
select @count = count(*) from WORKITEM_TASK;-- AS WorkItem_Task_CountAfterInsert
--PRINT CONVERT(nvarchar(3), @count) + ' WorkItem Task Count After rollback';
PRINT CONVERT(nvarchar(3), @count) + ' WorkItem Task Count After commit';
GO


DROP TABLE #TaskList;

GO
