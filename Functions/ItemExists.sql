USE [WTS]
GO

/****** Object:  UserDefinedFunction [dbo].[ItemExists]    Script Date: 3/12/2018 12:56:30 PM ******/
DROP FUNCTION [dbo].[ItemExists]
GO

/****** Object:  UserDefinedFunction [dbo].[ItemExists]    Script Date: 3/12/2018 12:56:30 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[ItemExists]
(
	@ItemID int,
	@TaskNumber int = 0,
	@Type nvarchar(50)
)
RETURNS bit
AS
BEGIN
	DECLARE @count int;
	SET @count = 0;
	DECLARE @isExisting bit;
	SET @isExisting = 0;

	IF @Type = 'Primary Task'
		SELECT @count = COUNT(WORKITEMID)
		FROM WORKITEM
		WHERE WORKITEMID = @ItemID
	ELSE IF @Type = 'Work Request'
		SELECT @count = COUNT(WORKREQUESTID)
		FROM WORKREQUEST
		WHERE WORKREQUESTID = @ItemID
	ELSE IF @Type = 'Subtask'
		SELECT @count = COUNT(WORKITEMID)
		FROM WORKITEM_TASK
		WHERE WORKITEMID = @ItemID
		AND TASK_NUMBER = @TaskNumber

	IF (ISNULL(@count,0) > 0)
		SET @isExisting = 1;
	ELSE
		SET @isExisting = 0;

	RETURN @isExisting;
END;

GO


