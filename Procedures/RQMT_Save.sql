USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_Save]    Script Date: 10/12/2018 9:30:36 AM ******/
DROP PROCEDURE [dbo].[RQMT_Save]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_Save]    Script Date: 10/12/2018 9:30:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








CREATE procedure [dbo].[RQMT_Save]
	@NewRQMT bit,
	@RQMTID int,
	@RQMT nvarchar(MAX),
	@Universal bit = 0,
	@UniversalCategories nvarchar(1000) = NULL,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output,
	@NewIDs nvarchar(500) = '' output
as
begin
	set nocount on;

	declare @date datetime;
	declare @count int;

	set @date = getdate();

	if @NewRQMT = 1
		begin
			-- for new rqmts, we allow multiple additions at once
			if charindex('|', @RQMT, 1) > 0
			begin
				set @NewIDs = ''

				select *, 0 as Processed into #rqmttmp from dbo.Split(@RQMT, '|')

				while exists (select 1 from #rqmttmp where Processed = 0)
				begin					
					declare @nextRQMT nvarchar(max) = (select top 1 Data from #rqmttmp where Processed = 0)

					declare @nextRQMTTrimmed nvarchar(500) = @nextRQMT
					if (len(@nextRQMTTrimmed) > 500) set @nextRQMTTrimmed = substring(@nextRQMTTrimmed, 0, 500)
					
					set @nextRQMTTrimmed = rtrim(ltrim(@nextRQMTTrimmed))
					if (substring(@nextRQMTTrimmed, 1, 1) = '>')
					begin
						set @nextRQMTTrimmed = ltrim(substring(@nextRQMTTrimmed, 2, len(@nextRQMTTrimmed) - 1))
					end
					
					declare @nextCount int = (select count(*) from RQMT where RQMT = @nextRQMTTrimmed);

					if isnull(@nextCount, 0) > 0
						begin
							set @Exists = 1;
							
							if @NewIDs <> '' SET @NewIDs = @NewIds + ','
							set @NewIDs = @NewIDs + convert(nvarchar, (select top 1 RQMTID from RQMT where RQMT = @nextRQMTTrimmed))
						end;
					else
						begin try
							insert into RQMT(RQMT, CreatedBy, UpdatedBy)
							values(@nextRQMTTrimmed, @UpdatedBy, @UpdatedBy);

							if @NewIDs <> '' SET @NewIDs = @NewIds + ','	
							declare @nextNewID int = scope_identity()
							set @NewIDs = @NewIDs + convert(nvarchar, @nextNewID);

							exec dbo.AuditLog_Save @nextNewID, NULL, 1, 1, 'RQMTID', NULL, 'RQMT CREATED', @date, @UpdatedBy
							exec dbo.AuditLog_Save @nextNewID, NULL, 1, 1, 'RQMT', NULL, @nextRQMTTrimmed, @date, @UpdatedBy

							set @Saved = 1;
						end try
						begin catch
				
						end catch;

					update #rqmttmp set Processed = 1 where Data = @nextRQMT
				end

				drop table #rqmttmp
			end
			else -- INSERTING JUST ONE RQMT
			begin
				set @RQMT = rtrim(ltrim(@RQMT))
				if (substring(@RQMT, 1, 1) = '>')
				begin
					set @RQMT = ltrim(substring(@RQMT, 2, len(@RQMT) - 1))
				end

				select @count = count(*) from RQMT where RQMT = @RQMT;

				if isnull(@count, 0) > 0
					begin
						set @Exists = 1;
						set @NewID = (select top 1 RQMTID from RQMT where RQMT = @RQMT)
						return;
					end;

				begin try
					if (len(@RQMT) > 500) set @RQMT = substring(@RQMT, 0, 500)

					insert into RQMT(RQMT, CreatedBy, UpdatedBy, Universal)
					values(@RQMT, @UpdatedBy, @UpdatedBy, @Universal);					
	
					set @NewID = scope_identity();

					exec dbo.AuditLog_Save @NewID, NULL, 1, 1, 'RQMTID', NULL, 'RQMT CREATED', @date, @UpdatedBy
					exec dbo.AuditLog_Save @NewID, NULL, 1, 1, 'RQMT', NULL, @RQMT, @date, @UpdatedBy

					set @Saved = 1;
				end try
				begin catch
				
				end catch;
			end
		end;
	else if @RQMTID > 0
		begin
			select @count = count(*) from RQMT where RQMT = @RQMT and RQMTID != @RQMTID;

			if isnull(@count, 0) > 0
				begin
					set @Exists = 1;
					return;
				end;

			declare @RQMT_OLD NVARCHAR(500) = (SELECT RQMT FROM RQMT WHERE RQMTID = @RQMTID)

			update RQMT
			set RQMT = @RQMT,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date
			where RQMTID = @RQMTID;

			set @Saved = 1;

			exec dbo.AuditLog_Save @RQMTID, NULL, 1, 5, 'RQMT', @RQMT_OLD, @RQMT, @date, @UpdatedBy
		end;
end;
GO


