use [WTS]
go

insert into WTS_SYSTEM_SUITE_RESOURCE(WTS_SYSTEM_SUITEID, ProductVersionID, WTS_RESOURCEID, ARCHIVE, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
select distinct wss.WTS_SYSTEM_SUITEID,
	wsr.ProductVersionID,
	wsr.WTS_RESOURCEID,
	0,
	min(wsr.CreatedBy),
	min(wsr.CreatedDate),
	max(wsr.UpdatedBy),
	max(wsr.UpdatedDate)
from WTS_SYSTEM_RESOURCE wsr
join WTS_SYSTEM ws
on wsr.WTS_SYSTEMID = ws.WTS_SYSTEMID
join WTS_SYSTEM_SUITE wss
on ws.WTS_SYSTEM_SUITEID = wss.WTS_SYSTEM_SUITEID
group by wss.WTS_SYSTEM_SUITEID,
	wsr.ProductVersionID,
	wsr.WTS_RESOURCEID
