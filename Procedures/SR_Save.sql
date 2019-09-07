use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[SR_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[SR_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[SR_Save]
	@NewSR bit,
	@SRID int,
	@StatusID int,
	@SRTypeID int,
	@PriorityID int,
	@INVPriorityID int = 0,
	@SRRankID int = 0,
	@Description nvarchar(max),
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output
as
begin
	set nocount on;

	declare @updatedByID int;
	declare @date datetime;
	declare @count int;
	declare @sort int = 0;

	select @updatedByID = WTS_RESOURCEID
	from WTS_RESOURCE
	where upper(USERNAME) = upper(@UpdatedBy);

	set @date = getdate();

	if @NewSR = 1
		begin
			/*select @count = count(*) from SR where [Description] = @Description;

			if isnull(@count, 0) > 0
				begin
					set @Exists = 1;
					return;
				end;*/

			begin try
				insert into SR(SubmittedByID, STATUSID, SRTypeID, PRIORITYID, [Description], CreatedBy, UpdatedBy)
				values(@updatedByID, @StatusID, @SRTypeID, @PriorityID, @Description, @UpdatedBy, @UpdatedBy);
	
				select @NewID = scope_identity();

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @SRID > 0
		begin
			/*select @count = count(*) from SR where [Description] = @Description and SRID != @SRID;

			if isnull(@count, 0) > 0
				begin
					set @Exists = 1;
					return;
				end;*/
			update SR
			set STATUSID =	CASE @StatusID
								WHEN 125 THEN STATUSID
								ELSE @StatusID
							END,
				SRTypeID = @SRTypeID,
				PRIORITYID = @PriorityID,
				INVPriorityID = @INVPriorityID,
				SRRankID =  CASE @SRRankID
								WHEN 44 THEN SRRankID
								ELSE @SRRankID
							END,
				[Description] = @Description,
				Closed = CASE 
							WHEN (@StatusID = 125 or @SRRankID = 44) and Closed = 0 THEN 1
							WHEN @StatusID = 125 and @SRRankID = 44 THEN 1
							ELSE 0
						 END,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where SRID = @SRID;

			set @Saved = 1;
		end;
end;
