INSERT INTO GridName (GridName) VALUES ('AOR');  -- New ID: 11
INSERT INTO GridName (GridName) VALUES ('AOR_Meeting');  -- New ID: 12

alter table gridview
alter column tier1columns nvarchar(max) null

INSERT INTO GridView (GridNameId, ViewName, SORT_ORDER, Archive, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE, Tier1Columns, ViewDescription)
VALUES (11, 'Default', 0, 0, 'WTS_ADMIN', GETDATE(), 'WTS_ADMIN', GETDATE(), '{"sectionorder":["1","2","3"],"sectionexpanded":{"chkRelease":false,"chkResources":false,"chkHistory":false},"gridname":"AOR","viewname":"Default","tblCols":[{"name":"AOR #","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"AOR Name","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Description","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Sort","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Carry In","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CMMI","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Critical Path Team","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Current Release","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Cyber","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Cyber Risk","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Estimated Effort","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Last Meeting","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Next Meeting","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"# of Meetings","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Customer Flagship","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Rank","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Stage Priority","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Tier","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Work Type","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Investigation Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Technical Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Customer Design Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Coding Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Internal Testing Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Customer Validation Testing Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Adoption Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"IP1 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"IP2 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"IP3 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Name","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Title","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Notes","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Websystem","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR CSD Required Now","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Related Release","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Sub Group","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Design Review","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR ITI POC","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Customer Priority List","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Government CSRD #","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR #","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Submitted By","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Submitted Date","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Keywords","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Websystem","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Type","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Priority","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR LCMB","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR ITI","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR ITI POC","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Description","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Last Reply","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false}],"columnorder":["30","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53"],"showcolumnheader":false,"subgrid3":[{"tblCols":[{"name":"AOR #","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"AOR Name","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Description","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Sort","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Carry In","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CMMI","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Critical Path Team","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Current Release","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Cyber","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Cyber Risk","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Estimated Effort","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Last Meeting","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Next Meeting","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"# of Meetings","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Customer Flagship","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Rank","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Stage Priority","alias":"Priority","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Tier","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Work Type","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Investigation Status","alias":"Inv","show":true,"sortorder":"none","sortpriority":"","groupname":"Status","concat":false},{"name":"Technical Status","alias":"TD","show":true,"sortorder":"none","sortpriority":"","groupname":"Status","concat":false},{"name":"Customer Design Status","alias":"CD","show":true,"sortorder":"none","sortpriority":"","groupname":"Status","concat":false},{"name":"Coding Status","alias":"C","show":true,"sortorder":"none","sortpriority":"","groupname":"Status","concat":false},{"name":"Internal Testing Status","alias":"IT","show":true,"sortorder":"none","sortpriority":"","groupname":"Status","concat":false},{"name":"Customer Validation Testing Status","alias":"CVT","show":true,"sortorder":"none","sortpriority":"","groupname":"Status","concat":false},{"name":"Adoption Status","alias":"Adopt","show":true,"sortorder":"none","sortpriority":"","groupname":"Status","concat":false},{"name":"IP1 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"IP2 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"IP3 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Name","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Title","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Notes","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Websystem","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR CSD Required Now","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Related Release","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Sub Group","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Design Review","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR ITI POC","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Customer Priority List","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Government CSRD #","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR #","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Submitted By","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Submitted Date","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Keywords","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Websystem","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Type","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Priority","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR LCMB","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR ITI","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR ITI POC","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Description","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Last Reply","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false}],"columnorder":["2","1","3","4","17","20","21","22","23","24","25","26","12","13","10","6","5","7","8","9","11","14","15","16","18","19","27","28","29","30","31","32","33","34","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53"],"showcolumnheader":true}],"subgrid4":[{"tblCols":[{"name":"AOR #","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"AOR Name","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Description","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Sort","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Carry In","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CMMI","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Critical Path Team","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Current Release","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Cyber","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Cyber Risk","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Estimated Effort","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Last Meeting","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Next Meeting","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"# of Meetings","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Customer Flagship","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Rank","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Stage Priority","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Tier","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Work Type","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Investigation Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Technical Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Customer Design Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Coding Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Internal Testing Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Customer Validation Testing Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Adoption Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"IP1 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"IP2 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"IP3 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Name","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Title","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Notes","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Websystem","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR CSD Required Now","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Related Release","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Sub Group","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Design Review","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR ITI POC","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Customer Priority List","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Government CSRD #","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR #","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Submitted By","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Submitted Date","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Keywords","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Websystem","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Status","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Type","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Priority","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR LCMB","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR ITI","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR ITI POC","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Description","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Last Reply","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false}],"columnorder":["41","42","43","44","45","46","47","48","49","50","51","52","53","1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32","33","34","35","36","37","38","39","40"],"showcolumnheader":true}]}', 'User preference for AOR page');

