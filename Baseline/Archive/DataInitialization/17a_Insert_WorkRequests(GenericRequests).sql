USE WTS
GO

DELETE FROM [WORKREQUEST]
GO

INSERT INTO [WORKREQUEST](REQUESTTYPEID,REQUESTGROUPID,ORGANIZATIONID,WTS_SCOPEID,PROGRESSID,TITLE,ARCHIVE)
SELECT (SELECT REQUESTTYPEID FROM REQUESTTYPE WHERE REQUESTTYPE = 'Other')
	, (SELECT RequestGroupID FROM RequestGroup WHERE RequestGroup = 'Prod Support')
	, (SELECT ORGANIZATIONID FROM ORGANIZATION WHERE [ORGANIZATION] = 'Business Team')
	, (SELECT WTS_SCOPEID FROM WTS_SCOPE WHERE [SCOPE] = 'Direct Support')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Design')
	, 'Generic Direct Support Work Request'
	, 1	UNION ALL
SELECT (SELECT REQUESTTYPEID FROM REQUESTTYPE WHERE REQUESTTYPE = 'Other')
	, (SELECT RequestGroupID FROM RequestGroup WHERE RequestGroup = 'Prod Support')
	, (SELECT ORGANIZATIONID FROM ORGANIZATION WHERE [ORGANIZATION] = 'Folsom Dev')
	, (SELECT WTS_SCOPEID FROM WTS_SCOPE WHERE [SCOPE] = 'Direct Support')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop')
	, 'Generic Direct Support Work Request'
	, 1	UNION ALL
SELECT (SELECT REQUESTTYPEID FROM REQUESTTYPE WHERE REQUESTTYPE = 'Other')
	, (SELECT RequestGroupID FROM RequestGroup WHERE RequestGroup = 'Prod Support')
	, (SELECT ORGANIZATIONID FROM ORGANIZATION WHERE [ORGANIZATION] = 'Folsom Dev')
	, (SELECT WTS_SCOPEID FROM WTS_SCOPE WHERE [SCOPE] = 'Sustainment')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop')
	, 'Generic Sustainment Work Request'
	, 1 UNION ALL
SELECT (SELECT REQUESTTYPEID FROM REQUESTTYPE WHERE REQUESTTYPE = 'Other')
	, (SELECT RequestGroupID FROM RequestGroup WHERE RequestGroup = 'Prod Support')
	, (SELECT ORGANIZATIONID FROM ORGANIZATION WHERE [ORGANIZATION] = 'Folsom Dev')
	, (SELECT WTS_SCOPEID FROM WTS_SCOPE WHERE [SCOPE] = 'New Development')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop')
	, 'Generic New Development Work Request'
	, 1 UNION ALL
SELECT (SELECT REQUESTTYPEID FROM REQUESTTYPE WHERE REQUESTTYPE = 'Other')
	, (SELECT RequestGroupID FROM RequestGroup WHERE RequestGroup = 'Prod Support')
	, (SELECT ORGANIZATIONID FROM ORGANIZATION WHERE [ORGANIZATION] = 'Folsom Dev')
	, (SELECT WTS_SCOPEID FROM WTS_SCOPE WHERE [SCOPE] = 'Warranty')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop')
	, 'Generic Warranty Work Request'
	, 1 UNION ALL
SELECT (SELECT REQUESTTYPEID FROM REQUESTTYPE WHERE REQUESTTYPE = 'Other')
	, (SELECT RequestGroupID FROM RequestGroup WHERE RequestGroup = 'Internal')
	, (SELECT ORGANIZATIONID FROM ORGANIZATION WHERE [ORGANIZATION] = 'Folsom Dev')
	, (SELECT WTS_SCOPEID FROM WTS_SCOPE WHERE [SCOPE] = 'Server Configuration')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop')
	, 'Generic Server Configuration Work Request'
	, 1 UNION ALL
SELECT (SELECT REQUESTTYPEID FROM REQUESTTYPE WHERE REQUESTTYPE = 'Other')
	, (SELECT RequestGroupID FROM RequestGroup WHERE RequestGroup = 'Internal')
	, (SELECT ORGANIZATIONID FROM ORGANIZATION WHERE [ORGANIZATION] = 'Folsom Dev')
	, (SELECT WTS_SCOPEID FROM WTS_SCOPE WHERE [SCOPE] = 'Training')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop')
	, 'Generic Training Work Request'
	, 1 UNION ALL
SELECT (SELECT REQUESTTYPEID FROM REQUESTTYPE WHERE REQUESTTYPE = 'Other')
	, (SELECT RequestGroupID FROM RequestGroup WHERE RequestGroup = 'Internal')
	, (SELECT ORGANIZATIONID FROM ORGANIZATION WHERE [ORGANIZATION] = 'Business Team')
	, (SELECT WTS_SCOPEID FROM WTS_SCOPE WHERE [SCOPE] = 'Documentation')
	, (SELECT PDDTDR_PHASEID FROM PDDTDR_PHASE WHERE PDDTDR_PHASE = 'Develop')
	, 'Generic Documentation Work Request'
	, 1
EXCEPT
SELECT REQUESTTYPEID,REQUESTGROUPID,ORGANIZATIONID,WTS_SCOPEID,PROGRESSID,TITLE,ARCHIVE FROM WORKREQUEST
GO
