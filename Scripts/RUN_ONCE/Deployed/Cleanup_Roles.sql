use wts
go

--remove non-admin users from admin roles
delete from aspnet_UsersInRoles
where exists (
	select 1
	from aspnet_Users a
	join aspnet_UsersInRoles b
	on a.UserId = b.UserId
	join aspnet_Roles c
	on b.RoleId = c.RoleId
	where a.UserName not in ('David.Navarro', 'Derik.Harris', 'Eric.Jonsson', 'Nick.Bailey', 'Sean.Walker')
	and c.RoleName like '%Admin%'
	and aspnet_UsersInRoles.UserId = b.UserId
	and aspnet_UsersInRoles.RoleId = b.RoleId
);

--remove all from cr roles
delete from aspnet_UsersInRoles
where exists (
	select 1
	from aspnet_Users a
	join aspnet_UsersInRoles b
	on a.UserId = b.UserId
	join aspnet_Roles c
	on b.RoleId = c.RoleId
	where c.RoleName like '%CR%'
	and aspnet_UsersInRoles.UserId = b.UserId
	and aspnet_UsersInRoles.RoleId = b.RoleId
);

--provide aor roles
insert into aspnet_UsersInRoles(UserId, RoleId)
select a.UserId, b.RoleId
from aspnet_Users a,
	aspnet_Roles b
where upper(a.UserName) in ('SEAN.WALKER', 'DAVID.ALLISON', 'CHERYL.GLAZER', 'JOSEPH.PORUBSKY', 'CAMBRIDGE.DORMAN', 'DERIK.HARRIS', 'NICK.BAILEY', 'ERIC.JONSSON', 'DAVID.NAVARRO')
and b.RoleName = 'AOR'
except
select UserId, RoleId
from aspnet_UsersInRoles;

insert into aspnet_UsersInRoles(UserId, RoleId)
select a.UserId, b.RoleId
from aspnet_Users a,
	aspnet_Roles b
where upper(a.UserName) in ('SEAN.WALKER', 'JOSEPH.PORUBSKY', 'NICK.BAILEY', 'ERIN.MENDOZA', 'CAMBRIDGE.DORMAN', 'DERIK.HARRIS', 'KRISTIN.WALKER', 'OSCAR.LOERA', 'DAVID.NAVARRO', 'CHERYL.GLAZER', 'ERIC.JONSSON', 'SHEILA.GLINSKI', 'DOUG.KNOX', 'TANYA.CARDOZO', 'DAVID.ALLISON', 'HANNAH.WALDEN', 'ANDY.TAYLOR', 'SHAHIR.ARIF')
and b.RoleName = 'View:AOR'
except
select UserId, RoleId
from aspnet_UsersInRoles;

--provide meeting roles
insert into aspnet_UsersInRoles(UserId, RoleId)
select a.UserId, b.RoleId
from aspnet_Users a,
	aspnet_Roles b
where upper(a.UserName) in ('SEAN.WALKER', 'JOSEPH.PORUBSKY', 'NICK.BAILEY', 'ERIN.MENDOZA', 'CAMBRIDGE.DORMAN', 'DERIK.HARRIS', 'KRISTIN.WALKER', 'OSCAR.LOERA', 'DAVID.NAVARRO', 'CHERYL.GLAZER', 'ERIC.JONSSON', 'SHEILA.GLINSKI', 'DOUG.KNOX', 'TANYA.CARDOZO', 'DAVID.ALLISON', 'HANNAH.WALDEN', 'ANDY.TAYLOR', 'SHAHIR.ARIF')
and b.RoleName in ('Meeting', 'View:Meeting')
except
select UserId, RoleId
from aspnet_UsersInRoles;

--provide cr roles
insert into aspnet_UsersInRoles(UserId, RoleId)
select a.UserId, b.RoleId
from aspnet_Users a,
	aspnet_Roles b
where upper(a.UserName) in ('SEAN.WALKER', 'JOSEPH.PORUBSKY', 'NICK.BAILEY', 'ERIN.MENDOZA', 'CAMBRIDGE.DORMAN', 'DERIK.HARRIS', 'KRISTIN.WALKER', 'OSCAR.LOERA', 'DAVID.NAVARRO', 'CHERYL.GLAZER', 'ERIC.JONSSON', 'SHEILA.GLINSKI', 'DOUG.KNOX', 'TANYA.CARDOZO', 'DAVID.ALLISON', 'HANNAH.WALDEN', 'ANDY.TAYLOR', 'SHAHIR.ARIF')
and b.RoleName in ('CR', 'View:CR')
except
select UserId, RoleId
from aspnet_UsersInRoles;