INSERT INTO GridView (GridNameId, ViewName, SORT_ORDER, Archive, CREATEDBY, CREATEDDATE, UPDATEDBY, UPDATEDDATE, Tier1Columns, ViewDescription)
VALUES (11, 'AOR Only', 0, 0, 'WTS_ADMIN', GETDATE(), 'WTS_ADMIN', GETDATE(), '{"sectionorder":["1","2","3"],"sectionexpanded":{"chkRelease":false,"chkResources":false,"chkHistory":false},"gridname":"AOR","viewname":"AOR Only","tblCols":[{"name":"AOR #","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"AOR Name","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Description","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Sort","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Carry In","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CMMI","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Critical Path Team","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Current Release","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Cyber","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Cyber Risk","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Estimated Effort","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Last Meeting","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Next Meeting","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"# of Meetings","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Customer Flagship","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Rank","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Stage Priority","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Tier","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Work Type","alias":"","show":true,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Investigation Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Technical Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Customer Design Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Coding Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Internal Testing Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Customer Validation Testing Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"Adoption Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"IP1 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"IP2 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"IP3 Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Name","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Title","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Notes","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Websystem","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR CSD Required Now","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Related Release","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Sub Group","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Design Review","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR ITI POC","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Customer Priority List","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"CR Government CSRD #","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR #","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Submitted By","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Submitted Date","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Keywords","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Websystem","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Status","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Type","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Priority","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR LCMB","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR ITI","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR ITI POC","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Description","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false},{"name":"SR Last Reply","alias":"","show":false,"sortorder":"none","sortpriority":"","groupname":"","concat":false}],"columnorder":["1","2","3","4","11","17","8","16","12","13","14","6","9","10","7","19","15","18","30","31","32","33","34","5","20","21","22","23","24","25","26","27","28","29","35","36","37","38","39","40","41","42","43","44","45","46","47","48","49","50","51","52","53"],"showcolumnheader":true}', 'User preference for AOR page');

-- ALTER PROCEDURE [dbo].[GridViewList_Get]
-- add the following fields to the select statement.
-- , gv.Tier1Columns
-- , gv.DefaultSelection

-- Also change sproc GridView_Add and GridView_Update by setting the property / field @Tier1Columns nvarchar(1000) = null to @Tier1Columns nvarchar(max) = null
-- Deploy changes to app files; default.aspx, aor_edit.*, AOR_Grid.*, itisettings.*, popup.master, sortables.css, WTSCommon.cs

ALTER PROCEDURE [dbo].[GridViewList_Get]
	@WTS_ResourceID int = null
	, @GridName nvarchar(50) = null
