use [WTS]
go

declare @myvalue nvarchar(max) = '{"sectionorder":["1","2","3"],"sectionexpanded":{"chkRelease":true,"chkResources":true,"chkHistory":true},"gridname":"AOR","viewname":"Default","tblCols":[{"name":"AOR #","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"AOR Name","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Description","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Sort","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Carry In","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"CMMI","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Critical Path Team","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Last Meeting","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Next Meeting","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"# of Meetings","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Rank","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Stage Priority","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Tier","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Investigation Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Technical Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Customer Design Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Coding Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Internal Testing Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Customer Validation Testing Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Adoption Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"CR ITI POC","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"SR #","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"SR Submitted By","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"SR Submitted Date","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"SR Keywords","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"SR Websystem","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"SR Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"SR Type","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"SR Priority","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"SR ITI","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"SR ITI POC","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"SR Description","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"Release","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"CSD Required Now","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"Related Release","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"Design Review","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"Customer Priority List","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"Government CSRD #","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"LCMB","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"Last Reply","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"SR"},{"name":"Affiliated","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Assigned To","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Functionality","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Organization (Assigned To)","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Percent Complete","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Priority","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Product Version","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Production Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Submitted By","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Work Area","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Resources","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Coding Estimated Effort","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Testing Estimated Effort","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Training/Support Estimated Effort","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Cyber Review","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Primary System","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"AOR System","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Approved","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Approved By","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Approved Date","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Rationale","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"Customer Impact","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"ITI Priority","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"Cyber/ISMT","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"Primary SR","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"Contract","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"Work Activity","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Primary Resource","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"System(Task)","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Resource Group","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Bus Workload Manager","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Dev Workload Manager","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Workload Priority","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Any"},{"name":"Resource Count (T.BA.PA.CT)","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Any"},{"name":"Carry In/Out Count","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Any"},{"name":"AOR Type","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Visible To Customer","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"IP1 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"IP2 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"IP3 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"Workload Type","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"AOR"},{"name":"CR Customer Title","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"CR Internal Title","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"CR Description","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"CR"},{"name":"Customer Rank","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Assigned To Rank","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Scheduled Deliverable","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"System Suite","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Parent Work Task","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Parent Title","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Work Task","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"},{"name":"Title","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false,"colgroup":"Work Task"}],"columnorder":["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53","54","55","56","57","58","59","60","61","62","63","64","65","66","67","68","69","70","71","72","73","74","75","76","77","78","79","80","81","82","83","84","85","86","87","88","89","90","91","92","93"],"showcolumnheader":true,"columngroups":["Any","AOR","CR","SR","Work Task"],"validated":"2018-03-27T10:21:29.517375-07:00","QFContract":"13,16,1,8,5,6,2,19","QFRelease":"38,40","QFAORType":"0,2,1","QFVisibleToCustomer":"1,0","QFTaskStatus":"80,72,1,2,3,4,5,7,8,9,11,12,13,15","QFAORProductionStatus":"0,76,108,75,78,77"}'

update GridView set Tier1Columns = @myvalue where ViewName = 'Default' and gridViewID = 285