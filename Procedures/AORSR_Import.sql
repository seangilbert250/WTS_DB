use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORSR_Import]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORSR_Import]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORSR_Import]
as
begin
	set nocount on;

	declare @date datetime;
	declare @lastImport nvarchar(50);
	declare @totalBeforeCountCR int = 0;
	declare @totalAfterCountCR int = 0;
	declare @totalBeforeCountSR int = 0;
	declare @openBeforeCountSR int = 0;
	declare @closedBeforeCountSR int = 0;
	declare @totalAfterCountSR int = 0;
	declare @openAfterCountSR int = 0;
	declare @closedAfterCountSR int = 0;

	declare @OldCRName nvarchar(255);
	declare @CRName nvarchar(255);
	declare @OldTitle nvarchar(255);
	declare @Title nvarchar(255);
	declare @OldNotes nvarchar(max);
	declare @Notes nvarchar(max);
	declare @OldWebsystem nvarchar(255);
	declare @Websystem nvarchar(255);
	declare @OldCRCSDRequiredNow int;
	declare @CRCSDRequiredNow int;
	declare @OldCRRelatedRelease nvarchar(255);
	declare @CRRelatedRelease nvarchar(255);
	declare @OldCRSubgroup nvarchar(255);
	declare @CRSubgroup nvarchar(255);
	declare @OldCRDesignReview nvarchar(255);
	declare @CRDesignReview nvarchar(255);
	declare @OldCRITIPOC nvarchar(255);
	declare @CRITIPOC nvarchar(255);
	declare @OldCRCustomerPriorityList nvarchar(255);
	declare @CRCustomerPriorityList nvarchar(255);
	declare @OldCRGovernmentCSRD int;
	declare @CRGovernmentCSRD int;
	declare @OldCRPrimarySR int;
	declare @CRPrimarySR int;

	declare @SRID int;
	declare @OldSubmittedBy nvarchar(255);
	declare @SubmittedBy nvarchar(255);
	declare @OldSubmittedDate nvarchar(255);
	declare @SubmittedDate nvarchar(255);
	declare @OldKeywords nvarchar(255);
	declare @Keywords nvarchar(255);
	declare @OldSRWebsystem nvarchar(255);
	declare @SRWebsystem nvarchar(255);
	declare @OldStatus nvarchar(255);
	declare @Status nvarchar(255);
	declare @OldSRType nvarchar(255);
	declare @SRType nvarchar(255);
	declare @OldPriority nvarchar(255);
	declare @Priority nvarchar(255);
	declare @OldLCMB int;
	declare @LCMB int;
	declare @OldITI int;
	declare @ITI int;
	declare @OldITIPOC nvarchar(255);
	declare @ITIPOC nvarchar(255);
	declare @OldDescription nvarchar(max);
	declare @Description nvarchar(max);
	declare @OldLastReply nvarchar(max);
	declare @LastReply nvarchar(max);
	declare @OldCRID int;
	declare @CRID int;

	declare @subject nvarchar(4000) = 'WTS: CAFDEx Sustainment Request Import';
	declare @html nvarchar(max);
	declare @error nvarchar(4000) = '';

	set @date = getdate();

	begin try
		select @lastImport = isnull(convert(varchar(10), max(ImportDate), 101) + right(convert(varchar(32), max(ImportDate), 100), 8), 'None') from AORSRImport;

		insert into AORSRImport([FileName])
		values ('WTS_SR.csv');

		create table #DeletedCRs(CRName nvarchar(255));
		create table #InsertedCRs(CRName nvarchar(255));
		create table #UpdatedCRs(
			OldCRName nvarchar(255),
			CRName nvarchar(255),
			OldTitle nvarchar(255),
			Title nvarchar(255),
			OldNotes nvarchar(max),
			Notes nvarchar(max),
			OldWebsystem nvarchar(255),
			Websystem nvarchar(255),
			OldCRCSDRequiredNow int,
			CRCSDRequiredNow int,
			OldCRRelatedRelease nvarchar(255),
			CRRelatedRelease nvarchar(255),
			OldCRSubgroup nvarchar(255),
			CRSubgroup nvarchar(255),
			OldCRDesignReview nvarchar(255),
			CRDesignReview nvarchar(255),
			OldCRITIPOC nvarchar(255),
			CRITIPOC nvarchar(255),
			OldCRCustomerPriorityList nvarchar(255),
			CRCustomerPriorityList nvarchar(255),
			OldCRGovernmentCSRD int,
			CRGovernmentCSRD int,
			OldCRPrimarySR int,
			CRPrimarySR int
		);
		create table #DeletedSRs(SRID int);
		create table #InsertedSRs(SRID int);
		create table #UpdatedSRs(
			SRID int,
			OldSubmittedBy nvarchar(255),
			SubmittedBy nvarchar(255),
			OldSubmittedDate nvarchar(255),
			SubmittedDate nvarchar(255),
			OldKeywords nvarchar(255),
			Keywords nvarchar(255),
			OldWebsystem nvarchar(255),
			Websystem nvarchar(255),
			OldStatus nvarchar(255),
			[Status] nvarchar(255),
			OldSRType nvarchar(255),
			SRType nvarchar(255),
			OldPriority nvarchar(255),
			[Priority] nvarchar(255),
			OldLCMB int,
			LCMB int,
			OldITI int,
			ITI int,
			OldITIPOC nvarchar(255),
			ITIPOC nvarchar(255),
			OldDescription nvarchar(max),
			[Description] nvarchar(max),
			OldLastReply nvarchar(max),
			LastReply nvarchar(max),
			OldCRID int,
			CRID int
		);
		create table #AORSRImport(
			SRID int,
			SubmittedBy nvarchar(255),
			SubmittedDate nvarchar(255),
			Keywords nvarchar(255),
			Websystem nvarchar(255),
			[Status] nvarchar(255),
			SRType nvarchar(255),
			[Priority] nvarchar(255),
			LCMB int,
			ITI int,
			ITIPOC nvarchar(255),
			[Description] nvarchar(max),
			LastReply nvarchar(max),
			CRID int,
			CRPrimarySR int,
			CRTitle nvarchar(255),
			CRName nvarchar(255),
			CRNotes nvarchar(max),
			CRWebsystem nvarchar(255),
			CRCSDRequiredNow int,
			CRRelatedRelease nvarchar(255),
			CRSubgroup nvarchar(255),
			CRDesignReview nvarchar(255),
			CRITIPOC nvarchar(255),
			CRCustomerPriorityList nvarchar(255),
			CRGovernmentCSRD int
		);

		bulk insert #AORSRImport
		from 'C:\WTS\WTS_Fileshare\WTS_SR.csv'
		with (
			firstrow = 2,
			fieldterminator = '|',
			rowterminator = '\n',
			tablock
		);

		select @totalBeforeCountCR = count(1)
		from AORCR;

		select @totalBeforeCountSR = count(1)
		from AORSR;

		select @openBeforeCountSR = count(1)
		from AORSR
		where upper(isnull([Status], '')) != 'RESOLVED';

		select @closedBeforeCountSR = count(1)
		from AORSR
		where upper([Status]) = 'RESOLVED';
		
		delete from AORReleaseCR
		where exists (
			select 1
			from AORCR acr
			where acr.CRID = AORReleaseCR.CRID
			and acr.Imported = 1
			and acr.Altered != 1
		)
		and not exists (
			select 1
			from #AORSRImport asi
			where asi.CRID = AORReleaseCR.CRID
		);
		
		delete from AORSR
		output deleted.SRID
		into #DeletedSRs
		where Imported = 1
		and not exists (
			select 1
			from #AORSRImport asi
			where asi.SRID = AORSR.SRID
		);

		delete from AORSR
		output deleted.SRID
		into #DeletedSRs
		where Imported = 1
		and not exists (
			select 1
			from #AORSRImport asi
			where asi.CRID = AORSR.CRID
		);

		delete from AORCR
		output deleted.CRName
		into #DeletedCRs
		where Imported = 1
		and Altered != 1
		and not exists (
			select 1
			from #AORSRImport asi
			where asi.CRID = AORCR.CRID
		);

		insert into AORCR(CRID,
			CRName,
			Title,
			Notes,
			Websystem,
			CSDRequiredNow,
			RelatedRelease,
			Subgroup,
			DesignReview,
			ITIPOC,
			CustomerPriorityList,
			GovernmentCSRD,
			PrimarySR,
			Imported
		)
		output inserted.CRName
		into #InsertedCRs
		select distinct CRID,
			CRName,
			CRTitle,
			CRNotes,
			CRWebsystem,
			CRCSDRequiredNow,
			CRRelatedRelease,
			CRSubgroup,
			CRDesignReview,
			CRITIPOC,
			CRCustomerPriorityList,
			CRGovernmentCSRD,
			CRPrimarySR,
			1
		from #AORSRImport asi
		where CRID is not null
		and not exists (
			select 1
			from AORCR acr
			where acr.CRID = asi.CRID
		);

		with crs as (
			select distinct CRID,
				CRName,
				CRTitle,
				CRNotes,
				CRWebsystem,
				CRCSDRequiredNow,
				CRRelatedRelease,
				CRSubgroup,
				CRDesignReview,
				CRITIPOC,
				CRCustomerPriorityList,
				CRGovernmentCSRD,
				CRPrimarySR
			from #AORSRImport asi
		)
		update AORCR
		set AORCR.CRName = crs.CRName,
			AORCR.Title = crs.CRTitle,
			AORCR.Notes = crs.CRNotes,
			AORCR.Websystem = crs.CRWebsystem,
			AORCR.CSDRequiredNow = crs.CRCSDRequiredNow,
			AORCR.RelatedRelease = crs.CRRelatedRelease,
			AORCR.Subgroup = crs.CRSubgroup,
			AORCR.DesignReview = crs.CRDesignReview,
			AORCR.ITIPOC = crs.CRITIPOC,
			AORCR.CustomerPriorityList = crs.CRCustomerPriorityList,
			AORCR.GovernmentCSRD = crs.CRGovernmentCSRD,
			AORCR.PrimarySR = crs.CRPrimarySR,
			AORCR.UpdatedBy = 'WTS',
			AORCR.UpdatedDate = @date
		output deleted.CRName,
			inserted.CRName,
			deleted.Title,
			inserted.Title,
			deleted.Notes,
			inserted.Notes,
			deleted.Websystem,
			inserted.Websystem,
			deleted.CSDRequiredNow,
			inserted.CSDRequiredNow,
			deleted.RelatedRelease,
			inserted.RelatedRelease,
			deleted.Subgroup,
			inserted.Subgroup,
			deleted.DesignReview,
			inserted.DesignReview,
			deleted.ITIPOC,
			inserted.ITIPOC,
			deleted.CustomerPriorityList,
			inserted.CustomerPriorityList,
			deleted.GovernmentCSRD,
			inserted.GovernmentCSRD,
			deleted.PrimarySR,
			inserted.PrimarySR
		into #UpdatedCRs
		from crs
		where (AORCR.CRID = crs.CRID and AORCR.Altered != 1)
		and (
			isnull(AORCR.CRName, 0) != isnull(crs.CRName, 0) or
			isnull(AORCR.Title, 0) != isnull(crs.CRTitle, 0) or
			isnull(AORCR.Notes, 0) != isnull(crs.CRNotes, 0) or
			isnull(AORCR.Websystem, 0) != isnull(crs.CRWebsystem, 0) or
			isnull(AORCR.CSDRequiredNow, 0) != isnull(crs.CRCSDRequiredNow, 0) or
			isnull(AORCR.RelatedRelease, 0) != isnull(crs.CRRelatedRelease, 0) or
			isnull(AORCR.Subgroup, 0) != isnull(crs.CRSubgroup, 0) or
			isnull(AORCR.DesignReview, 0) != isnull(crs.CRDesignReview, 0) or
			isnull(AORCR.ITIPOC, 0) != isnull(crs.CRITIPOC, 0) or
			isnull(AORCR.CustomerPriorityList, 0) != isnull(crs.CRCustomerPriorityList, 0) or
			isnull(AORCR.GovernmentCSRD, 0) != isnull(crs.CRGovernmentCSRD, 0) or
			isnull(AORCR.PrimarySR, 0) != isnull(crs.CRPrimarySR, 0)
		);

		insert into AORSR(SRID,
			SubmittedBy,
			SubmittedDate,
			Keywords,
			Websystem,
			[Status],
			SRType,
			[Priority],
			LCMB,
			ITI,
			ITIPOC,
			[Description],
			LastReply,
			CRID,
			Imported
		)
		output inserted.SRID
		into #InsertedSRs
		select SRID,
			SubmittedBy,
			SubmittedDate,
			Keywords,
			Websystem,
			[Status],
			SRType,
			[Priority],
			LCMB,
			ITI,
			ITIPOC,
			[Description],
			LastReply,
			CRID,
			1
		from #AORSRImport asi
		where not exists (
			select 1
			from AORSR asr
			where asr.SRID = asi.SRID
		);

		update AORSR
		set AORSR.SubmittedBy = asi.SubmittedBy,
			AORSR.SubmittedDate = asi.SubmittedDate,
			AORSR.Keywords = asi.Keywords,
			AORSR.Websystem = asi.Websystem,
			AORSR.[Status] = asi.[Status],
			AORSR.SRType = asi.SRType,
			AORSR.[Priority] = asi.[Priority],
			AORSR.LCMB = asi.LCMB,
			AORSR.ITI = asi.ITI,
			AORSR.ITIPOC = asi.ITIPOC,
			AORSR.[Description] = asi.[Description],
			AORSR.LastReply = asi.LastReply,
			AORSR.CRID = asi.CRID,
			AORSR.UpdatedBy = 'WTS',
			AORSR.UpdatedDate = @date
		output inserted.SRID,
			deleted.SubmittedBy,
			inserted.SubmittedBy,
			deleted.SubmittedDate,
			inserted.SubmittedDate,
			deleted.Keywords,
			inserted.Keywords,
			deleted.Websystem,
			inserted.Websystem,
			deleted.[Status],
			inserted.[Status],
			deleted.SRType,
			inserted.SRType,
			deleted.[Priority],
			inserted.[Priority],
			deleted.LCMB,
			inserted.LCMB,
			deleted.ITI,
			inserted.ITI,
			deleted.ITIPOC,
			inserted.ITIPOC,
			deleted.[Description],
			inserted.[Description],
			deleted.LastReply,
			inserted.LastReply,
			deleted.CRID,
			inserted.CRID
		into #UpdatedSRs
		from #AORSRImport asi
		where AORSR.SRID = asi.SRID
		and (
			isnull(AORSR.SubmittedBy, 0) != isnull(asi.SubmittedBy, 0) or
			isnull(AORSR.SubmittedDate, 0) != isnull(asi.SubmittedDate, 0) or
			isnull(AORSR.Keywords, 0) != isnull(asi.Keywords, 0) or
			isnull(AORSR.Websystem, 0) != isnull(asi.Websystem, 0) or
			isnull(AORSR.[Status], 0) != isnull(asi.[Status], 0) or
			isnull(AORSR.SRType, 0) != isnull(asi.SRType, 0) or
			isnull(AORSR.[Priority], 0) != isnull(asi.[Priority], 0) or
			isnull(AORSR.LCMB, 0) != isnull(asi.LCMB, 0) or
			isnull(AORSR.ITI, 0) != isnull(asi.ITI, 0) or
			isnull(AORSR.ITIPOC, 0) != isnull(asi.ITIPOC, 0) or
			isnull(AORSR.[Description], 0) != isnull(asi.[Description], 0) or
			isnull(AORSR.LastReply, 0) != isnull(asi.LastReply, 0) or
			isnull(AORSR.CRID, 0) != isnull(asi.CRID, 0)
		);

		select @totalAfterCountCR = count(1)
		from AORCR;

		select @totalAfterCountSR = count(1)
		from AORSR;

		select @openAfterCountSR = count(1)
		from AORSR
		where upper(isnull([Status], '')) != 'RESOLVED';

		select @closedAfterCountSR = count(1)
		from AORSR
		where upper([Status]) = 'RESOLVED';

		set @html = '<style type="text/css">div,table { font-family: Arial; font-size: 12px; }</style>' +
			'<div>' +
			'<b>Last Import: </b>' + @lastImport + '<br />' +
			'<br /><hr><br /><br />' +
			'<b># of CRs Before Import: </b>' + convert(nvarchar(10), @totalBeforeCountCR) + '<br />' +
			'<b># of CRs Added: </b>' + convert(nvarchar(10), (select count(1) from #InsertedCRs));

			if exists (select * from #InsertedCRs)
				begin
					set @html = @html + '<br />' + (select stuff((select '<br />&nbsp;&nbsp;&nbsp;&nbsp;&#8226;&nbsp;' + [dbo].[Decode](CRName) from #InsertedCRs order by upper([dbo].[Decode](CRName)) for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, '')) + '<br />';
				end;
			
		set @html = @html +
			'<br /><b># of CRs Updated: </b>' + convert(nvarchar(10), (select count(1) from #UpdatedCRs)) + '<br />';

			if exists (select * from #UpdatedCRs)
				begin
					set @html = @html + '<br />';

					declare curUpdatedCRs cursor for
					select *
					from #UpdatedCRs
					order by upper([dbo].[Decode](CRName));

					open curUpdatedCRs

					fetch next from curUpdatedCRs
					into @OldCRName, 
						@CRName, 
						@OldTitle, 
						@Title, 
						@OldNotes, 
						@Notes, 
						@OldWebsystem, 
						@Websystem, 
						@OldCRCSDRequiredNow, 
						@CRCSDRequiredNow, 
						@OldCRRelatedRelease, 
						@CRRelatedRelease, 
						@OldCRSubgroup, 
						@CRSubgroup, 
						@OldCRDesignReview, 
						@CRDesignReview, 
						@OldCRITIPOC, 
						@CRITIPOC, 
						@OldCRCustomerPriorityList, 
						@CRCustomerPriorityList, 
						@OldCRGovernmentCSRD, 
						@CRGovernmentCSRD, 
						@OldCRPrimarySR, 
						@CRPrimarySR

					while @@fetch_status = 0
					begin
						set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&#8226;&nbsp;' + [dbo].[Decode](@CRName) + '<br />';

						if (isnull(@OldCRName, 0) != isnull(@CRName, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>CR Customer Title:</b>&nbsp;' + [dbo].[Decode](isnull(@OldCRName, 'None')) + ' <b>&gt;</b> ' + [dbo].[Decode](isnull(@CRName, 'None')) + '<br />'; end;
						if (isnull(@OldTitle, 0) != isnull(@Title, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>CR Internal Title:</b>&nbsp;' + [dbo].[Decode](isnull(@OldTitle, 'None')) + ' <b>&gt;</b> ' + [dbo].[Decode](isnull(@Title, 'None')) + '<br />'; end;
						--Notes
						if (isnull(@OldWebsystem, 0) != isnull(@Websystem, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Websystem:</b>&nbsp;' + isnull(@OldWebsystem, 'None') + ' <b>&gt;</b> ' + isnull(@Websystem, 'None') + '<br />'; end;
						if (isnull(@OldCRCSDRequiredNow, 0) != isnull(@CRCSDRequiredNow, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>CSD Required Now:</b>&nbsp;' + case when @OldCRCSDRequiredNow = 1 then 'Yes' else 'No' end + ' <b>&gt;</b> ' + case when @CRCSDRequiredNow = 1 then 'Yes' else 'No' end + '<br />'; end;
						if (isnull(@OldCRRelatedRelease, 0) != isnull(@CRRelatedRelease, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Related Release:</b>&nbsp;' + isnull(@OldCRRelatedRelease, 'None') + ' <b>&gt;</b> ' + isnull(@CRRelatedRelease, 'None') + '<br />'; end;
						if (isnull(@OldCRSubgroup, 0) != isnull(@CRSubgroup, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Subgroup:</b>&nbsp;' + isnull(@OldCRSubgroup, 'None') + ' <b>&gt;</b> ' + isnull(@CRSubgroup, 'None') + '<br />'; end;
						if (isnull(@OldCRDesignReview, 0) != isnull(@CRDesignReview, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Design Review:</b>&nbsp;' + isnull(@OldCRDesignReview, 'None') + ' <b>&gt;</b> ' + isnull(@CRDesignReview, 'None') + '<br />'; end;
						if (isnull(@OldCRITIPOC, 0) != isnull(@CRITIPOC, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>ITI POC:</b>&nbsp;' + isnull(lower(@OldCRITIPOC), 'None') + ' <b>&gt;</b> ' + isnull(lower(@CRITIPOC), 'None') + '<br />'; end;
						if (isnull(@OldCRCustomerPriorityList, 0) != isnull(@CRCustomerPriorityList, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Customer Priority List:</b>&nbsp;' + isnull(@OldCRCustomerPriorityList, 'None') + ' <b>&gt;</b> ' +isnull( @CRCustomerPriorityList, 'None') + '<br />'; end;
						if (isnull(@OldCRGovernmentCSRD, 0) != isnull(@CRGovernmentCSRD, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Government CSRD #:</b>&nbsp;' + isnull(convert(nvarchar(10), @OldCRGovernmentCSRD), 'None') + ' <b>&gt;</b> ' + isnull(convert(nvarchar(10), @CRGovernmentCSRD), 'None') + '<br />'; end;
						if (isnull(@OldCRPrimarySR, 0) != isnull(@CRPrimarySR, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Primary SR #:</b>&nbsp;' + isnull(convert(nvarchar(10), @OldCRPrimarySR), 'None') + ' <b>&gt;</b> ' + isnull(convert(nvarchar(10), @CRPrimarySR), 'None') + '<br />'; end;
						
						fetch next from curUpdatedCRs
						into @OldCRName, 
							@CRName, 
							@OldTitle, 
							@Title, 
							@OldNotes, 
							@Notes, 
							@OldWebsystem, 
							@Websystem, 
							@OldCRCSDRequiredNow, 
							@CRCSDRequiredNow, 
							@OldCRRelatedRelease, 
							@CRRelatedRelease, 
							@OldCRSubgroup, 
							@CRSubgroup, 
							@OldCRDesignReview, 
							@CRDesignReview, 
							@OldCRITIPOC, 
							@CRITIPOC, 
							@OldCRCustomerPriorityList, 
							@CRCustomerPriorityList, 
							@OldCRGovernmentCSRD, 
							@CRGovernmentCSRD, 
							@OldCRPrimarySR, 
							@CRPrimarySR
					end;
					close curUpdatedCRs
					deallocate curUpdatedCRs;

					set @html = @html + '<br />';
				end;

		set @html = @html +
			'<b># of CRs Deleted: </b>' + convert(nvarchar(10), (select count(1) from #DeletedCRs));

			if exists (select * from #DeletedCRs)
				begin
					set @html = @html + '<br />' + (select stuff((select '<br />&nbsp;&nbsp;&nbsp;&nbsp;&#8226;&nbsp;' + [dbo].[Decode](CRName) from #DeletedCRs order by upper([dbo].[Decode](CRName)) for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, '')) + '<br />';
				end;

		set @html = @html +
			'<br /><b># of CRs After Import: </b>' + convert(nvarchar(10), @totalAfterCountCR) + '<br />' +
			'<br /><hr><br /><br />' +
			'<b># of SRs Before Import: </b>' + convert(nvarchar(10), @totalBeforeCountSR) + '<br />' +
			'<b># of Open SRs Before Import: </b>' + convert(nvarchar(10), @openBeforeCountSR) + '<br />' +
			'<b># of Closed SRs Before Import: </b>' + convert(nvarchar(10), @closedBeforeCountSR) + '<br />' +
			'<b># of SRs Added: </b>' + convert(nvarchar(10), (select count(1) from #InsertedSRs));

			if exists (select * from #InsertedSRs)
				begin
					set @html = @html + '<br />' + (select stuff((select '<br />&nbsp;&nbsp;&nbsp;&nbsp;&#8226;&nbsp;' + convert(nvarchar(10), SRID) from #InsertedSRs order by SRID for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, '')) + '<br />';
				end;

		set @html = @html +
			'<br /><b># of SRs Updated: </b>' + convert(nvarchar(10), (select count(1) from #UpdatedSRs)) + '<br />';

			if exists (select * from #UpdatedSRs)
				begin
					set @html = @html + '<br />';

					declare curUpdatedSRs cursor for
					select *
					from #UpdatedSRs
					order by SRID;

					open curUpdatedSRs

					fetch next from curUpdatedSRs
					into @SRID, 
						@OldSubmittedBy, 
						@SubmittedBy, 
						@OldSubmittedDate, 
						@SubmittedDate, 
						@OldKeywords, 
						@Keywords, 
						@OldSRWebsystem, 
						@SRWebsystem, 
						@OldStatus, 
						@Status, 
						@OldSRType, 
						@SRType, 
						@OldPriority, 
						@Priority, 
						@OldLCMB,
						@LCMB,
						@OldITI,
						@ITI,
						@OldITIPOC, 
						@ITIPOC, 
						@OldDescription, 
						@Description, 
						@OldLastReply, 
						@LastReply, 
						@OldCRID, 
						@CRID

					while @@fetch_status = 0
					begin
						set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&#8226;&nbsp;' + convert(nvarchar(10), @SRID) + '<br />';

						--SubmittedBy
						--SubmittedDate
						if (isnull(@OldKeywords, 0) != isnull(@Keywords, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Keywords:</b>&nbsp;' + [dbo].[Decode](isnull(@OldKeywords, 'None')) + ' <b>&gt;</b> ' + [dbo].[Decode](isnull(@Keywords, 'None')) + '<br />'; end;
						if (isnull(@OldSRWebsystem, 0) != isnull(@SRWebsystem, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Websystem:</b>&nbsp;' + isnull(@OldSRWebsystem, 'None') + ' <b>&gt;</b> ' + isnull(@SRWebsystem, 'None') + '<br />'; end;
						if (isnull(@OldStatus, 0) != isnull(@Status, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Status:</b>&nbsp;' + isnull(@OldStatus, 'None') + ' <b>&gt;</b> ' + isnull(@Status, 'None') + '<br />'; end;
						if (isnull(@OldSRType, 0) != isnull(@SRType, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>SR Type:</b>&nbsp;' + isnull(@OldSRType, 'None') + ' <b>&gt;</b> ' + isnull(@SRType, 'None') + '<br />'; end;
						if (isnull(@OldPriority, 0) != isnull(@Priority, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>Priority:</b>&nbsp;' + isnull(@OldPriority, 'None') + ' <b>&gt;</b> ' + isnull(@Priority, 'None') + '<br />'; end;
						if (isnull(@OldLCMB, 0) != isnull(@LCMB, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>LCMB:</b>&nbsp;' + case when @OldLCMB = 1 then 'Yes' else 'No' end + ' <b>&gt;</b> ' + case when @LCMB = 1 then 'Yes' else 'No' end + '<br />'; end;
						if (isnull(@OldITI, 0) != isnull(@ITI, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>ITI:</b>&nbsp;' + case when @OldITI = 1 then 'Yes' else 'No' end + ' <b>&gt;</b> ' + case when @ITI = 1 then 'Yes' else 'No' end + '<br />'; end;
						if (isnull(@OldITIPOC, 0) != isnull(@ITIPOC, 0)) begin set @html = @html + '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>ITI POC:</b>&nbsp;' + isnull(lower(@OldITIPOC), 'None') + ' <b>&gt;</b> ' + isnull(lower(@ITIPOC), 'None') + '<br />'; end;
						--Description
						--LastReply
						--CRID

						fetch next from curUpdatedSRs
						into @SRID, 
							@OldSubmittedBy, 
							@SubmittedBy, 
							@OldSubmittedDate, 
							@SubmittedDate, 
							@OldKeywords, 
							@Keywords, 
							@OldSRWebsystem, 
							@SRWebsystem, 
							@OldStatus, 
							@Status, 
							@OldSRType, 
							@SRType, 
							@OldPriority, 
							@Priority, 
							@OldLCMB,
							@LCMB,
							@OldITI,
							@ITI,
							@OldITIPOC, 
							@ITIPOC, 
							@OldDescription, 
							@Description, 
							@OldLastReply, 
							@LastReply, 
							@OldCRID, 
							@CRID
					end;
					close curUpdatedSRs
					deallocate curUpdatedSRs;

					set @html = @html + '<br />';
				end;

		set @html = @html +
			'<b># of SRs Deleted: </b>' + convert(nvarchar(10), (select count(1) from #DeletedSRs));

			if exists (select * from #DeletedSRs)
				begin
					set @html = @html + '<br />' + (select stuff((select '<br />&nbsp;&nbsp;&nbsp;&nbsp;&#8226;&nbsp;' + convert(nvarchar(10), SRID) from #DeletedSRs order by SRID for xml path(''), type).value('.', 'nvarchar(max)'), 1, 0, '')) + '<br />';
				end;

		set @html = @html +
			'<br /><b># of SRs After Import: </b>' + convert(nvarchar(10), @totalAfterCountSR) + '<br />' +
			'<b># of Open SRs After Import: </b>' + convert(nvarchar(10), @openAfterCountSR) + '<br />' +
			'<b># of Closed SRs After Import: </b>' + convert(nvarchar(10), @closedAfterCountSR) + '<br />' +
			'</div>';
	end try
	begin catch
		select @error = error_message();

		set @subject = 'WTS: CAFDEx Sustainment Request Import (Error)';
		set @html = '<style type="text/css">div,table { font-family: Arial; font-size: 12px; }</style>' +
			'<div>' +
			'<b>Error: </b>' + @error + '<br />' +
			'</div>';
	end catch;

	if object_id('tempdb..#AORSRImport') is not null
		begin
			drop table #AORSRImport;
		end;

	if object_id('tempdb..#DeletedCRs') is not null
		begin
			drop table #DeletedCRs;
		end;

	if object_id('tempdb..#InsertedCRs') is not null
		begin
			drop table #InsertedCRs;
		end;

	if object_id('tempdb..#UpdatedCRs') is not null
		begin
			drop table #UpdatedCRs;
		end;

	if object_id('tempdb..#DeletedSRs') is not null
		begin
			drop table #DeletedSRs;
		end;

	if object_id('tempdb..#InsertedSRs') is not null
		begin
			drop table #InsertedSRs;
		end;

	if object_id('tempdb..#UpdatedSRs') is not null
		begin
			drop table #UpdatedSRs;
		end;

	exec msdb.dbo.sp_send_dbmail @profile_name = 'Default'
		, @recipients = 'walkers@infintech.com;porubskyj@infintech.com;baileyn@infintech.com;mendozae@infintech.com;dormanc@infintech.com;harrisd@infintech.com;walkerk@infintech.com;loerao@infintech.com;glazerc@infintech.com;jonssone@infintech.com;waldenh@infintech.com;allisond@infintech.com;jacobsm@infintech.com;belcherm@infintech.com;brandesd@infintech.com;brandym@infintech.com;aneelm@infintech.com;glazerc@infintech.com;taylorj@infintech.com;cobba@infintech.com;sasserb@infintech.com'
		--, @copy_recipients = 'FolsomWorkload@infintech.com'
		, @subject = @subject
		, @body = @html
		, @body_format = 'HTML';

	exec LogEmail_Add @StatusId = 1
		, @Sender = 'FolsomWorkload@infintech.com'
		, @ToAddresses = 'walkers@infintech.com;porubskyj@infintech.com;baileyn@infintech.com;mendozae@infintech.com;dormanc@infintech.com;harrisd@infintech.com;walkerk@infintech.com;loerao@infintech.com;glazerc@infintech.com;jonssone@infintech.com;waldenh@infintech.com;allisond@infintech.com;jacobsm@infintech.com;belcherm@infintech.com;brandesd@infintech.com;brandym@infintech.com;aneelm@infintech.com;glazerc@infintech.com;taylorj@infintech.com;cobba@infintech.com;sasserb@infintech.com'
		--, @CcAddresses = 'FolsomWorkload@infintech.com'
		, @BccAddresses = ''
		, @Subject = @subject
		, @Body = @html
		, @SentDate = @date
		, @Procedure_Used = 'AORSR_Import'
		, @ErrorMessage = @error
		, @CreatedBy = 'SQL Server'
		, @newID = null;
end;
