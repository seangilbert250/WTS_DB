use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[RQMTDescription_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[RQMTDescription_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[RQMTDescription_Save]
	@RQMTDescriptionTypeID int,
	@RQMTDescription nvarchar(max),
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output
as
begin
	set nocount on;

	declare @count int;

	select @count = count(*)
	from RQMTDescription
	where RQMTDescriptionTypeID = @RQMTDescriptionTypeID
	and RQMTDescription = @RQMTDescription;

	if isnull(@count, 0) > 0
		begin
			set @Exists = 1;
			return;
		end;

	begin try
		insert into RQMTDescription(RQMTDescriptionTypeID, RQMTDescription, CreatedBy, UpdatedBy)
		values(@RQMTDescriptionTypeID, @RQMTDescription, @UpdatedBy, @UpdatedBy);
	
		select @NewID = scope_identity();

		set @Saved = 1;
	end try
	begin catch
				
	end catch;
end;
