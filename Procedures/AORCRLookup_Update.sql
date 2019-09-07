USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORCRLookup_Update]    Script Date: 8/2/2018 9:02:14 AM ******/
DROP PROCEDURE [dbo].[AORCRLookup_Update]
GO

/****** Object:  StoredProcedure [dbo].[AORCRLookup_Update]    Script Date: 8/2/2018 9:02:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[AORCRLookup_Update]
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
			tbl.updates.value('crid[1]', 'varchar(10)') as CR_ID,
			tbl.updates.value('field[1]', 'varchar(100)') as fieldName,
			tbl.updates.value('value[1]', 'varchar(100)') as fieldValue
		from @Changes.nodes('changes/update') as tbl(updates)
	)
	select @sql = stuff((select ' ' + [dbo].[Get_Updates](CR_ID, 0, fieldName, fieldValue, 'CR', null, @UpdatedBy) from w_changes for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');
	
	if @sql != ''
		begin
			execute sp_executesql @sql;
			set @Saved = 1;
		end;
end;

SELECT 'Executing File [Procedures\SR_Update.sql]';
GO


