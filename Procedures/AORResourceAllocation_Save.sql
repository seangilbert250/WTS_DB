USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORResourceAllocation_Save]    Script Date: 8/2/2018 9:04:23 AM ******/
DROP PROCEDURE [dbo].[AORResourceAllocation_Save]
GO

/****** Object:  StoredProcedure [dbo].[AORResourceAllocation_Save]    Script Date: 8/2/2018 9:04:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




create procedure [dbo].[AORResourceAllocation_Save]
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
			tbl.updates.value('aorreleaseresourceid[1]', 'int') as AORReleaseResourceID,
			tbl.updates.value('field[1]', 'varchar(100)') as fieldName,
			tbl.updates.value('value[1]', 'varchar(100)') as fieldValue
		from @Changes.nodes('changes/update') as tbl([updates])
	)
	select @sql = stuff((select ' ' + [dbo].[Get_Updates](AORReleaseResourceID, 0, fieldName, fieldValue, 'AOR RELEASE RESOURCE', null, @UpdatedBy) from w_changes for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');
	
	if @sql != ''
		begin
			execute sp_executesql @sql;
			set @Saved = 1;
		end;
end;

SELECT 'Executing File [Functions\AOR_Get_Columns.sql]';
GO


