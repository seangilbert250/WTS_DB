use [WTS]
go

update wac
set wac.WorkActivityGroup = pdp.PDDTDR_PHASE,
	UPDATEDBY = 'WTS',
	UPDATEDDATE = getdate()
from WORKITEMTYPE wac
join PDDTDR_PHASE pdp
on wac.PDDTDR_PHASEID = pdp.PDDTDR_PHASEID;
