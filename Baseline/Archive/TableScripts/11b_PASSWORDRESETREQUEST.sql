USE WTS
GO

ALTER TABLE [dbo].[PasswordResetRequest] DROP CONSTRAINT [FK_PasswordResetRequest_aspnet_Users]
GO

ALTER TABLE [dbo].[PasswordResetRequest] DROP CONSTRAINT [DF__PasswordR__expir__3F9B6DFF]
GO

ALTER TABLE [dbo].[PasswordResetRequest] DROP CONSTRAINT [DF__PasswordR__reset__3EA749C6]
GO

/****** Object:  Table [dbo].[PasswordResetRequest]    Script Date: 6/12/2015 4:13:08 PM ******/
DROP TABLE [dbo].[PasswordResetRequest]
GO

/****** Object:  Table [dbo].[PasswordResetRequest]    Script Date: 6/12/2015 4:13:08 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[PasswordResetRequest](
	[resetcode] [uniqueidentifier] NOT NULL DEFAULT(newid()),
	[userId] [uniqueidentifier] NOT NULL,
	[requestDateTicks] [bigint] NOT NULL,
	[expired] [bit] NOT NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[resetcode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[PasswordResetRequest]  WITH CHECK ADD  CONSTRAINT [FK_PasswordResetRequest_aspnet_Users] FOREIGN KEY([userId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO

ALTER TABLE [dbo].[PasswordResetRequest] CHECK CONSTRAINT [FK_PasswordResetRequest_aspnet_Users]
GO

