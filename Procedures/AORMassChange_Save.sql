USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMassChange_Save]    Script Date: 8/2/2018 9:02:40 AM ******/
DROP PROCEDURE [dbo].[AORMassChange_Save]
GO

/****** Object:  StoredProcedure [dbo].[AORMassChange_Save]    Script Date: 8/2/2018 9:02:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[AORMassChange_Save]
	@EntityType nvarchar(50)
	,@FieldName nvarchar(50)
	, @ExistingValue nvarchar(MAX) = ''
	, @NewValue nvarchar(50)
	, @EntityFilter nvarchar(MAX)
	, @UpdatedBy nvarchar(255) = 'WTS_ADMIN'
	--Rows affected
	, @RowsUpdated int output
AS
BEGIN
	
	DECLARE @date datetime = GETDATE();
	DECLARE @sql nvarchar(max) = '';
	DECLARE @itemUpdateTypeID int;

	select @itemUpdateTypeID = ITEM_UPDATETYPEID from ITEM_UPDATETYPE where upper(ITEM_UPDATETYPE) = 'UPDATE';

	IF @EntityType = 'AOR'
	BEGIN
		IF @FieldName = 'Current Release'
		BEGIN
			UPDATE AORRelease
			SET
				ProductVersionID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE AORReleaseID IN (
				SELECT arl.AORReleaseID
				FROM 
					AORRelease arl
				WHERE
					(arl.AORReleaseID is null or arl.[Current] = 1)
					and charindex(',' + convert(nvarchar(10), arl.AORID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10), arl.ProductVersionID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		IF @FieldName = 'Workload Allocation'
		BEGIN
			--UPDATE AORRelease
			--SET
			--	WorkloadAllocationID = CONVERT(int, @NewValue)
			--	, UPDATEDBY = @UpdatedBy
			--	, UPDATEDDATE = @date
			--WHERE AORReleaseID IN (
			--	SELECT arl.AORReleaseID
			--	FROM 
			--		AORRelease arl
			--	WHERE
			--		(arl.AORReleaseID is null or arl.[Current] = 1)
			--		and charindex(',' + convert(nvarchar(10), arl.AORID) + ',', ',' + @EntityFilter + ',') > 0
			--		and charindex(',' + convert(nvarchar(10), arl.WorkloadAllocationID) + ',', ',' + @ExistingValue + ',') > 0
			--);

			IF ISNULL(CONVERT(int, @ExistingValue),0) != ISNULL(CONVERT(int, @NewValue),0)
				BEGIN
					select @sql = stuff((select ' ' + [dbo].[Get_Updates](arl.AORReleaseID, 0, 'WORKLOAD ALLOCATION', @NewValue, 'AOR', null, @UpdatedBy) FROM 
							AORRelease arl
						WHERE
							(arl.AORReleaseID is null or arl.[Current] = 1)
							and charindex(',' + convert(nvarchar(10), arl.AORID) + ',', ',' + @EntityFilter + ',') > 0
							and charindex(',' + convert(nvarchar(10), arl.WorkloadAllocationID) + ',', ',' + @ExistingValue + ',') > 0 
						for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');

					if @sql != ''
						begin
							execute sp_executesql @sql;
						end;

					SET @RowsUpdated = LEN(@EntityFilter) - LEN(REPLACE(@EntityFilter, ',', '')) + 1;
				END;
		END;
	END;
	IF @EntityType = 'CR' 
	BEGIN
		IF @FieldName = 'Contract'
			BEGIN
				UPDATE AORCR
				SET
					[ContractID] = CONVERT(int, @NewValue)
					, UPDATEDBY = @UpdatedBy
					, UPDATEDDATE = @date
				WHERE [CRID] IN (
					SELECT acr.[CRID]
					FROM 
						AORCR acr
					WHERE
						charindex(',' + convert(nvarchar(10), acr.CRID) + ',', ',' + @EntityFilter + ',') > 0
						and charindex(',' + convert(nvarchar(10), acr.[ContractID]) + ',', ',' + @ExistingValue + ',') > 0
				);

				SET @RowsUpdated = @@ROWCOUNT;
			END;
		IF @FieldName = 'CR Coordination'
			BEGIN
				UPDATE AORCR
				SET
					StatusID = CONVERT(int, @NewValue)
					, UPDATEDBY = @UpdatedBy
					, UPDATEDDATE = @date
				WHERE [CRID] IN (
					SELECT acr.[CRID]
					FROM 
						AORCR acr
					WHERE
						charindex(',' + convert(nvarchar(10), acr.CRID) + ',', ',' + @EntityFilter + ',') > 0
						and charindex(',' + convert(nvarchar(10), acr.StatusID) + ',', ',' + @ExistingValue + ',') > 0
				);

				SET @RowsUpdated = @@ROWCOUNT;
			END;
			IF @FieldName = 'Websystem'
			BEGIN
				UPDATE AORCR
				SET
					Websystem = @NewValue
					, UPDATEDBY = @UpdatedBy
					, UPDATEDDATE = @date
				WHERE [CRID] IN (
					SELECT acr.[CRID]
					FROM 
						AORCR acr
					WHERE
						charindex(',' + convert(nvarchar(10), acr.CRID) + ',', ',' + @EntityFilter + ',') > 0
						and charindex(',' + convert(nvarchar(10), acr.Websystem) + ',', ',' + @ExistingValue + ',') > 0
				);

				SET @RowsUpdated = @@ROWCOUNT;
			END;
		END;
	IF @EntityType = 'PrimaryTask'
		BEGIN
		IF @FieldName = 'System(Task)'
		BEGIN
			insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
			SELECT @itemUpdateTypeID, 
				wi.WorkItemID, 
				@FieldName, 
				(select ws.WTS_SYSTEM from WTS_SYSTEM ws where ws.WTS_SYSTEMID = wi.WTS_SYSTEMID), 
				(select ws.WTS_SYSTEM from WTS_SYSTEM ws where ws.WTS_SYSTEMID = @NewValue), 
				@UpdatedBy, 
				@UpdatedBy
			from WORKITEM wi 
				where charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
				and charindex(',' + convert(nvarchar(10),  wi.WTS_SYSTEMID) + ',', ',' + @ExistingValue + ',') > 0

			UPDATE WORKITEM
			SET
				WTS_SYSTEMID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.WTS_SYSTEMID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		IF @FieldName = 'Production Status'
		BEGIN
			insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
			SELECT @itemUpdateTypeID, 
				wi.WorkItemID, 
				@FieldName, 
				(select s.[STATUS] from [STATUS] s where s.STATUSID = wi.ProductionStatusID), 
				(select s.[STATUS] from [STATUS] s where s.STATUSID = @NewValue), 
				@UpdatedBy, 
				@UpdatedBy
			from WORKITEM wi 
				where charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
				and charindex(',' + convert(nvarchar(10),  wi.ProductionStatusID) + ',', ',' + @ExistingValue + ',') > 0

			UPDATE WORKITEM
			SET
				ProductionStatusID = CONVERT(bit, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.ProductionStatusID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		IF @FieldName = 'Product Version'
		BEGIN
			insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
			SELECT @itemUpdateTypeID, 
				wi.WorkItemID, 
				@FieldName, 
				(select pv.ProductVersion from ProductVersion pv where pv.ProductVersionID = wi.ProductVersionID), 
				(select pv.ProductVersion from ProductVersion pv where pv.ProductVersionID = @NewValue), 
				@UpdatedBy, 
				@UpdatedBy
			from WORKITEM wi 
				where charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
				and charindex(',' + convert(nvarchar(10),  wi.ProductVersionID) + ',', ',' + @ExistingValue + ',') > 0

			UPDATE WORKITEM
			SET
				ProductVersionID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.ProductVersionID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		ELSE IF @FieldName = 'Priority'
		BEGIN
			insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
			SELECT @itemUpdateTypeID, 
				wi.WorkItemID, 
				@FieldName, 
				(select p.[PRIORITY] from [PRIORITY] p where p.PRIORITYID = wi.PRIORITYID), 
				(select p.[PRIORITY] from [PRIORITY] p where p.PRIORITYID = @NewValue), 
				@UpdatedBy, 
				@UpdatedBy
			from WORKITEM wi 
				where charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
				and charindex(',' + convert(nvarchar(10),  wi.PRIORITYID) + ',', ',' + @ExistingValue + ',') > 0

			UPDATE WORKITEM
			SET
				PRIORITYID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.PRIORITYID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		ELSE IF @FieldName = 'Status'
		BEGIN
			IF ISNULL(CONVERT(int, @ExistingValue),0) != ISNULL(CONVERT(int, @NewValue),0)
				BEGIN
					select @sql = 'declare @Old_StatusID int;
						declare @SRNumber int;
						declare @AssignedToRankID int;
						declare @BusinessRank int;
						declare @Cascade int;
						declare @field1 int;
						declare @CurAORRelease varchar(max) = null; ';

					select @sql = @sql + stuff((select ' ' + [dbo].[Get_Updates](wi.WORKITEMID, 0, 'Status', @NewValue, 'Crosswalk', null, @UpdatedBy) FROM 
							WORKITEM wi
						WHERE charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
						and charindex(',' + convert(nvarchar(10),  wi.STATUSID) + ',', ',' + @ExistingValue + ',') > 0
						for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');

					if @sql != ''
						begin
							execute sp_executesql @sql;
						end;

					SET @RowsUpdated = LEN(@EntityFilter) - LEN(REPLACE(@EntityFilter, ',', '')) + 1;
				END;
		END;
		ELSE IF @FieldName = 'Assigned To'
		BEGIN
			insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
			SELECT @itemUpdateTypeID, 
				wi.WorkItemID, 
				@FieldName, 
				(select wr.FIRST_NAME + ' ' + wr.LAST_NAME from WTS_RESOURCE wr where wr.WTS_RESOURCEID = wi.ASSIGNEDRESOURCEID), 
				(select wr.FIRST_NAME + ' ' + wr.LAST_NAME from WTS_RESOURCE wr where wr.WTS_RESOURCEID = @NewValue), 
				@UpdatedBy, 
				@UpdatedBy
			from WORKITEM wi 
				where charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
				and charindex(',' + convert(nvarchar(10),  wi.ASSIGNEDRESOURCEID) + ',', ',' + @ExistingValue + ',') > 0

			UPDATE WORKITEM
			SET
				ASSIGNEDRESOURCEID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.ASSIGNEDRESOURCEID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		ELSE IF @FieldName = 'Primary Resource'
		BEGIN
			insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
			SELECT @itemUpdateTypeID, 
				wi.WorkItemID, 
				@FieldName, 
				(select wr.FIRST_NAME + ' ' + wr.LAST_NAME from WTS_RESOURCE wr where wr.WTS_RESOURCEID = wi.PRIMARYRESOURCEID), 
				(select wr.FIRST_NAME + ' ' + wr.LAST_NAME from WTS_RESOURCE wr where wr.WTS_RESOURCEID = @NewValue), 
				@UpdatedBy, 
				@UpdatedBy
			from WORKITEM wi 
				where charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
				and charindex(',' + convert(nvarchar(10),  wi.PRIMARYRESOURCEID) + ',', ',' + @ExistingValue + ',') > 0

			UPDATE WORKITEM
			SET
				PRIMARYRESOURCEID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.PRIMARYRESOURCEID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		ELSE IF @FieldName = 'Percent Complete'
		BEGIN
			UPDATE WORKITEM
			SET
				COMPLETIONPERCENT = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.COMPLETIONPERCENT) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
	END;
	IF @EntityType = 'Subtask'
		BEGIN
		IF @FieldName = 'System(Task)'
		BEGIN
			UPDATE WORKITEM
			SET
				WTS_SYSTEMID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.WTS_SYSTEMID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		IF @FieldName = 'Production Status'
		BEGIN
			UPDATE WORKITEM
			SET
				ProductionStatusID = CONVERT(bit, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.ProductionStatusID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		IF @FieldName = 'Product Version'
		BEGIN
			UPDATE WORKITEM
			SET
				ProductVersionID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.ProductVersionID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		ELSE IF @FieldName = 'Priority'
		BEGIN
			UPDATE WORKITEM
			SET
				PRIORITYID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.PRIORITYID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		ELSE IF @FieldName = 'Status'
		BEGIN
			UPDATE WORKITEM
			SET
				STATUSID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.STATUSID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		ELSE IF @FieldName = 'Assigned To'
		BEGIN
			insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
			SELECT @itemUpdateTypeID, 
				wit.WORKITEM_TASKID, 
				@FieldName, 
				(select wr.FIRST_NAME + ' ' + wr.LAST_NAME from WTS_RESOURCE wr where wr.WTS_RESOURCEID = wit.ASSIGNEDRESOURCEID), 
				(select wr.FIRST_NAME + ' ' + wr.LAST_NAME from WTS_RESOURCE wr where wr.WTS_RESOURCEID = @NewValue), 
				@UpdatedBy, 
				@UpdatedBy
			from WORKITEM_TASK wit
				where charindex(',' + convert(nvarchar(10), wit.WORKITEM_TASKID) + ',', ',' + @EntityFilter + ',') > 0
				and charindex(',' + convert(nvarchar(10),  wit.ASSIGNEDRESOURCEID) + ',', ',' + @ExistingValue + ',') > 0

			UPDATE WORKITEM_TASK
			SET
				ASSIGNEDRESOURCEID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEM_TASKID IN (
				SELECT wit.WORKITEM_TASKID
				FROM 
					WORKITEM_TASK wit
				WHERE
					charindex(',' + convert(nvarchar(10), wit.WORKITEM_TASKID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wit.ASSIGNEDRESOURCEID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		ELSE IF @FieldName = 'Primary Resource'
		BEGIN
			UPDATE WORKITEM
			SET
				PRIMARYRESOURCEID = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.PRIMARYRESOURCEID) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
		ELSE IF @FieldName = 'Percent Complete'
		BEGIN
			UPDATE WORKITEM
			SET
				COMPLETIONPERCENT = CONVERT(int, @NewValue)
				, UPDATEDBY = @UpdatedBy
				, UPDATEDDATE = @date
			WHERE WORKITEMID IN (
				SELECT wi.WORKITEMID
				FROM 
					WORKITEM wi
				WHERE
					charindex(',' + convert(nvarchar(10), wi.WORKITEMID) + ',', ',' + @EntityFilter + ',') > 0
					and charindex(',' + convert(nvarchar(10),  wi.COMPLETIONPERCENT) + ',', ',' + @ExistingValue + ',') > 0
			);

			SET @RowsUpdated = @@ROWCOUNT;
		END;
	END;
END;



GO


