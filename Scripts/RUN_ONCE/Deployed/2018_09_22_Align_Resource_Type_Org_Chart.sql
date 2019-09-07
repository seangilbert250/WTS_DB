use [WTS]
go

declare @date datetime = getdate();

update WTS_RESOURCE_TYPE
set WTS_RESOURCE_TYPE = 'DEV',
	[DESCRIPTION] = 'DEV'
where WTS_RESOURCE_TYPEID = 2;

update WTS_RESOURCE_TYPE
set WTS_RESOURCE_TYPE = 'Program MGMT Cyber',
	[DESCRIPTION] = 'Program MGMT Cyber'
where WTS_RESOURCE_TYPEID = 3;

update WTS_RESOURCE
set WTS_RESOURCE_TYPEID = null
where WTS_RESOURCE_TYPEID > 4;

delete from WorkActivity_WTS_RESOURCE_TYPE
where WTS_RESOURCE_TYPEID > 4;

delete from WTS_RESOURCE_TYPE
where WTS_RESOURCE_TYPEID > 4;

insert into WTS_RESOURCE_TYPE (WTS_RESOURCE_TYPE, [DESCRIPTION], SORT_ORDER, ARCHIVE, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
select a.WTS_RESOURCE_TYPE,
	a.WTS_RESOURCE_TYPE,
	a.SORT_ORDER,
	0,
	'WTS',
	@date,
	'WTS',
	@date
from (
	select 'AMC GIO Geospatial Developer' as WTS_RESOURCE_TYPE, 5 as SORT_ORDER union all
	select 'AMC GIO GIS Web Developer' as WTS_RESOURCE_TYPE, 6 as SORT_ORDER union all
	select 'AMC GIO Sys Admin' as WTS_RESOURCE_TYPE, 7 as SORT_ORDER union all
	select 'AMC GIO System Administration' as WTS_RESOURCE_TYPE, 8 as SORT_ORDER union all
	select 'App Arch SME Prog MGMT' as WTS_RESOURCE_TYPE, 9 as SORT_ORDER union all
	select 'App Config SME Prog MGMT' as WTS_RESOURCE_TYPE, 10 as SORT_ORDER union all
	select 'BA ANG' as WTS_RESOURCE_TYPE, 11 as SORT_ORDER union all
	select 'Consultant ANG' as WTS_RESOURCE_TYPE, 12 as SORT_ORDER union all
	select 'Consultant CAM App Config' as WTS_RESOURCE_TYPE, 13 as SORT_ORDER union all
	select 'Contract Manager' as WTS_RESOURCE_TYPE, 14 as SORT_ORDER union all
	select 'Customer Relations SME Prog MGMT' as WTS_RESOURCE_TYPE, 15 as SORT_ORDER union all
	select 'Executive Assistant' as WTS_RESOURCE_TYPE, 16 as SORT_ORDER union all
	select 'IS3 Help Desk' as WTS_RESOURCE_TYPE, 17 as SORT_ORDER union all
	select 'IS3 Server Admin' as WTS_RESOURCE_TYPE, 18 as SORT_ORDER union all
	select 'Prog MGMT ANG/CAM App Config' as WTS_RESOURCE_TYPE, 19 as SORT_ORDER union all
	select 'Prog MGMT Recruit, Train' as WTS_RESOURCE_TYPE, 20 as SORT_ORDER union all
	select 'Prog MGMT Special Projects' as WTS_RESOURCE_TYPE, 21 as SORT_ORDER union all
	select 'Senior App Arch' as WTS_RESOURCE_TYPE, 22 as SORT_ORDER union all
	select 'Senior Consultant' as WTS_RESOURCE_TYPE, 23 as SORT_ORDER union all
	select 'Senior Consultant Cyber' as WTS_RESOURCE_TYPE, 24 as SORT_ORDER union all
	select 'SME App Arch' as WTS_RESOURCE_TYPE, 25 as SORT_ORDER union all
	select 'Sr Consultant ANG' as WTS_RESOURCE_TYPE, 26 as SORT_ORDER union all
	select 'Sr. BA' as WTS_RESOURCE_TYPE, 27 as SORT_ORDER union all
	select 'Sr. DEV' as WTS_RESOURCE_TYPE, 28 as SORT_ORDER union all
	select 'Sr. Lead App Arch' as WTS_RESOURCE_TYPE, 29 as SORT_ORDER union all
	select 'Sr. Lead BA' as WTS_RESOURCE_TYPE, 30 as SORT_ORDER union all
	select 'Sr. Lead Training Prog MGMT' as WTS_RESOURCE_TYPE, 31 as SORT_ORDER union all
	select 'Sr. Prog MGMT Operations' as WTS_RESOURCE_TYPE, 32 as SORT_ORDER union all
	select 'Sr. Prog MGMT Special Projects' as WTS_RESOURCE_TYPE, 33 as SORT_ORDER union all
	select 'Sr. Prog MGMT Special Projects AMC GIO' as WTS_RESOURCE_TYPE, 34 as SORT_ORDER union all
	select 'Sr. Systems Analyst' as WTS_RESOURCE_TYPE, 35 as SORT_ORDER union all
	select 'Sr. Tech Arch Oracle DBA' as WTS_RESOURCE_TYPE, 36 as SORT_ORDER union all
	select 'Systems Analyst' as WTS_RESOURCE_TYPE, 37 as SORT_ORDER union all
	select 'Tech Arch SME Prog MGMT' as WTS_RESOURCE_TYPE, 38 as SORT_ORDER
) a;

select a.WTS_RESOURCEID,
	b.WTS_RESOURCE_TYPEID
into #ResourceTypeMapping
from WTS_RESOURCE a
cross join WTS_RESOURCE_TYPE b
where (
	case when lower(a.USERNAME) = 'kelsey.swanson' and b.WTS_RESOURCE_TYPE = 'AMC GIO Geospatial Developer' then 1
	when lower(a.USERNAME) = 'christina.mccullough' and b.WTS_RESOURCE_TYPE = 'AMC GIO GIS Web Developer' then 1
	when lower(a.USERNAME) = 'chris.rohloff' and b.WTS_RESOURCE_TYPE = 'AMC GIO Sys Admin' then 1
	when lower(a.USERNAME) = 'heather.nemeth' and b.WTS_RESOURCE_TYPE = 'AMC GIO System Administration' then 1
	when lower(a.USERNAME) = 'erin.mendoza' and b.WTS_RESOURCE_TYPE = 'App Arch SME Prog MGMT' then 1
	when lower(a.USERNAME) = 'doreen.harris' and b.WTS_RESOURCE_TYPE = 'App Config SME Prog MGMT' then 1
	when lower(a.USERNAME) = 'david.coulter' and b.WTS_RESOURCE_TYPE = 'App Config SME Prog MGMT' then 1
	when lower(a.USERNAME) = 'shahir.arif' and b.WTS_RESOURCE_TYPE = 'BA' then 1
	when lower(a.USERNAME) = 'isabelle.nelson' and b.WTS_RESOURCE_TYPE = 'BA' then 1
	when lower(a.USERNAME) = 'maliha.aneel' and b.WTS_RESOURCE_TYPE = 'BA' then 1
	when lower(a.USERNAME) = 'aire.cobb' and b.WTS_RESOURCE_TYPE = 'BA' then 1
	when lower(a.USERNAME) = 'bobbie.sasser' and b.WTS_RESOURCE_TYPE = 'BA' then 1
	when lower(a.USERNAME) = 'oscar.loera' and b.WTS_RESOURCE_TYPE = 'BA ANG' then 1
	when lower(a.USERNAME) = 'hannah.walden' and b.WTS_RESOURCE_TYPE = 'BA ANG' then 1
	when lower(a.USERNAME) = 'scott.sneddon' and b.WTS_RESOURCE_TYPE = 'BA ANG' then 1
	when lower(a.USERNAME) = 'david.stewart' and b.WTS_RESOURCE_TYPE = 'Consultant ANG' then 1
	when lower(a.USERNAME) = 'anna.knapp' and b.WTS_RESOURCE_TYPE = 'Consultant CAM App Config' then 1
	when lower(a.USERNAME) = 'greg.jones' and b.WTS_RESOURCE_TYPE = 'Contract Manager' then 1
	when lower(a.USERNAME) = 'erwin.torres' and b.WTS_RESOURCE_TYPE = 'Customer Relations SME Prog MGMT' then 1
	when lower(a.USERNAME) = 'mark.woolsey' and b.WTS_RESOURCE_TYPE = 'DEV' then 1
	when lower(a.USERNAME) = 'kevin.smith' and b.WTS_RESOURCE_TYPE = 'DEV' then 1
	when lower(a.USERNAME) = 'daniel.brandes' and b.WTS_RESOURCE_TYPE = 'DEV' then 1
	when lower(a.USERNAME) = 'bradley.singer' and b.WTS_RESOURCE_TYPE = 'DEV' then 1
	when lower(a.USERNAME) = 'matt.belcher' and b.WTS_RESOURCE_TYPE = 'DEV' then 1
	when lower(a.USERNAME) = 'anthony.doan' and b.WTS_RESOURCE_TYPE = 'DEV' then 1
	when lower(a.USERNAME) = 'jeff.button' and b.WTS_RESOURCE_TYPE = 'DEV' then 1
	when lower(a.USERNAME) = 'roman.pshichenko' and b.WTS_RESOURCE_TYPE = 'DEV' then 1
	when lower(a.USERNAME) = 'kandy.ho' and b.WTS_RESOURCE_TYPE = 'DEV' then 1
	when lower(a.USERNAME) = 'tanya.cardozo' and b.WTS_RESOURCE_TYPE = 'Executive Assistant' then 1
	when lower(a.USERNAME) = 'julie.williams' and b.WTS_RESOURCE_TYPE = 'IS3 Help Desk' then 1
	when lower(a.USERNAME) = 'quinton.rice' and b.WTS_RESOURCE_TYPE = 'IS3 Server Admin' then 1
	when lower(a.USERNAME) = 'aaron.martinez' and b.WTS_RESOURCE_TYPE = 'IS3 Server Admin' then 1
	when lower(a.USERNAME) = 'cambridge.dorman' and b.WTS_RESOURCE_TYPE = 'Prog MGMT ANG/CAM App Config' then 1
	when lower(a.USERNAME) = 'louanne.dukes' and b.WTS_RESOURCE_TYPE = 'Prog MGMT Recruit, Train' then 1
	when lower(a.USERNAME) = 'kristopher.mckinley' and b.WTS_RESOURCE_TYPE = 'Prog MGMT Special Projects' then 1
	when lower(a.USERNAME) = 'terrence.manning' and b.WTS_RESOURCE_TYPE = 'Program MGMT Cyber' then 1
	when lower(a.USERNAME) = 'eric.jonsson' and b.WTS_RESOURCE_TYPE = 'Senior App Arch' then 1
	when lower(a.USERNAME) = 'eric.gervais' and b.WTS_RESOURCE_TYPE = 'Senior Consultant' then 1
	when lower(a.USERNAME) = 'marissa.almstrom' and b.WTS_RESOURCE_TYPE = 'Senior Consultant Cyber' then 1
	when lower(a.USERNAME) = 'wendy.kellogg' and b.WTS_RESOURCE_TYPE = 'SME App Arch' then 1
	when lower(a.USERNAME) = 'nick.bailey' and b.WTS_RESOURCE_TYPE = 'SME App Arch' then 1
	when lower(a.USERNAME) = 'esel.ramos' and b.WTS_RESOURCE_TYPE = 'SME App Arch' then 1
	when lower(a.USERNAME) = 'dennis.dillon' and b.WTS_RESOURCE_TYPE = 'Sr Consultant ANG' then 1
	when lower(a.USERNAME) = 'casey.daniels' and b.WTS_RESOURCE_TYPE = 'Sr. BA' then 1
	when lower(a.USERNAME) = 'nichole.waddell' and b.WTS_RESOURCE_TYPE = 'Sr. BA' then 1
	when lower(a.USERNAME) = 'myanh.nguyen' and b.WTS_RESOURCE_TYPE = 'Sr. DEV' then 1
	when lower(a.USERNAME) = 'don.whitecar' and b.WTS_RESOURCE_TYPE = 'Sr. DEV' then 1
	when lower(a.USERNAME) = 'don.petersen' and b.WTS_RESOURCE_TYPE = 'Sr. DEV' then 1
	when lower(a.USERNAME) = 'kristopher.tadlock' and b.WTS_RESOURCE_TYPE = 'Sr. DEV' then 1
	when lower(a.USERNAME) = 'odette.pumares' and b.WTS_RESOURCE_TYPE = 'Sr. DEV' then 1
	when lower(a.USERNAME) = 'brian.duby' and b.WTS_RESOURCE_TYPE = 'Sr. DEV' then 1
	when lower(a.USERNAME) = 'teresa.manadan' and b.WTS_RESOURCE_TYPE = 'Sr. DEV' then 1
	when lower(a.USERNAME) = 'michael.jacobs' and b.WTS_RESOURCE_TYPE = 'Sr. DEV' then 1
	when lower(a.USERNAME) = 'david.evans' and b.WTS_RESOURCE_TYPE = 'Sr. DEV' then 1
	when lower(a.USERNAME) = 'selva.sebastian' and b.WTS_RESOURCE_TYPE = 'Sr. DEV' then 1
	when lower(a.USERNAME) = 'bryan.arnett' and b.WTS_RESOURCE_TYPE = 'Sr. Lead App Arch' then 1
	when lower(a.USERNAME) = 'taylor.watanabe' and b.WTS_RESOURCE_TYPE = 'Sr. Lead App Arch' then 1
	when lower(a.USERNAME) = 'tanyetta.white' and b.WTS_RESOURCE_TYPE = 'Sr. Lead BA' then 1
	when lower(a.USERNAME) = 'cheryl.glazer' and b.WTS_RESOURCE_TYPE = 'Sr. Lead BA' then 1
	when lower(a.USERNAME) = 'mike.stewart' and b.WTS_RESOURCE_TYPE = 'Sr. Lead BA' then 1
	when lower(a.USERNAME) = 'joseph.porubsky' and b.WTS_RESOURCE_TYPE = 'Sr. Lead BA' then 1
	when lower(a.USERNAME) = 'andy.taylor' and b.WTS_RESOURCE_TYPE = 'Sr. Lead Training Prog MGMT' then 1
	when lower(a.USERNAME) = 'dan.gilbert' and b.WTS_RESOURCE_TYPE = 'Sr. Prog MGMT Operations' then 1
	when lower(a.USERNAME) = 'kristin.walker' and b.WTS_RESOURCE_TYPE = 'Sr. Prog MGMT Special Projects' then 1
	when lower(a.USERNAME) = 'paul.friedrich' and b.WTS_RESOURCE_TYPE = 'Sr. Prog MGMT Special Projects AMC GIO' then 1
	when lower(a.USERNAME) = 'david.allison' and b.WTS_RESOURCE_TYPE = 'Sr. Systems Analyst' then 1
	when lower(a.USERNAME) = 'jene''t.taylor' and b.WTS_RESOURCE_TYPE = 'Sr. Systems Analyst' then 1
	when lower(a.USERNAME) = 'courtenay.thomas' and b.WTS_RESOURCE_TYPE = 'Sr. Tech Arch Oracle DBA' then 1
	when lower(a.USERNAME) = 'marcel.brandy' and b.WTS_RESOURCE_TYPE = 'Systems Analyst' then 1
	when lower(a.USERNAME) = 'monique.parker' and b.WTS_RESOURCE_TYPE = 'Systems Analyst' then 1
	when lower(a.USERNAME) = 'derik.harris' and b.WTS_RESOURCE_TYPE = 'Tech Arch SME Prog MGMT' then 1
	else 0 end
) = 1;

update res
set WTS_RESOURCE_TYPEID = rtm.WTS_RESOURCE_TYPEID,
	UPDATEDBY = 'WTS',
	UPDATEDDATE = @date
from WTS_RESOURCE res
join #ResourceTypeMapping rtm
on res.WTS_RESOURCEID = rtm.WTS_RESOURCEID;

drop table #ResourceTypeMapping;

go
