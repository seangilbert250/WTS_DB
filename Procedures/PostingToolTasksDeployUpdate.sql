USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[PostingToolTasksDeployUpdate]    Script Date: 5/11/2018 10:41:47 PM ******/
DROP PROCEDURE [dbo].[PostingToolTasksDeployUpdate]
GO

/****** Object:  StoredProcedure [dbo].[PostingToolTasksDeployUpdate]    Script Date: 5/11/2018 10:41:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[PostingToolTasksDeployUpdate]
	@Changes xml,
	@DeployEnvironment nvarchar(255),
	@UpdatedByID nvarchar(10),
	@Saved bit = 0 output
as
begin
	set nocount on;
	--XML Format
	--<changes><update><itemid>16699</itemid></update><update><itemid>16545 - 23</itemid></update></changes>
	declare @date nvarchar(30);
	declare @ItemID nvarchar(50);
	declare @workitemTaskID nvarchar(50); 
	declare @statusID nvarchar(50);
	declare @percentComplete nvarchar(50);
	declare @assignedToID nvarchar(50);
	declare @submittedByID nvarchar(50);
	declare @deployedType nvarchar(50);
    declare @deployedTypeOn nvarchar(100);
    declare @deployedTypeByID nvarchar(50);
	declare @deployedTypeBy nvarchar(100);
	declare @selectedDeploy nvarchar(50);
	declare @operatorName nvarchar(100);
    declare @isIVTRequired nvarchar(50);
	declare @sql nvarchar(max) = '';
	
	set @date = convert(nvarchar(30), getdate());
	set @operatorName = (select FIRST_NAME + ' ' + LAST_NAME FROM WTS_RESOURCE WHERE WTS_ResourceID = @UpdatedByID);

	if @DeployEnvironment = 'Commercial' 
		set @selectedDeploy = '_Comm'; 

	if @DeployEnvironment = 'Test' 
		set @selectedDeploy = '_Test'; 

	if @DeployEnvironment = 'Production' 
		set @selectedDeploy = '_Prod'; 
	
		declare cur CURSOR LOCAL for
			select
				tbl.updates.value('itemid[1]', 'varchar(10)') as ItemID
				from @Changes.nodes('changes/update') as tbl(updates);
		
		open cur
		fetch next from cur into @ItemID
		while @@FETCH_STATUS = 0 BEGIN

		if charindex('-', upper(@ItemID)) > 0
			begin
				select 
					@workitemTaskID = wit.WORKITEM_TASKID,
					@statusID = wit.STATUSID,
					@percentComplete = wit.COMPLETIONPERCENT,
					@assignedToID = wit.ASSIGNEDRESOURCEID,
					@submittedByID = wit.SubmittedByID
				from WORKITEM_TASK wit
				where convert(nvarchar(10), wit.WORKITEMID)  + '-' + convert(nvarchar(10), wit.TASK_NUMBER) = @ItemID;

                if @statusID = '8'
					begin
							set @sql = @sql + ' INSERT INTO WorkItem_Task_History (ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE) 
							VALUES (5, ' + @workitemTaskID + ', ''Status'', ''Checked In'', ''Deployed'', ''' + @operatorName + ''', ''' + @date + ''', ''' + @operatorName + ''', ''' + @date + ''');';
						set @sql = @sql + ' UPDATE WorkItem_Task SET StatusID = 9, UPDATEDBY = ''' + @operatorName + ''', UPDATEDDATE = ''' + @date + ''' WHERE WORKITEM_TASKID = ' + @workitemTaskID + ' AND StatusID = 8;';
                
						if @percentComplete != '100'
							begin
								set @sql = @sql + 'insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
								values(5, ' + @workitemTaskID + ', ''Percent Complete'', (select COMPLETIONPERCENT from WORKITEM_TASK where WORKITEM_TASKID = ' + @workitemTaskID + '), ' + '100' + ', ''' + @operatorName + ''', ''' + @operatorName + ''');
								update WORKITEM_TASK set COMPLETIONPERCENT = ' + '100' + ', UPDATEDBY = ''' + @operatorName + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @workitemTaskID + ';'
							end;
						if @assignedToID != @submittedByID
							begin
								set @sql = @sql + ' insert into WORKITEM_TASK_HISTORY(ITEM_UPDATETYPEID, WORKITEM_TASKID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
								values(5, ' + @workitemTaskID + ', ''Assigned To'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM_TASK wit join WTS_RESOURCE wr on wit.ASSIGNEDRESOURCEID = wr.WTS_RESOURCEID where wit.WORKITEM_TASKID = ' + @workitemTaskID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @submittedByID + '), ''' + @operatorName + ''', ''' + @operatorName + ''');
								update WORKITEM_TASK set ASSIGNEDRESOURCEID = ' + @submittedByID + ', UPDATEDBY = ''' + @operatorName + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEM_TASKID = ' + @workitemTaskID + ';'
							end;		
					end;
			end;
		else
			begin
				select 
					@statusID = wi.STATUSID,
					@percentComplete = wi.COMPLETIONPERCENT,
					@assignedToID = wi.ASSIGNEDRESOURCEID,
					@submittedByID = wi.SubmittedByID,
					@deployedType = case when @DeployEnvironment = 'Commercial' then Deployed_Comm
					when @DeployEnvironment = 'Test' then Deployed_Test
					when @DeployEnvironment = 'Production' then Deployed_Prod else '' end,
					@deployedTypeOn = case when @DeployEnvironment = 'Commercial' then DeployedDate_Comm
					when @DeployEnvironment = 'Test' then DeployedDate_Test
					when @DeployEnvironment = 'Production' then DeployedDate_Prod else '' end,
					@deployedTypeByID = case when @DeployEnvironment = 'Commercial' then DeployedBy_CommID
					when @DeployEnvironment = 'Test' then DeployedBy_TestID
					when @DeployEnvironment = 'Production' then DeployedBy_ProdID else '' end,
					@isIVTRequired = IVTRequired
				from WORKITEM wi 
				where wi.WORKITEMID = @ItemID;

				set @deployedTypeBy = (select FIRST_NAME + ' ' + LAST_NAME FROM WTS_RESOURCE WHERE WTS_ResourceID = @deployedTypeByID);

				if @isIVTRequired = '0' and @statusID = '8'
					begin
						set @sql = @sql + ' INSERT INTO WorkItem_History (ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE) 
						VALUES (5, ' + @ItemID + ', ''Deployed ' + @DeployEnvironment + ' On'', (SELECT DeployedDate' + @selectedDeploy + ' FROM WorkItem WHERE WorkItemID = ' + @ItemID + '), ''' + @date + ''', ''' + @operatorName + ''', ''' + @date + ''', ''' + @operatorName + ''', ''' + @date + ''');';
                                    
						set @sql = @sql + ' UPDATE WorkItem SET DeployedDate' + @selectedDeploy + ' = ''' + @date + ''', DeployedBy' + @selectedDeploy + 'ID = ' + @UpdatedByID + ', StatusID = 9, Deployed' + @selectedDeploy + ' = 1, UPDATEDBY = ''' + @operatorName + ''', UPDATEDDATE = ''' + @date + ''' WHERE WorkItemID = ' + @ItemID + ' AND StatusID = 8;';
                                    
						set @sql = @sql + ' INSERT INTO WorkItem_History (ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE) 
						VALUES (5, ' + @ItemID + ', ''Status'', ''Checked In'', ''Deployed'', ''' + @operatorName + ''', ''' + @date + ''', ''' + @operatorName + ''', ''' + @date + ''');';
                                    
						if @deployedType = '0'
							begin
								set @sql = @sql + ' INSERT INTO WorkItem_History (ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE) 
								VALUES (5, ' + @ItemID + ', ''Deployed ' + @DeployEnvironment + ''', ''No'', ''Yes'', ''' + @operatorName + ''', ''' + @date + ''', ''' + @operatorName + ''', ''' + @date + ''');';
							end;

						if @deployedTypeBy != @operatorName
						begin
							set @sql = @sql + ' INSERT INTO WorkItem_History (ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE) 
							VALUES (5, ' + @ItemID + ', ''Deployed ' + @DeployEnvironment + ' By'', ''' + @deployedTypeBy + ''', ''' + @operatorName + ''', ''' + @operatorName + ''', ''' + @date + ''', ''' + @operatorName + ''', ''' + @date + ''');';
                        end;

						if @percentComplete != '100'
						begin
							set @sql = @sql + 'insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
							values(5, ' + @ItemID + ', ''Percent Complete'', (select COMPLETIONPERCENT from WORKITEM where WORKITEMID = ' + @ItemID + '), ' + '100' + ', ''' + @operatorName + ''', ''' + @operatorName + ''');
							update WORKITEM set COMPLETIONPERCENT = ' + '100' + ', UPDATEDBY = ''' + @operatorName + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
						end;
						if @assignedToID != @submittedByID
						begin
							set @sql = @sql + ' insert into WorkItem_History(ITEM_UPDATETYPEID, WORKITEMID, FieldChanged, OldValue, NewValue, CREATEDBY, UPDATEDBY)
							values(5, ' + @ItemID + ', ''Assigned To'', (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WORKITEM wi join WTS_RESOURCE wr on wi.ASSIGNEDRESOURCEID = wr.WTS_RESOURCEID where wi.WORKITEMID = ' + @ItemID + '), (select wr.FIRST_NAME + '' '' + wr.LAST_NAME from WTS_RESOURCE wr WHERE wr.WTS_RESOURCEID  = ' + @submittedByID + '), ''' + @operatorName + ''', ''' + @operatorName + ''');
							update WORKITEM set ASSIGNEDRESOURCEID = ' + @submittedByID + ', UPDATEDBY = ''' + @operatorName + ''', UPDATEDDATE = ''' + @date + ''' where WORKITEMID = ' + @ItemID + ';'
						end;
					end;
				end;
			fetch next from cur into @ItemID
		END;

		close cur
		deallocate cur
	
	begin
		execute sp_executesql @sql;
		set @Saved = 1;
	end;
end;
GO

