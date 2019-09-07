USE WTS
GO

UPDATE BugTracker.dbo.users
SET
	us_email = 'harrisdoreen@infintech.com'
WHERE
	us_username = 'harrisdoreen'
;

UPDATE BugTracker.dbo.users
SET
	us_email = us_username + '@infintech.com'
WHERE
	us_username IN ('BUS_COMPLETE','DEV_COMPLETE','FOLSOM_DEV','email','test')
;
GO


CREATE TABLE #BT_USERS(
	FirstName nvarchar(60), LastName nvarchar(60), UserName nvarchar(40), Email nvarchar(150), Active bit, LastLoginDate date, Organization nvarchar(80)
	)
INSERT INTO #BT_USERS
SELECT
	LTRIM(RTRIM(us_firstname))
	, LTRIM(RTRIM(us_lastname))
	, LTRIM(RTRIM(us_firstname)) + '.' + LTRIM(RTRIM(us_lastname)) AS UserName
	, us_email
	, us_active
	, us_most_recent_login_datetime
	, CASE o.og_name
		WHEN 'Admin' THEN 'Folsom Dev'
		WHEN 'Tech Writers and Bus. Team' THEN 'Business Team'
		WHEN 'Engineering' THEN 'RCS'
		WHEN 'Inactive' THEN 'Unauthorized'
		WHEN 'Probationary' THEN 'Unauthorized'
		ELSE o.og_name
		END AS Organization
FROM
	BugTracker.dbo.users u
		JOIN BugTracker.dbo.orgs o ON u.us_org = o.og_id
ORDER BY
	us_firstname, us_lastname
	;
	
GO


SELECT * FROM #BT_USERS;


DELETE FROM aspnet_Users;
GO

INSERT INTO aspnet_Users(UserName, LoweredUserName, ApplicationId, IsAnonymous, LastActivityDate)
SELECT 
	bu.UserName
	, LOWER(bu.UserName)
	, (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/')
	, 0
	, ISNULL(bu.LastLoginDate,getdate())
FROM
	#BT_USERS bu
EXCEPT
SELECT UserName, LoweredUserName, ApplicationId, IsAnonymous, LastActivityDate FROM aspnet_Users
;
GO

SELECT * FROM aspnet_Users;


DELETE FROM aspnet_Membership
GO

--default password is iti_2015
INSERT INTO aspnet_Membership(ApplicationId, UserId, [Password], PasswordFormat, PasswordSalt, Email, LoweredEmail, IsApproved, IsLockedOut, CreateDate, LastLoginDate, LastPasswordChangedDate, LastLockoutDate, FailedPasswordAttemptCount, FailedPasswordAttemptWindowStart, FailedPasswordAnswerAttemptCount, FailedPasswordAnswerAttemptWindowStart)
SELECT
	(SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') AS ApplicationId
	, (SELECT UserId FROM aspnet_Users WHERE UserName = bu.UserName) AS UserId
	, 'Lylgt2pc0beBSVcuIXBj8WzjmfY=' AS [Password]
	, 1 AS PasswordFormat
	, 'mPBsmaIWKxTZSWZ7Yrmtog==' AS PasswordSalt
	, bu.Email AS Email
	, LOWER(bu.Email) AS LoweredEmail
	, bu.Active AS IsApproved
	, 0 AS IsLockedOut
	, GETDATE() AS CreateDate
	, '1/1/1754 12:00:00 AM' AS LastLoginDate
	, '1/1/1754 12:00:00 AM' AS LastPasswordChangedDate
	, '1/1/1754 12:00:00 AM' AS LastLockoutDate
	, 0 AS FailedPasswordAttemptCount
	, 0 AS FailedPasswordAttemptWindowStart
	, 0 AS FailedPasswordAnswerAttemptCount
	, 0 AS FailedPasswordAnswerAttemptWindowStart
FROM
	#BT_USERS bu
EXCEPT
SELECT ApplicationId, UserId, [Password], PasswordFormat, PasswordSalt, Email, LoweredEmail, IsApproved, IsLockedOut, CreateDate, LastLoginDate, LastPasswordChangedDate, LastLockoutDate, FailedPasswordAttemptCount, FailedPasswordAttemptWindowStart, FailedPasswordAnswerAttemptCount, FailedPasswordAnswerAttemptWindowStart FROM aspnet_Membership
;

GO

SELECT * FROM aspnet_Membership;


DELETE FROM [WTS_RESOURCE]
GO

INSERT INTO [WTS_RESOURCE](Membership_UserId, ORGANIZATIONID, USERNAME, THEMEID, ENABLEANIMATIONS
	, FIRST_NAME, LAST_NAME, EMAIL)
SELECT
	au.UserId AS Membership_UserId
	, o.ORGANIZATIONID AS ORGANIZATIONID
	, bu.UserName AS USERNAME
	, 1 AS THEMEID
	, 1 AS ENABLEANIMATIONS
	, bu.FirstName AS FIRST_NAME
	, bu.LastName AS LAST_NAME
	, bu.Email AS EMAIL
FROM
	#BT_USERS bu
		JOIN aspnet_Users au on bu.UserName = au.UserName
		JOIN ORGANIZATION o ON bu.ORGANIZATION = o.ORGANIZATION
EXCEPT
SELECT Membership_UserId, ORGANIZATIONID, USERNAME, THEMEID, ENABLEANIMATIONS
	, FIRST_NAME, LAST_NAME, EMAIL FROM WTS_RESOURCE
;

GO

SELECT * FROM WTS_RESOURCE;


DROP TABLE #BT_USERS
GO
