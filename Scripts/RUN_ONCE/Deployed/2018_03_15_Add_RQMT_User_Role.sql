use [WTS]
go

--provide RQMT role
insert into aspnet_UsersInRoles(UserId, RoleId)
select a.UserId, b.RoleId
from aspnet_Users a,
	aspnet_Roles b
where upper(a.UserName) in ('NICK.BAILEY', 'ERIC.JONSSON', 'MICHAEL.JACOBS', 'MATT.BELCHER', 'DANIEL.BRANDES')
and b.RoleName in ('RQMT', 'View:RQMT')
except
select UserId, RoleId
from aspnet_UsersInRoles;
go