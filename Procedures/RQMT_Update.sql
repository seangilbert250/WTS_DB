USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_Update]    Script Date: 8/2/2018 9:47:59 AM ******/
DROP PROCEDURE [dbo].[RQMT_Update]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_Update]    Script Date: 8/2/2018 9:47:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[RQMT_Update]
	@Changes xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Output nvarchar(max) = null output
as
begin
	set nocount on;

	declare @sql nvarchar(max) = '';

	with
	w_changes as (
		select
		tbl.updates.value('typeName[1]', 'varchar(50)') as fieldType,
			tbl.updates.value('typeID[1]', 'varchar(10)') as fieldTypeID,
			tbl.updates.value('field[1]', 'varchar(100)') as fieldName,
			tbl.updates.value('value[1]', 'varchar(MAX)') as fieldValue,
			tbl.updates.value('rqmtid[1]', 'varchar(10)') as rqmtID,
			tbl.updates.value('systemid[1]', 'varchar(10)') as systemID,
			tbl.updates.value('workareaid[1]', 'varchar(10)') as workareaID,
			tbl.updates.value('rqmttypeid[1]', 'varchar(10)') as rqmttypeID,
			tbl.updates.value('rsetid[1]', 'varchar(10)') as rsetID
		from @Changes.nodes('changes/update') as tbl(updates)
	)
	select @sql = stuff((select ' ' + 
		[dbo].[Get_Updates](
			fieldTypeID, 0, fieldName, fieldValue, fieldType, 
			convert(nvarchar, rqmtID) +',' + convert(nvarchar, systemID) + ',' + convert(nvarchar, workareaID) + ',' + convert(nvarchar, rqmttypeID) + ',' + convert(nvarchar, rsetID), 
			@UpdatedBy) 
		from w_changes for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');
	
	--set @Output = @sql

	if @sql != ''
		begin
			execute sp_executesql @sql;
			set @Saved = 1;
		end;
end;

GO


