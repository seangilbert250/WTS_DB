USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORReleaseTask_Get]    Script Date: 7/9/2018 4:36:13 PM ******/
DROP PROCEDURE [dbo].[AORReleaseTask_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORReleaseTask_Get]    Script Date: 7/9/2018 4:36:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create procedure [dbo].[AORReleaseTask_Get]
    @WorkItemID int,
    @AORReleaseTaskID int = 0 output
as
begin
    select @AORReleaseTaskID = AORReleaseTaskID
    FROM AORReleaseTask art
    left join AORRelease arl
    on art.AORReleaseID = arl.AORReleaseID
    where @WorkItemID = art.WORKITEMID
    and arl.AORWorkTypeID = 2;
end;