AS
BEGIN
	--Default Views
	SELECT
		gv.GridViewID
		, gv.WTS_RESOURCEID
		, wr.FIRST_NAME + ' ' + wr.LAST_NAME AS Resource_Name
		, gv.GridNameID
		, gv.ViewName
		, gv.ViewDescription
		, gn.GridName
		, gn.[Description]
		, CASE WHEN UPPER(gv.ViewName) = 'DEFAULT' THEN -1 ELSE gv.SORT_ORDER END AS SORT_ORDER
		, gv.Tier1Columns
		, gv.DefaultSelection
		, gv.Tier1RollupGroup
		, gv.Tier1ColumnOrder
		, gv.Tier2ColumnOrder
		, gv.Tier2SortOrder

		, gv.SectionsXML

		, CASE WHEN gv.WTS_RESOURCEID = @WTS_ResourceID OR wrc.WTS_RESOURCEID = @WTS_ResourceID THEN 1 ELSE 0 END AS MyView
	FROM
		GridView gv
			JOIN GridName gn ON gv.GridNameID = gn.GridNameID
			LEFT JOIN WTS_RESOURCE wr ON gv.WTS_RESOURCEID = wr.WTS_RESOURCEID
			LEFT JOIN WTS_RESOURCE wrc ON UPPER(gv.CREATEDBY) = UPPER(wrc.USERNAME)
	WHERE
		(ISNULL(@GridName,'') = '' OR UPPER(gn.GridName) = UPPER(@GridName))
		AND (ISNULL(gv.WTS_RESOURCEID,0) = 0 OR gv.WTS_RESOURCEID = @WTS_ResourceID)
	ORDER BY gv.WTS_RESOURCEID, SORT_ORDER ASC, gv.ViewName ASC
	;

END;

ALTER PROCEDURE [dbo].[GridView_Add]
	@GridNameID int,
	@ViewName nvarchar(50),
	@SessionID nvarchar(100) = null,
	@WTS_ResourceID int = null,
	@DefaultSelection bit = 1,
	@Tier1Columns nvarchar(max) = null,
	@Tier1ColumnOrder nvarchar(max) = null,
	@Tier1SortOrder nvarchar(1000) = null,
	@Tier1RollupGroup nvarchar(50) = null,
	@Tier2Columns nvarchar(1000) = null,
	@Tier2ColumnOrder nvarchar(max) = null,
	@Tier2SortOrder nvarchar(1000) = null,
	@Tier2RollupGroup nvarchar(50) = null,
	@Tier3Columns nvarchar(1000) = null,
	@Tier3ColumnOrder nvarchar(max) = null,
	@Tier3SortOrder nvarchar(1000) = null,
	@Sort_Order int = null,

	@SectionsXML xml = null,

	@CreatedBy nvarchar(255) = 'WTS_ADMIN',
	@newID int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @exists int = 0;
	SET @newID = 0;

	IF @SessionID IS NULL AND @WTS_ResourceID IS NOT NULL
		BEGIN
			SELECT @exists = COUNT(*) FROM GridView 
			WHERE 
				GridNameID = @GridNameID
				AND UPPER(ViewName) = UPPER(@ViewName)
				AND WTS_RESOURCEID = @WTS_ResourceID;

			IF ISNULL(@exists,0) > 0
				RETURN;
		END;

	SELECT @exists = COUNT(*) FROM GridView 
	WHERE 
		GridNameID = @GridNameID
		AND ViewName = @ViewName
		AND WTS_RESOURCEID = @WTS_ResourceID
		AND SessionID = @SessionID;

	IF ISNULL(@WTS_ResourceID, 0) > 0 AND ISNULL(@SessionID,'') != '' AND ISNULL(@exists,0) > 0
		BEGIN
			DELETE FROM GridView
			WHERE
				GridNameID = @GridNameID
				AND ViewName = @ViewName
				AND WTS_RESOURCEID = @WTS_ResourceID
				AND SessionID = @SessionID;
		END;
		
	INSERT INTO GridView(
		GridNameID
		, WTS_RESOURCEID
		, SessionID
		, ViewName
		, Tier1Columns
		, Tier1ColumnOrder
		, Tier1SortOrder
		, Tier1RollupGroup
		, Tier2Columns
		, Tier2ColumnOrder
		, Tier2SortOrder
		, Tier2RollupGroup
		, Tier3Columns
		, Tier3ColumnOrder
		, Tier3SortOrder
		, DefaultSelection
		, SORT_ORDER
		, SectionsXML
		, Archive
		, CREATEDBY
		, CREATEDDATE
		, UPDATEDBY
		, UPDATEDDATE
	)
	VALUES(
		@GridNameID
		, @WTS_ResourceID
		, @SessionID
		, @ViewName
		, @Tier1Columns
		, @Tier1ColumnOrder
		, @Tier1SortOrder
		, @Tier1RollupGroup
		, @Tier2Columns
		, @Tier2ColumnOrder
		, @Tier2SortOrder
		, @Tier2RollupGroup
		, @Tier3Columns
		, @Tier3ColumnOrder
		, @Tier3SortOrder
		, 0
		, @Sort_Order
		, @SectionsXML
		, 0
		, @CreatedBy
		, @date
		, @CreatedBy
		, @date
	);
	
	SELECT @newID = SCOPE_IDENTITY();

