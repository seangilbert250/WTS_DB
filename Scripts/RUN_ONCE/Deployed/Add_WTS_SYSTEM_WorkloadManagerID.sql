use wts
go

alter table WTS_SYSTEM add BusWorkloadManagerID int null;
go

alter table WTS_SYSTEM add DevWorkloadManagerID int null;
go

alter table WTS_SYSTEM add constraint [FK_WTS_SYSTEM_WTS_RESOURCE_BUS] foreign key ([BusWorkloadManagerID]) references [WTS_RESOURCE]([WTS_RESOURCEID]);
go

alter table WTS_SYSTEM add constraint [FK_WTS_SYSTEM_WTS_RESOURCE_DEV] foreign key ([DevWorkloadManagerID]) references [WTS_RESOURCE]([WTS_RESOURCEID]);
go

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'KRISTIN.WALKER')
where upper(WTS_SYSTEM) = 'NCII ACC GIO';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'DAVID.COULTER')
where upper(WTS_SYSTEM) = 'WSS CAFDEX';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'SEAN.WALKER')
where upper(WTS_SYSTEM) = 'OPERATIONS(CONTRACT, TRAINING, B&D)';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'ERWIN.TORRES')
where upper(WTS_SYSTEM) = 'NCII IS3/MSDIS';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'DOREEN.HARRIS')
where upper(WTS_SYSTEM) = 'FHP FFPM';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'DOREEN.HARRIS')
where upper(WTS_SYSTEM) = 'FHP FHPM';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'CAMBRIDGE.DORMAN')
where upper(WTS_SYSTEM) = 'WSS FRM';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'DOREEN.HARRIS')
where upper(WTS_SYSTEM) = 'FHP FTPM';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'DAVID.COULTER')
where upper(WTS_SYSTEM) = 'WSS AMR';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'DOREEN.HARRIS')
where upper(WTS_SYSTEM) = 'FHP CAFDEX';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'DAVID.COULTER')
where upper(WTS_SYSTEM) = 'RSEP CAFDEX';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'JOSEPH.PORUBSKY')
where upper(WTS_SYSTEM) = 'CAFDOX';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'DAVID.COULTER')
where upper(WTS_SYSTEM) = 'RSEP CESR';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'DAVID.COULTER')
where upper(WTS_SYSTEM) = 'WSS DPEM';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'DAVID.COULTER')
where upper(WTS_SYSTEM) = 'RSEP PMMA';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'KRISTOPHER.MCKINLEY')
where upper(WTS_SYSTEM) = 'WSS WSA-PBO';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'DAVID.COULTER')
where upper(WTS_SYSTEM) = 'WSS WSMS';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'SEAN.WALKER')
where upper(WTS_SYSTEM) = 'WTS';

update WTS_SYSTEM
set BusWorkloadManagerID = (select WTS_RESOURCEID from WTS_RESOURCE where upper(USERNAME) = 'KRISTOPHER.MCKINLEY')
where upper(WTS_SYSTEM) = 'RSEP UID';
