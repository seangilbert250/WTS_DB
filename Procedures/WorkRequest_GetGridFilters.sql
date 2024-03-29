﻿USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkRequest_GetGridFilters]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkRequest_GetGridFilters]

GO

CREATE PROCEDURE [dbo].[WorkRequest_GetGridFilters]
AS
BEGIN
	--Contract
	SELECT
		c.CONTRACTID
		, c.[CONTRACT]
	FROM
		[CONTRACT] c
	WHERE
		c.ARCHIVE = 0
	ORDER BY
		SORT_ORDER, UPPER(c.[CONTRACT])
	;

	--Organization
	SELECT
		o.ORGANIZATIONID
		, o.ORGANIZATION
	FROM
		ORGANIZATION o
	WHERE
		o.ARCHIVE = 0
	ORDER BY
		SORT_ORDER, UPPER(o.ORGANIZATION)
	;

	--Request Type
	SELECT
		rt.REQUESTTYPEID
		, rt.REQUESTTYPE
	FROM
		REQUESTTYPE rt
	WHERE
		rt.ARCHIVE = 0
	ORDER BY
		SORT_ORDER, UPPER(rt.REQUESTTYPE)
	;

	--Scope
	SELECT
		s.WTS_SCOPEID
		, s.SCOPE
	FROM
		WTS_SCOPE s
	WHERE
		s.ARCHIVE = 0
	ORDER BY
		SORT_ORDER, UPPER(s.SCOPE)
	;

	--Operations Priority
	SELECT
		p.PRIORITYID
		, p.PRIORITY
	FROM
		PRIORITY p
	WHERE
		p.ARCHIVE = 0
		AND p.PRIORITYTYPEID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE LIKE '%Operations%')
	ORDER BY
		p.SORT_ORDER, UPPER(p.PRIORITY)
	;

	--SME
	SELECT
		u.WTS_RESOURCEID
		, u.ORGANIZATIONID
		, u.USERNAME
		, u.FIRST_NAME
		, u.LAST_NAME
	FROM
		WTS_RESOURCE u
	WHERE
		u.ARCHIVE = 0
	ORDER BY
		UPPER(u.FIRST_NAME), UPPER(u.LAST_NAME)
	;

	--Lead_IA_TW
	SELECT
		u.WTS_RESOURCEID
		, u.ORGANIZATIONID
		, u.USERNAME
		, u.FIRST_NAME
		, u.LAST_NAME
	FROM
		WTS_RESOURCE u
	WHERE
		u.ARCHIVE = 0
	ORDER BY
		UPPER(u.FIRST_NAME), UPPER(u.LAST_NAME)
	;

	--Lead_Resource
	SELECT
		u.WTS_RESOURCEID
		, u.ORGANIZATIONID
		, u.USERNAME
		, u.FIRST_NAME
		, u.LAST_NAME
	FROM
		WTS_RESOURCE u
	WHERE
		u.ARCHIVE = 0
	ORDER BY
		UPPER(u.FIRST_NAME), UPPER(u.LAST_NAME)
	;

	--PD2TDR Phase
	SELECT
		pp.PDDTDR_PHASEID
		, pp.PDDTDR_PHASE
	FROM
		PDDTDR_PHASE pp
	WHERE
		pp.ARCHIVE = 0
	ORDER BY
		SORT_ORDER, UPPER(pp.PDDTDR_PHASE)
	;

	--Submitted By
	SELECT
		u.WTS_RESOURCEID
		, u.ORGANIZATIONID
		, u.USERNAME
		, u.FIRST_NAME
		, u.LAST_NAME
	FROM
		WTS_RESOURCE u
	WHERE
		u.ARCHIVE = 0
	ORDER BY
		UPPER(u.FIRST_NAME), UPPER(u.LAST_NAME)
	;

END;

GO
