use [WTS]
go

alter table WORKITEMTYPE
add WorkActivityGroup nvarchar(255) null;
go

update WORKITEMTYPE
set WorkActivityGroup = 'Business Development'
where WORKITEMTYPEID in (104,105,106,107);

update WORKITEMTYPE
set WorkActivityGroup = 'Cyber'
where WORKITEMTYPEID in (95,96,97,98,99,100,101,102,103);

update WORKITEMTYPE
set WorkActivityGroup = 'Training'
where WORKITEMTYPEID in (108,109,110,111,112,113);

update WORKITEMTYPE
set WorkActivityGroup = 'Production/Other'
where WORKITEMTYPEID in (54,55,56,57,58,59,60,62,22);

