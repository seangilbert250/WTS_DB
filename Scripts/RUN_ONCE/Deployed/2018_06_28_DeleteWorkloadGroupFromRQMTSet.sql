USE WTS
GO

IF dbo.ColumnExists('dbo', 'RQMTSet', 'WorkloadGroupID') = 1
BEGIN
	DECLARE @sql NVARCHAR(MAX) = ''

	SELECT @sql = @sql + 'ALTER TABLE RQMTSet DROP CONSTRAINT ' + name + ';'
	FROM sys.default_constraints
	WHERE parent_object_id = object_id('RQMTSet') AND type = 'D' and definition = '((1))'

	--select @sql

	exec sp_executesql @sql

	ALTER TABLE [dbo].[RQMTSet] DROP CONSTRAINT [FK_RQMTSet_WorkloadGroup]
	ALTER TABLE RQMTSet DROP COLUMN WorkloadGroupID
END