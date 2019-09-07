USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[SR_Update]    Script Date: 8/2/2018 9:05:40 AM ******/
DROP PROCEDURE [dbo].[SR_Update]
GO

/****** Object:  StoredProcedure [dbo].[SR_Update]    Script Date: 8/2/2018 9:05:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[SR_Update]
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
		tbl.updates.value('typeName[1]', 'varchar(50)') as fieldType,
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

SELECT 'Executing File [Procedures\WTS_System_ResourceAlt_Save.sql]';
GO


