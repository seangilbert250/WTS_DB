--select * from users order by us_id;

INSERT INTO project_user_xref (
	pu_project, pu_user
)
SELECT distinct p.pj_id, u.us_id
FROM projects p
	, users u
EXCEPT SELECT pu_project, pu_user FROM project_user_xref;
GO

UPDATE project_user_xref
SET pu_permission_level = 1
WHERE pu_permission_level > 0
	AND pu_user NOT IN (
		SELECT 
			u.us_id
		FROM
			users u
		WHERE
			u.us_username IN ('pete','porubskyj')
	)
;