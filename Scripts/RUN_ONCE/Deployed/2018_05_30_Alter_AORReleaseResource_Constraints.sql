use wts
go

alter table AORReleaseResource
drop constraint UK_AORReleaseResource;

alter table AORReleaseResource
add constraint [UK_AORReleaseResource] unique([AORReleaseID], [WTS_RESOURCEID], [AORRoleID]);