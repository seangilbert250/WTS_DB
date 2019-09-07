USE WTS
GO

DELETE FROM CONFIGSETTING
GO

SET IDENTITY_INSERT CONFIGSETTING ON
GO

INSERT INTO CONFIGSETTING(CONFIGSETTINGID, CONFIGSETTINGTYPEID, PARENTSETTINGID, SETTINGVALUE, [DESCRIPTION], ARCHIVE)
SELECT 1, 1, NULL, 'mail.infintech.com', 'ITI email server', 0 UNION ALL
SELECT 2, 2, NULL, 'FolsomWorkload@infintech.com', 'Email FROM address', 0 UNION ALL
SELECT 3, 3, 2, 'WTS Web Application', 'AppName email name', 0 UNION ALL
SELECT 4, 4, NULL, 'FolsomWorkload@infintech.com', 'System support email address', 0 UNION ALL
SELECT 5, 5, 4, 'WTS Support', 'WTS Support', 0 UNION ALL
SELECT 6, 6, NULL, 'FolsomWorkload@infintech.com', 'Support email from address', 0 UNION ALL
SELECT 7, 7, 6, 'WTS Support', 'Support', 0 UNION ALL
SELECT 8, 8, NULL, 'FolsomWorkload@infintech.com', '', 0 UNION ALL
SELECT 9, 9, NULL, '', '', 0 UNION ALL
SELECT 10, 10, NULL, '', '', 0 UNION ALL
SELECT 11, 11, NULL, '30', '30 minutes', 0 UNION ALL
SELECT 12, 12, NULL, 'FolsomWorkload@infintech.com', '', 0 UNION ALL
SELECT 13, 13, 12, 'WTS Registration', '', 0 UNION ALL
SELECT 14, 14, NULL, 'mcnameep@infintech.com', '', 0 UNION ALL
SELECT 15, 15, 14, 'Pete McNamee', '', 0 UNION ALL
SELECT 16, 14, NULL, 'kirchgatterj@infintech.com', '', 0 UNION ALL
SELECT 17, 15, 14, 'Jared Kirchgatter', '', 0 UNION ALL
SELECT 18, 14, NULL, 'harrisd@infintech.com', '', 0 UNION ALL
SELECT 19, 15, 18, 'Derik Harris', '', 0 UNION ALL
SELECT 20, 14, NULL, 'mendozae@infintech.com', '', 0 UNION ALL
SELECT 21, 15, 20, 'Erin Mendoza', '', 0 UNION ALL
SELECT 22, 14, NULL, 'mendozaej@infintech.com', '', 0 UNION ALL
SELECT 23, 15, 22, 'Esel Ramos', '', 0

--TODO: add more error email recipients


GO

SET IDENTITY_INSERT CONFIGSETTING OFF
GO