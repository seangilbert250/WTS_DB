use WTS

declare @count int

SELECT @count = count(*) FROM News where Summary = 'Changes on Task/Sub-Task Status';


IF @count <= 0
begin
	INSERT INTO [dbo].[News]
			   ([Summary]
			   ,[Detail]
			   ,[Sort_Order])
		 VALUES
			   ('Changes on Task/Sub-Task Status'
			   ,'The Task/Sub-Task Status of "Re-Opened" will only be available after the Task/Sub-Task has been saved as "Checked-In," "Closed," "Deployed," or "Un-reproducible."  Additionally, the statuses of “Approved/Closed” and “Complete” no longer exist.  All those tasks & sub-tasks now have a status of “Closed.”'
			   ,11)
end