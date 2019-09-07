use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORMeetingInstanceAuto_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORMeetingInstanceAuto_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORMeetingInstanceAuto_Save]
as
begin
	set nocount on;

	declare @date datetime;
	declare @AORMeetingID int;
	declare @AORMeetingInstanceID int;
	declare @AORMeetingInstanceID_Last int;

	set @date = getdate();

	begin try
		update AORMeetingInstance
		set Locked = 1
		where Locked = 0
		and InstanceDate < getdate();
	end try
	begin catch

	end catch;

	begin try
		create table #AutoAORMeetingInstance(AORMeetingID int, AORMeetingInstanceID int);

		insert into AORMeetingInstance(AORMeetingID, AORMeetingInstanceName, InstanceDate)
		output inserted.AORMeetingID,
			inserted.AORMeetingInstanceID
		into #AutoAORMeetingInstance
		select a.AORMeetingID, a.AORMeetingInstanceName, a.AddMeeting
		from (
			select ami.AORMeetingID,
				ami.AORMeetingInstanceName,
				max(ami.InstanceDate) as LastMeeting,
				case when afr.AORFrequencyName = 'Daily' then dateadd(dd, 1, max(ami.InstanceDate))
					when afr.AORFrequencyName = 'Weekly' then dateadd(wk, 1, max(ami.InstanceDate)) end as AddMeeting
			from AORMeetingInstance ami
			join AORMeeting aom
			on ami.AORMeetingID = aom.AORMeetingID
			join AORFrequency afr
			on aom.AORFrequencyID = afr.AORFrequencyID
			where afr.AORFrequencyName in ('Daily', 'Weekly')
			and aom.AutoCreateMeetings = 1
			and ami.InstanceDate < @date
			and ami.InstanceDate > case when afr.AORFrequencyName = 'Daily' then dateadd(dd, -1, @date)
				when afr.AORFrequencyName = 'Weekly' then dateadd(wk, -1, @date) end
			group by ami.AORMeetingID,
				ami.AORMeetingInstanceName,
				afr.AORFrequencyName
		) a
		where not exists (
			select 1
			from AORMeetingInstance
			where AORMeetingID = a.AORMeetingID
			and InstanceDate > a.LastMeeting
			and InstanceDate <= a.AddMeeting
		);

		declare cur cursor for
		select AORMeetingID,
			AORMeetingInstanceID
		from #AutoAORMeetingInstance;

		open cur

		fetch next from cur
		into @AORMeetingID,
			@AORMeetingInstanceID

		while @@fetch_status = 0
		begin
			select @AORMeetingInstanceID_Last = max(ami.AORMeetingInstanceID)
			from AORMeetingInstance ami
			where ami.AORMeetingID = @AORMeetingID
			and ami.InstanceDate = (
				select max(ami2.InstanceDate)
				from AORMeetingInstance ami2
				where ami2.AORMeetingID = @AORMeetingID
				and ami2.InstanceDate < (select InstanceDate from AORMeetingInstance where AORMeetingInstanceID = @AORMeetingInstanceID)
			);

			exec AORMeetingInstance_Copy @AORMeetingID, @AORMeetingInstanceID_Last, @AORMeetingInstanceID;

			fetch next from cur
			into @AORMeetingID,
				@AORMeetingInstanceID
		end;
		close cur
		deallocate cur;

		if object_id('tempdb..#AutoAORMeetingInstance') is not null
			begin
				drop table #AutoAORMeetingInstance;
			end;
	end try
	begin catch
		if object_id('tempdb..#AutoAORMeetingInstance') is not null
			begin
				drop table #AutoAORMeetingInstance;
			end;
	end catch;
end;
