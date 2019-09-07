use [WTS]
go

alter table AORRelease
add AORName nvarchar(150) null;
go

alter table AORRelease
add Notes nvarchar(MAX) null;
go

alter table AORRelease
add Description varchar(MAX) null;
go
