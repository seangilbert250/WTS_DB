﻿USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WorkRequest_GetOptions]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [WorkRequest_GetOptions]

GO

CREATE PROCEDURE [dbo].[WorkRequest_GetOptions]
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

	--Effort
	SELECT
		e.EFFORTID
		, e.EFFORT
	FROM
		EFFORT e
	WHERE
		e.ARCHIVE = 0
	ORDER BY
		SORT_ORDER, UPPER(e.EFFORT)
	;

	--PD2TDR Phase
	SELECT
		pp.PDDTDR_PHASEID
		, pp.PDDTDR_PHASE
	FROM
		PDDTDR_PHASE pp
	WHERE
		pp.ARCHIVE = 0
		AND PDDTDR_PHASE != 'Task'
	ORDER BY
		SORT_ORDER, UPPER(pp.PDDTDR_PHASE)
	;

	--Users
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

	--Operations Priority
	SELECT
		p.PRIORITYID
		, p.[PRIORITY]
		, p.SORT_ORDER
	FROM
		PRIORITY p
	WHERE
		p.ARCHIVE = 0
		AND p.PRIORITYTYPEID = (SELECT PRIORITYTYPEID FROM PRIORITYTYPE WHERE PRIORITYTYPE LIKE '%Operations%')
	ORDER BY
		p.SORT_ORDER, UPPER(p.PRIORITY)
	;
	
	--Request Group
	SELECT
		rg.RequestGroupID
		, rg.RequestGroup
	FROM
		RequestGroup rg
	WHERE
		rg.ARCHIVE = 0
	ORDER BY
		SORT_ORDER, UPPER(rg.RequestGroup)
	;

	--Status
	SELECT
		s.STATUSID
		, s.[STATUS]
		, s.[DESCRIPTION] AS Status_Description
		, s.StatusTypeID
		, st.StatusType
		, st.[DESCRIPTION] AS StatusType_Description
	FROM
		[STATUS] s
			JOIN StatusType st ON s.StatusTypeID = st.StatusTypeID
	WHERE
		st.StatusTypeID BETWEEN 2 AND 8
	ORDER BY st.SORT_ORDER, s.SORT_ORDER
	;

END;

GO
