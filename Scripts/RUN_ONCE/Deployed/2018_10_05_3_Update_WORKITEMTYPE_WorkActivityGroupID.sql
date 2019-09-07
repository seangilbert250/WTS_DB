use [WTS]
go

update WORKITEMTYPE
set WorkActivityGroupID = wag.WorkActivityGroupID
from WorkActivityGroup wag
where wag.WorkActivityGroup = WORKITEMTYPE.WorkActivityGroup