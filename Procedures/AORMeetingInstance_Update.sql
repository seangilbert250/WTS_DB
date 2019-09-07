USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_Update]    Script Date: 8/2/2018 9:03:52 AM ******/
DROP PROCEDURE [dbo].[AORMeetingInstance_Update]
GO

/****** Object:  StoredProcedure [dbo].[AORMeetingInstance_Update]    Script Date: 8/2/2018 9:03:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[AORMeetingInstance_Update]
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
			tbl.updates.value('aormeetinginstanceid[1]', 'varchar(10)') as AORMeetingInstance_ID,
			tbl.updates.value('field[1]', 'varchar(100)') as fieldName,
			tbl.updates.value('value[1]', 'varchar(100)') as fieldValue
		from @Changes.nodes('changes/update') as tbl(updates)
	)
	select @sql = stuff((select ' ' + [dbo].[Get_Updates](AORMeetingInstance_ID, 0, fieldName, fieldValue, 'AOR Meeting Instance', null, @UpdatedBy) from w_changes for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');
	
	if @sql != ''
		begin
			execute sp_executesql @sql;
			set @Saved = 1;
		end;
end;

SELECT 'Executing File [Procedures\AORCRLookup_Update.sql]';
GO


