use [WTS]
go

insert into WorkActivityGroup(WorkActivityGroup, Description, Archive)
select distinct wit.WorkActivityGroup, wit.WorkActivityGroup, 0
from WORKITEMTYPE wit

ALTER TABLE WORKITEMTYPE
  ADD WorkActivityGroupID int null;
