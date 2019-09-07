USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AOR_Update]    Script Date: 8/2/2018 9:01:25 AM ******/
DROP PROCEDURE [dbo].[AOR_Update]
GO

/****** Object:  StoredProcedure [dbo].[AOR_Update]    Script Date: 8/2/2018 9:01:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE procedure [dbo].[AOR_Update]
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
		tbl.updates.value('typeName[1]', 'varchar(10)') as fieldType,
			tbl.updates.value('typeID[1]', 'varchar(10)') as fieldTypeID,
			tbl.updates.value('field[1]', 'varchar(100)') as fieldName,
			tbl.updates.value('value[1]', 'varchar(MAX)') as fieldValue
		from @Changes.nodes('changes/update') as tbl(updates)
	)
	select @sql = stuff((select ' ' + [dbo].[Get_Updates](fieldTypeID, 0, fieldName, fieldValue, fieldType, null, @UpdatedBy) from w_changes for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');
	
	if @sql != ''
		begin
			execute sp_executesql @sql;
			set @Saved = 1;
		end;
end;

GO


