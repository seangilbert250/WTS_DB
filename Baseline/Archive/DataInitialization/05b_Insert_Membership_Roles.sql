USE WTS
GO

INSERT INTO aspnet_Roles(RoleName, LoweredRoleName, Description, ApplicationId)
SELECT 'Admin', 'admin', 'Unrestricted access in all areas of system', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'WorkRequest', 'workrequest', 'Read/Write access to Work Requests', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'CR', 'cr', 'Read/Write access to CR maintenance', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'SustainmentRequest', 'sustainmentrequest', 'Read/Write access to Sustainment Requests', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'WorkItem', 'workitem', 'Read/Write access to Work Items', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'Task', 'task', 'Read/Write access to Work Item Tasks', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'MasterData', 'masterdata', 'Read/Write access to Master Data', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'Administration', 'administration', 'Read/Write access to ALL Administration module', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'ResourceManagement', 'resourcemanagement', 'Read/Write access to Resource Management', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'Dashboard', 'dashboard', 'Read/Write - Can view AND edit Dashboard', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'Reports', 'reports', 'Read/Write - Can view Reports AND create custom Reports', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'News', 'news', 'Read/Write Access to News', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:WorkRequest', 'view:workrequest', 'View Only access to Work Requests', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:CR', 'view:cr', 'View Only access to CR maintenance', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:SustainmentRequest', 'view:sustainmentrequest', 'View Only access to Sustainment Requests', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:WorkItem', 'view:workitem', 'View Only access to Work Items', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:Task', 'view:task', 'View Only access to Work Item Tasks', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:MasterData', 'view:masterdata', 'View only access to Master Data', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:Administration', 'view:administration', 'View only access to ALL Administration module', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:ResourceManagement', 'view:resourcemanagement', 'View only access to Resource Management', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:Dashboard', 'view:dashboard', 'View Only access to pre-configured Dashboard', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:Reports', 'view:reports', 'View Only access to Reports', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:Metrics', 'view:metrics', 'Access to view Metrics', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:CVTMetrics', 'view:cvtmetrics', 'Access to view CVT Metrics', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/') UNION ALL
SELECT 'View:News', 'view:news', 'Access to view News', (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = '/')
EXCEPT 
SELECT RoleName, LoweredRoleName, Description, ApplicationId FROM aspnet_Roles

GO