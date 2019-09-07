use [WTS]
go

update WORKITEMTYPE
set PDDTDR_PHASEID = null,
	SORT_ORDER = SORT_ORDER + 1
where WORKITEMTYPE = 'Software Dev - Planning' or SORT_ORDER > 25;
