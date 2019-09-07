use WTS
go

--select a.*from PRIORITY a
--inner join PRIORITYTYPE pt
--on a.PRIORITYTYPEID = pt.PRIORITYTYPEID
--and pt.PRIORITYTYPE = 'AOR Estimation'

update PRIORITY
set PRIORITY = 'Low (Routine)'
where PRIORITY = 'Low'
and PRIORITYTYPEID = (
select PRIORITYTYPEID
from PRIORITYTYPE
where PRIORITYTYPE = 'AOR Estimation'
)
;

update PRIORITY
set PRIORITY = 'Moderate (Acceptable)'
where PRIORITY = 'Moderate'
and PRIORITYTYPEID = (
select PRIORITYTYPEID
from PRIORITYTYPE
where PRIORITYTYPE = 'AOR Estimation'
)
;

update PRIORITY
set PRIORITY = 'High (Emergency)'
where PRIORITY = 'High'
and PRIORITYTYPEID = (
select PRIORITYTYPEID
from PRIORITYTYPE
where PRIORITYTYPE = 'AOR Estimation'
)
;

go
