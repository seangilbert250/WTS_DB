USE [WTS]
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[AOREstimation_Assoc_Add]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE [AOREstimation_Assoc_Add]
SET ANSI_NULLS ON
GO

CREATE procedure [dbo].[AOREstimation_Assoc_Add]
	@AOREstimation_AORReleaseID int,
	@Additions xml,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output
as
begin
	set nocount on;

	declare @date datetime;

	set @date = getdate();

	begin
		begin try
			if @Additions.exist('additions/save') > 0
				begin
					with
					w_aors as (
						select distinct
							tbl.[save].value('aorid[1]', 'int') as AORID
						from @Additions.nodes('additions/save') as tbl([save])
					)
					insert into AOREstimation_AORAssoc(AOREstimation_AORReleaseID, AORID, CreatedBy, CreatedDate, UpdatedBy, UpdatedDate)
					select @AOREstimation_AORReleaseID,
						AORID,
						@UpdatedBy,
						@date,
						@UpdatedBy,
						@date
					from w_aors;
				end;

			set @Saved = 1;
		end try
		begin catch
				
		end catch;
	end;
	
end;

SELECT 'Executing File [Procedures\AORMeetingInstanceList_Get.sql]';
GO


