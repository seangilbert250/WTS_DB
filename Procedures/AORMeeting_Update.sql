USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMeeting_Update]    Script Date: 8/2/2018 9:03:25 AM ******/
DROP PROCEDURE [dbo].[AORMeeting_Update]
GO

/****** Object:  StoredProcedure [dbo].[AORMeeting_Update]    Script Date: 8/2/2018 9:03:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



create procedure [dbo].[AORMeeting_Update]
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
			tbl.updates.value('aormeetingid[1]', 'varchar(10)') as AORMeeting_ID,
			tbl.updates.value('field[1]', 'varchar(100)') as fieldName,
			tbl.updates.value('value[1]', 'varchar(100)') as fieldValue
		from @Changes.nodes('changes/update') as tbl(updates)
	)
	select @sql = stuff((select ' ' + [dbo].[Get_Updates](AORMeeting_ID, 0, fieldName, fieldValue, 'AOR Meeting', null, @UpdatedBy) from w_changes for xml path(''), type).value('.', 'nvarchar(max)'), 1, 1, '');
	
	if @sql != ''
		begin
			execute sp_executesql @sql;
			set @Saved = 1;
		end;
end;

SELECT 'Executing File [Procedures\AORMeetingInstance_Update.sql]';
GO


