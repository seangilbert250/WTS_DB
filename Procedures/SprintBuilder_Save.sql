USE [WTS]
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[SprintBuilder_Save]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [SprintBuilder_Save]
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[SprintBuilder_Save]
	@SprintBuilder xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @date datetime;
	set @date = getdate();

	begin
		begin try
			if @SprintBuilder.exist('sprint/save') > 0
				begin
					with
					w_sprint as (
						select distinct
							tbl.[save].value('TASKID[1]', 'int') as TASKID,
							tbl.[save].value('SUBTASKID[1]', 'int') as SUBTASKID,
							tbl.[save].value('WORKITEMID[1]', 'int') as WORKITEMID,
							tbl.[save].value('WORKITEM_TASKID[1]', 'int') as WORKITEM_TASKID,
							tbl.[save].value('WORKMGMTID[1]', 'int') as WORKMGMTID,
							tbl.[save].value('JUSTIFICATION[1]', 'nvarchar(max)') as JUSTIFICATION
						from @SprintBuilder.nodes('sprint/save') as tbl([save])
					)
					select TASKID,
						   SUBTASKID,
					       WORKITEMID,
						   WORKITEM_TASKID,
						   WORKMGMTID,
						   JUSTIFICATION
					into #sprintTemp
					from w_sprint
				end;

				
				DECLARE @TASKID int
				DECLARE @SUBTASKID int
				DECLARE @WORKITEMID int
				DECLARE @WORKITEM_TASKID int
				DECLARE @WORKMGMTID int
				DECLARE @JUSTIFICATION nvarchar(max)
				DECLARE @COUNT int
				DECLARE @oldWorkloadAOR nvarchar(255)
				DECLARE @newWorkloadAOR nvarchar(255)
				DECLARE @cascadeAOR bit
				DECLARE @oldAORReleaseID int

				DECLARE cur CURSOR FOR SELECT TASKID, SUBTASKID, WORKITEMID, WORKITEM_TASKID, WORKMGMTID, JUSTIFICATION FROM #sprintTemp
				OPEN cur

					FETCH NEXT FROM cur INTO @TASKID, @SUBTASKID, @WORKITEMID, @WORKITEM_TASKID, @WORKMGMTID, @JUSTIFICATION

					WHILE @@FETCH_STATUS = 0 BEGIN
						IF @SUBTASKID = -1
							begin
								select @oldWorkloadAOR = ar.AORName,
									@cascadeAOR = art.CascadeAOR,
									@oldAORReleaseID = art.AORReleaseID
								from AORRelease ar
								join AORReleaseTask art
								on ar.AORReleaseID = art.AORReleaseID
								where art.AORReleaseTaskID = @TASKID
								;

								select @newWorkloadAOR = ar.AORName
								from AORRelease ar
								where AORReleaseID = @WORKMGMTID
								;

								exec WorkItem_History_Add
								@ITEM_UPDATETYPEID = 5,
								@WORKITEMID = @WORKITEMID,
								@FieldChanged = 'Workload MGMT AOR',
								@OldValue = @oldWorkloadAOR,
								@NewValue = @newWorkloadAOR,
								@CreatedBy = @UpdatedBy,
								@newID = null;

								delete from AORReleaseTask where AORReleaseTaskID = @TASKID;

								insert into AORReleaseTask(AORReleaseID, WORKITEMID, Justification, CascadeAOR)
								values(@WORKMGMTID, @WORKITEMID, @JUSTIFICATION, @cascadeAOR);

								if @cascadeAOR = 1
									begin
										delete from AORReleaseSubTask
										where AORReleaseID = @oldAORReleaseID
										and exists (
											select 1
											from AORReleaseSubTask rst
											join WORKITEM_TASK wit
											on rst.WORKITEMTASKID = wit.WORKITEM_TASKID
											where rst.WORKITEMTASKID = AORReleaseSubTask.WORKITEMTASKID
											and wit.WORKITEMID = @WORKITEMID
										);

										insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, CreatedBy, UpdatedBy)
										select @WORKMGMTID,
											WORKITEM_TASKID,
											@UpdatedBy,
											@UpdatedBy
										from WORKITEM_TASK wit
										where wit.WORKITEMID = @WORKITEMID
										and not exists (
											select 1
											from AORReleaseSubTask ast
											where ast.AORReleaseID = @WORKMGMTID
											and ast.WORKITEMTASKID = wit.WORKITEM_TASKID
										)
										;
									end;
							end
						ELSE
							begin
								select @oldWorkloadAOR = ar.AORName
								from AORRelease ar
								join AORReleaseSubTask art
								on ar.AORReleaseID = art.AORReleaseID
								where art.AORReleaseSubTaskID = @SUBTASKID
								;

								select @newWorkloadAOR = ar.AORName
								from AORRelease ar
								where ar.AORReleaseID = @WORKMGMTID
								;

								exec WorkItem_Task_History_Add
								@ITEM_UPDATETYPEID = 5,
								@WORKITEM_TASKID = @SubTaskID,
								@FieldChanged = 'Workload MGMT AOR',
								@OldValue = @oldWorkloadAOR,
								@NewValue = @newWorkloadAOR,
								@CreatedBy = @UpdatedBy,
								@newID = null;

								delete from AORReleaseSubTask where AORReleaseSubTaskID = @SUBTASKID;

								insert into AORReleaseSubTask(AORReleaseID, WORKITEMTASKID, Justification)
								values(@WORKMGMTID, @WORKITEM_TASKID, @JUSTIFICATION);
							end
						FETCH NEXT FROM cur INTO @TASKID, @SUBTASKID, @WORKITEMID, @WORKITEM_TASKID, @WORKMGMTID, @JUSTIFICATION
					END

				CLOSE cur;
				DEALLOCATE cur;

				DROP TABLE #sprintTemp;

			set @Saved = 1;
		end try
		begin catch
				
		end catch;
	end;
	
end;

SELECT 'Executing File [Procedures\AORMeetingInstanceList_Get.sql]';
GO


