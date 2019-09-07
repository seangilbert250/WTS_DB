USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_ResourceAlt_Save]    Script Date: 8/2/2018 9:06:23 AM ******/
DROP PROCEDURE [dbo].[WTS_System_ResourceAlt_Save]
GO

/****** Object:  StoredProcedure [dbo].[WTS_System_ResourceAlt_Save]    Script Date: 8/2/2018 9:06:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[WTS_System_ResourceAlt_Save]
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
			tbl.updates.value('systemresourceid[1]', 'int') as WTS_SYSTEM_RESOURCEID,
			tbl.updates.value('field[1]', 'varchar(100)') as fieldName,
			tbl.updates.value('value[1]', 'varchar(100)') as fieldValue
		from @Changes.nodes('changes/update') as tbl([updates])
	)
	select @sql = stuff((select ' ' + [dbo].[Get_Updates](WTS_SYSTEM_RESOURCEID, 0, fieldName, fieldValue, 'System Resource', null, @UpdatedBy) from w_changes for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');
	
	if @sql != ''
		begin
			execute sp_executesql @sql;
			set @Saved = 1;
		end;
end;

SELECT 'Executing File [Functions\AOR_Get_Columns.sql]';
GO


