use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORCR_Delete]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORCR_Delete]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORCR_Delete]
	@AORReleaseCRID int,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Exists int = 0 output,
	@HasDependencies int = 0 output,
	@Deleted bit = 0 output
as
begin
	select @Exists = count(*) from AORReleaseCR where AORReleaseCRID = @AORReleaseCRID;

	if isnull(@Exists, 0) = 0
		begin
			return;
		end;

	declare @OldCR varchar(max) = null;
	declare @aorReleaseID int = null;
	declare @itemUpdateTypeID int = null;

	SELECT @itemUpdateTypeID = ITEM_UPDATETYPEID FROM ITEM_UPDATETYPE WHERE UPPER(ITEM_UPDATETYPE) = 'UPDATE';


	begin try
		SELECT @aorReleaseID = acr.AORReleaseID 
		from AORReleaseCR acr
		where acr.AORReleaseCRID = @AORReleaseCRID 

		SELECT @OldCR = STUFF((SELECT DISTINCT ', ' + acr.CRName from AORCR acr left join AORReleaseCR crs on acr.CRID = crs.CRID WHERE crs.AORReleaseID = @aorReleaseID FOR XML PATH('')), 1, 2, '');
		
		delete from AORReleaseCR
		where AORReleaseCRID = @AORReleaseCRID;

		EXEC AORRelease_History_Add @ITEM_UPDATETYPEID = @itemUpdateTypeID, @AORReleaseID = @aorReleaseID, @FieldChanged = 'CRs', @OldValue = @OldCR, @NewValue = null, @CreatedBy = @UpdatedBy, @newID = null

		set @Deleted = 1;
	end try
	begin catch
		
	end catch;
end;
