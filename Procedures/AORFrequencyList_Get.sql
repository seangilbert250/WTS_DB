use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORFrequencyList_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORFrequencyList_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORFrequencyList_Get]
as
begin
	select AORFrequencyID as AORFrequency_ID,
		AORFrequencyName as Frequency
	from AORFrequency
	order by Sort, upper(AORFrequencyName);
end;
