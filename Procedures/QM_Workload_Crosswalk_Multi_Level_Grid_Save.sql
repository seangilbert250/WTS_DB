USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[QM_Workload_Crosswalk_Multi_Level_Grid_Save]    Script Date: 8/2/2018 9:04:49 AM ******/
DROP PROCEDURE [dbo].[QM_Workload_Crosswalk_Multi_Level_Grid_Save]
GO

/****** Object:  StoredProcedure [dbo].[QM_Workload_Crosswalk_Multi_Level_Grid_Save]    Script Date: 8/2/2018 9:04:49 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[QM_Workload_Crosswalk_Multi_Level_Grid_Save]
	@Changes xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @sql nvarchar(max) = '';

	with
	w_changes as (
		select
			tbl.updates.value('workitemid[1]', 'varchar(10)') as workItemID,
			tbl.updates.value('blnsubtask[1]', 'varchar(10)') as blnSubTask,
			tbl.updates.value('field[1]', 'varchar(100)') as fieldName,
			tbl.updates.value('value[1]', 'varchar(100)') as fieldValue
		from @Changes.nodes('changes/update') as tbl(updates)
	)
	select @sql = stuff((select ' ' + [dbo].[Get_Updates](workItemID, blnSubTask, fieldName, fieldValue, 'Crosswalk', null, @UpdatedBy) from w_changes for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');
	
	if @sql != ''
	set @sql = 
		' begin
		declare @Old_StatusID int;
		declare @SRNumber int;
		declare @AssignedToRankID int;
		declare @BusinessRank int;
		declare @Cascade int;
		declare @field1 int;
		declare @CurAORRelease varchar(max) = null;
		' + @sql + '
		end;'
		
		begin
			execute sp_executesql @sql;
			set @Saved = 1;
		end;
end;
GO