END;

ALTER PROCEDURE [dbo].[GridView_Update]
	@GridViewID int,
	@GridNameID int,
	@ViewName nvarchar(50),
	@SessionID nvarchar(100) = null,
	@WTS_ResourceID int = null,
	@Tier1Columns nvarchar(max) = null,
	@Tier1ColumnOrder nvarchar(max) = null,
	@Tier1SortOrder nvarchar(1000) = null,
	@Tier1RollupGroup nvarchar(50) = null,
	@Tier2Columns nvarchar(1000) = null,
	@Tier2ColumnOrder nvarchar(max) = null,
	@Tier2SortOrder nvarchar(1000) = null,
	@Tier2RollupGroup nvarchar(50) = null,
	@Tier3Columns nvarchar(1000) = null,
	@Tier3ColumnOrder nvarchar(max) = null,
	@Tier3SortOrder nvarchar(1000) = null,
	@Sort_Order int = null,
	@SectionsXML xml = null,
	@UpdatedBy nvarchar(255) = 'WTS_ADMIN',
	@duplicate bit output,
	@saved int output
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @date datetime = GETDATE();
	DECLARE @count int = 0;
	SET @duplicate = 0;
	SET @saved = 0;

	IF ISNULL(@GridViewID,0) = 0
		RETURN;

	SELECT @count = COUNT(*) FROM GridView WHERE GridViewID = @GridViewID;

	IF ISNULL(@count,0) = 0
		RETURN;

	--Check for duplicate
	SELECT @count = COUNT(*) FROM GridView 
	WHERE GridNameID = @GridNameID
		AND ViewName = @ViewName
		AND WTS_RESOURCEID = @WTS_ResourceID
		AND SessionID = @SessionID
		AND GridViewID != @GridViewID;

	IF (ISNULL(@count,0) > 0)
		BEGIN
			SET @duplicate = 1;
			RETURN;
		END;

	--UPDATE NOW
	UPDATE GridView
	SET
		GridNameID = @GridNameID
		, WTS_RESOURCEID = @WTS_ResourceID
		, SessionID = @SessionID
		, ViewName = @ViewName
		, Tier1Columns = @Tier1Columns
		, Tier1ColumnOrder = @Tier1ColumnOrder
		, Tier1SortOrder = @Tier1SortOrder
		, Tier1RollupGroup = @Tier1RollupGroup
		, Tier2Columns = @Tier2Columns
		, Tier2ColumnOrder = @Tier2ColumnOrder
		, Tier2SortOrder = @Tier2SortOrder
		, Tier2RollupGroup = @Tier2RollupGroup
		, Tier3Columns = @Tier3Columns
		, Tier3ColumnOrder = @Tier3ColumnOrder
		, Tier3SortOrder = @Tier3SortOrder
		, SORT_ORDER = @Sort_Order
		, SectionsXML = @SectionsXML
		, UPDATEDBY = @UpdatedBy
		, UPDATEDDATE = @date
	WHERE
		GridViewID = @GridViewID;

	SET @saved = 1;

END;