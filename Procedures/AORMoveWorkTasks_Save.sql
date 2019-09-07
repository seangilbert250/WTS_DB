USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORMoveWorkTasks_Save]    Script Date: 4/27/2018 4:09:53 PM ******/
DROP PROCEDURE [dbo].[AORMoveWorkTasks_Save]
GO

/****** Object:  StoredProcedure [dbo].[AORMoveWorkTasks_Save]    Script Date: 4/27/2018 4:09:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create procedure [dbo].[AORMoveWorkTasks_Save]
	@AORID int = 0,
	@AORReleaseID int = 0,
	@AORID2 int = 0,
	@AORReleaseID2 int = 0,
	@Tasks xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin

end;
go