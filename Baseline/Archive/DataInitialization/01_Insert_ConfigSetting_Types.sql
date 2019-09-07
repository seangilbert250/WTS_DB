USE WTS
GO

DELETE FROM ConfigSetting_Type
GO

SET IDENTITY_INSERT ConfigSetting_Type ON
GO

INSERT INTO ConfigSetting_Type(ConfigSetting_TypeId, Parent_TypeID, ConfigSetting_Type, [Description], Archive)
SELECT 1, NULL, 'EmailServer', 'Email server', 0 UNION ALL
SELECT 2, NULL, 'EmailFrom', 'System email FROM address', 0 UNION ALL
SELECT 3, 2, 'EmailFromName', 'User friendly name of email FROM account', 0 UNION ALL
SELECT 4, NULL, 'ErrorEmailTo', 'Email address to send error messages TO', 0 UNION ALL
SELECT 5, 4, 'ErrorEmailToName', 'User friendly name of email TO acount', 0 UNION ALL
SELECT 6, NULL, 'ErrorEmailFrom', 'System ERROR Email FROM address', 0 UNION ALL
SELECT 7, 6, 'ErrorEmailFromName', 'User friendly name of System ERROR Email FROM account', 0 UNION ALL
SELECT 8, NULL, 'TechSupport_Email', 'Email address to send to for tech support issues', 0 UNION ALL
SELECT 9, NULL, 'TechSupport_Phone', 'Phone number to call for tech support regarding system issues', 0 UNION ALL
SELECT 10, NULL, 'TechSupport_Fax', 'Fax number to send to for tech support regarding system issues', 0 UNION ALL
SELECT 11, NULL, 'PasswordResetExpiration', 'Time in minutes after which password reset request code expires', 0 UNION ALL
SELECT 12, NULL, 'RegistrationEmailTo', 'Email Address to send registration updates/issues to', 0 UNION ALL
SELECT 13, 12, 'RegistrationEmailToName', 'User friendly name for Email Address to send registration updates/issues to', 0 UNION ALL
SELECT 14, NULL, 'RegistrationEmailBcc', 'Email Address to copy registration udpates/issues to', 0 UNION ALL
SELECT 15, 14, 'RegistrationEmailBccName', 'User friendly name for Email Address to copy registration updates/issues to', 0

GO

SET IDENTITY_INSERT ConfigSetting_Type OFF
GO