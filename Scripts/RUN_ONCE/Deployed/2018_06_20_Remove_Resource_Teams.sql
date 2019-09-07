use [WTS]
go

delete AORReleaseResourceTeam;

delete i
from WORKITEM_SUBSCRIBER i
join WTS_RESOURCE wre
on i.WTS_RESOURCEID = wre.WTS_RESOURCEID
where wre.AORResourceTeam = 1;

delete WTS_RESOURCE
where AORResourceTeam = 1;
