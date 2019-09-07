use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[WTS_Contract_System_Cleanup]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[WTS_Contract_System_Cleanup]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[WTS_Contract_System_Cleanup]
	@saved int output
as
begin
	set nocount on;

	declare @date datetime;
	declare @count int = 0;
	declare @WTS_SYSTEMID int;

	set @saved = 0;
	set @date = getdate();

	declare curSystems cursor for
	select distinct WTS_SYSTEMID
	from WTS_SYSTEM_CONTRACT;

	open curSystems

	fetch next from curSystems
	into @WTS_SYSTEMID

	while @@fetch_status = 0
	begin
		select @count = count(1)
		from WTS_SYSTEM_CONTRACT
		where WTS_SYSTEMID = @WTS_SYSTEMID
		and [Primary] = 1;

		if @count > 1
			begin
				update WTS_SYSTEM_CONTRACT
				set [Primary] = 0
				where WTS_SYSTEMID = @WTS_SYSTEMID;
			end;

		select @count = count(1)
		from WTS_SYSTEM_CONTRACT
		where WTS_SYSTEMID = @WTS_SYSTEMID
		and [Primary] = 1;

		if @count = 0
			begin
				update WTS_SYSTEM_CONTRACT
				set [Primary] = 1,
					UpdatedBy = 'WTS',
					UpdatedDate = @date
				where WTS_SYSTEMID = @WTS_SYSTEMID
				and CONTRACTID = (
					select CONTRACTID
					from (
						select CONTRACTID,
							row_number() over(partition by WTS_SYSTEMID order by UpdatedDate desc) as rn
						from WTS_SYSTEM_CONTRACT
						where WTS_SYSTEMID = @WTS_SYSTEMID
					) as a
					where a.rn = 1
				);
			end;

		fetch next from curSystems
		into @WTS_SYSTEMID
	end;
	close curSystems
	deallocate curSystems;

	set @saved = 1;
end;
