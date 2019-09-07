use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[SR_Add]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[SR_Add]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[SR_Add]
	@SubmittedByID int,
	@SRTypeID int,
	@PriorityID int,
	@Description nvarchar(max),
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output
as
begin
	set nocount on;

	declare @SubmittedStatusID int;

	select @SubmittedStatusID = s.STATUSID
	from [STATUS] s
	join StatusType st
	on s.StatusTypeID = st.StatusTypeID
	where s.[STATUS] = 'Submitted'
	and st.StatusType = 'SR';

	begin try
		

		insert into SR(SubmittedByID, STATUSID, SRTypeID, PRIORITYID, [Description], CreatedBy, UpdatedBy)
		values(@SubmittedByID, @SubmittedStatusID, @SRTypeID, @PriorityID, @Description, @UpdatedBy, @UpdatedBy);
	
		select @NewID = scope_identity();

		set @Saved = 1;
	end try
	begin catch
				
	end catch;
end;
