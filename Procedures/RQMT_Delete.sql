USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_Delete]    Script Date: 8/16/2018 11:50:41 AM ******/
DROP PROCEDURE [dbo].[RQMT_Delete]
GO

/****** Object:  StoredProcedure [dbo].[RQMT_Delete]    Script Date: 8/16/2018 11:50:41 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE procedure [dbo].[RQMT_Delete]
	@RQMTID int,
	@Exists int = 0 OUTPUT,
	@HasDependencies int = 0 OUTPUT,
	@Deleted bit = 0 OUTPUT,
	@IgnoreDependencies bit = 0,
	@UpdatedBy NVARCHAR(255)
as
begin
	declare @now datetime = getdate()

	select @Exists = count(*) from RQMT where RQMTID = @RQMTID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	-- we can ignore dependencies for the rqmtsystem, but not if it has been added to a set
	if exists (select 1 from RQMTSet_RQMTSystem rsrs join RQMTSystem rs on (rsrs.RQMTSystemID = rs.RQMTSystemID) join RQMT r on (r.RQMTID = rs.RQMTID) where r.RQMTID = @RQMTID)
	begin
		set @HasDependencies = 1
		return
	end

	-- if @IgnoreDependencies is true, we can delete a rqmt and the rqmtsystem dependencies
	if (
			exists(select 1 from RQMTSystem rs join RQMTSystemDefect rsd on (rs.RQMTSystemID = rsd.RQMTSystemID) where rs.RQMTID = @RQMTID)
				or
			exists(select 1 from RQMTSystem rs join RQMTSystemRevision rsr on (rs.RQMTSystemID = rsr.RQMTSystemID) where rs.RQMTID = @RQMTID)
				or
			exists(select 1 from RQMTSystem rs join RQMTSystemRQMTDescription rsrd on (rs.RQMTSystemID = rsrd.RQMTSystemID) where rs.RQMTID = @RQMTID)
		)
	begin		
		if @IgnoreDependencies = 0
		begin
			set @HasDependencies = 1
			return
		end
	end

	begin try
		delete from RQMTSystemRevision
		where exists (
			select 1
			from RQMTSystem rs
			where rs.RQMTSystemID = RQMTSystemRevision.RQMTSystemID
			and rs.RQMTID = @RQMTID
		);

		delete from RQMTSystemDefect
		where exists (
			select 1
			from RQMTSystem rs
			where rs.RQMTSystemID = RQMTSystemDefect.RQMTSystemID
			and rs.RQMTID = @RQMTID
		);

		delete from RQMTSystemRQMTDescription
		where exists (
			select 1
			from RQMTSystem rs
			where rs.RQMTSystemID = RQMTSystemRQMTDescription.RQMTSystemID
			and rs.RQMTID = @RQMTID
		);

		delete from RQMTSystem
		where RQMTID = @RQMTID;

		delete from RQMT
		where RQMTID = @RQMTID;

		exec dbo.AuditLog_Save @RQMTID, NULL, 1, 6, 'RQMTID', NULL, 'RQMT DELETED', @now, @UpdatedBy

		set @Deleted = 1;
	end try
	begin catch
select dbo.GetErrorInfo()		
	end catch;
end;

SELECT 'Executing File [Functions\RQMT_Get_Tables.sql]';
GO


