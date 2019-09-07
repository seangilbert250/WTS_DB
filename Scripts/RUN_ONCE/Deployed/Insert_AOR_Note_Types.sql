use [WTS]
go

insert into AORNoteType(AORNoteTypeName, [Description], Sort)
select a.AORNoteTypeName, a.[Description], a.Sort from (
	select 'Objectives' as AORNoteTypeName, 'Objectives' as [Description], 1 as Sort
	union all
	select 'Burndown Overview' as AORNoteTypeName, 'Burndown Overview' as [Description], 2 as Sort
	union all
	select 'Action Items' as AORNoteTypeName, 'Action Items' as [Description], 3 as Sort
	union all
	select 'Stopping Conditions' as AORNoteTypeName, 'Stopping Conditions' as [Description], 4 as Sort
	union all
	select 'Questions/Discussion Points' as AORNoteTypeName, 'Questions/Discussion Points' as [Description], 5 as Sort
	union all
	select 'Notes' as AORNoteTypeName, 'Notes' as [Description], 6 as Sort
) a;