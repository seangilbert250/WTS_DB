use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORCRLookup_Save]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORCRLookup_Save]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORCRLookup_Save]
	@Altered bit,
	@NewCR bit,
	@CRID int,
	@CRName nvarchar(255),
	@Title nvarchar(255),
	@Notes nvarchar(max),
	@Websystem nvarchar(255),
	@CSDRequiredNow int,
	@RelatedRelease nvarchar(255),
	@Subgroup nvarchar(255),
	@DesignReview nvarchar(255),
	@ITIPOC nvarchar(255),
	@CustomerPriorityList nvarchar(255),
	@GovernmentCSRD int,
	@PrimarySRID int,
    @CAMPriority int,
	@LCMBPriority int,
	@AirstaffPriority int,
	@CustomerPriority int,
	@ITIPriority int,
	@RiskOfPTS int,
	@StatusID int,
	@LCMBSubmitted datetime,
	@LCMBApproved datetime,
	@ERBISMTSubmitted datetime,
	@ERBISMTApproved datetime,
	@UpdatedBy nvarchar(50) = 'WTS',
	@Saved bit = 0 output,
	@Exists bit = 0 output,
	@NewID int = 0 output
as
begin
	set nocount on;

	declare @date datetime;
	declare @count int;
	declare @newCRID int;

	set @date = getdate();

	if @NewCR = 1
		begin
			select @count = count(*) from AORCR where CRName = @CRName;

			if isnull(@count, 0) > 0
				begin
					set @Exists = 1;
					return;
				end;

			begin try
				select @newCRID = isnull(case when min(CRID) > 0 then 0 else min(CRID) end, 0) - 1 from AORCR;

				insert into AORCR(CRID, CRName, Title, Notes, Websystem, CSDRequiredNow, RelatedRelease, Subgroup, DesignReview, ITIPOC, CustomerPriorityList, GovernmentCSRD, PrimarySR,
					CAMPriority, LCMBPriority, AirstaffPriority, CustomerPriority, ITIPriority, RiskOfPTS,
					StatusID, LCMBSubmittedDate, LCMBApprovedDate, ERBISMTSubmittedDate, ERBISMTApprovedDate,
					CreatedBy, UpdatedBy)
				values(@newCRID, @CRName, @Title, @Notes, @Websystem, @CSDRequiredNow, @RelatedRelease, @Subgroup, @DesignReview, @ITIPOC, @CustomerPriorityList, @GovernmentCSRD, @PrimarySRID,
					@CAMPriority, @LCMBPriority, @AirstaffPriority, @CustomerPriority, @ITIPriority, @RiskOfPTS,
					@StatusID, @LCMBSubmitted, @LCMBApproved, @ERBISMTSubmitted, @ERBISMTApproved,
					@UpdatedBy, @UpdatedBy);
	
				select @NewID = @newCRID;

				set @Saved = 1;
			end try
			begin catch
				
			end catch;
		end;
	else if @CRID < 0 or @CRID > 0
		begin
			select @count = count(*) from AORCR where CRName = @CRName and CRID != @CRID;

			if isnull(@count, 0) > 0
				begin
					set @Exists = 1;
					return;
				end;

			select @Altered = Altered from AORCR where CRID = @CRID and Imported = 1 and Altered = 1;
			if isnull(@Altered, 0) = 1
				begin
					set @Altered = 1;
				end;
			
			update AORCR
			set CRName = @CRName,
				Title = @Title,
				Notes = @Notes,
				Websystem = @Websystem,
				CSDRequiredNow = @CSDRequiredNow,
				RelatedRelease = @RelatedRelease,
				Subgroup = @Subgroup,
				DesignReview = @DesignReview,
				ITIPOC = @ITIPOC,
				CustomerPriorityList = @CustomerPriorityList,
				GovernmentCSRD = @GovernmentCSRD,
				PrimarySR = @PrimarySRID,
				CAMPriority = @CAMPriority,
				LCMBPriority = @LCMBPriority,
				AirstaffPriority = @AirstaffPriority,
				CustomerPriority = @CustomerPriority,
				ITIPriority = @ITIPriority,
				RiskOfPTS = @RiskOfPTS,
				StatusID = @StatusID,
				LCMBSubmittedDate = @LCMBSubmitted,
				LCMBApprovedDate = @LCMBApproved,
				ERBISMTSubmittedDate = @ERBISMTSubmitted,
				ERBISMTApprovedDate = @ERBISMTApproved,
				UpdatedBy = @UpdatedBy,
				UpdatedDate = @date,
				Altered = @Altered
			where CRID = @CRID;
			
			set @Saved = 1;
		end;
end;
