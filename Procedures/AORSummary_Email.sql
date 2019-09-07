use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORSummary_Email]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORSummary_Email]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORSummary_Email]
as
begin
	set nocount on;

	declare @date datetime;

	declare @openCountCR int = 0;
	declare @openCountSR int = 0;
	declare @openCountCRWithoutAOR int = 0;
	declare @openCountSRWithoutTask int = 0;

	declare @CRID int;
	declare @CRName nvarchar(255);
	declare @CRStatus nvarchar(255);

	declare @AORName nvarchar(255);
	declare @AORLoopCount int = 0;

	declare @SRCount int = 0;
	declare @SRID int;
	declare @SubmittedBy nvarchar(255);
	declare @SubmittedDate nvarchar(255);
	--declare @SRWebsystem nvarchar(255); --on cafdex email; group by suite?
	declare @Status nvarchar(255);
	declare @Priority nvarchar(255);
	--declare @ITIPOC nvarchar(255); --on cafdex email
	declare @Description nvarchar(max);
	declare @LastReply nvarchar(max);
	declare @SRLoopCount int = 0;

	declare @TaskCount int = 0;
	declare @TaskID int;
	declare @TaskStatus nvarchar(50);
	declare @Assigned nvarchar(50);
	--declare @TaskPriority nvarchar(50); --on cafdex email
	--declare @System nvarchar(50); --on cafdex email
	--declare @PrimaryBusinessResource nvarchar(50); --on cafdex email
	--declare @Title nvarchar(150); --on cafdex email
	declare @TaskLoopCount int = 0;

	declare @subject nvarchar(4000) = 'WTS: AOR Summary';
	declare @html nvarchar(max);
	declare @error nvarchar(4000) = '';

	set @date = getdate();

	begin try
		select @openCountCR = count(1)
		from AORCR acr
		left join [STATUS] s
		on acr.StatusID = s.STATUSID
		where upper(isnull(s.[STATUS], '')) != 'RESOLVED';

		select @openCountSR = count(1)
		from AORSR
		where upper(isnull([Status], '')) != 'RESOLVED';

		select @openCountCRWithoutAOR = @openCountCR - count(distinct acr.CRID)
		from AORCR acr
		left join [STATUS] s
		on acr.StatusID = s.STATUSID
		join AORReleaseCR arc
		on acr.CRID = arc.CRID
		join AORRelease arl
		on arc.AORReleaseID = arl.AORReleaseID
		join AOR
		on arl.AORID = AOR.AORID
		where upper(isnull(s.[STATUS], '')) != 'RESOLVED'
		and arl.[Current] = 1
		and AOR.Archive = 0;

		select @openCountSRWithoutTask = count(1)
		from AORSR asr
		where upper(isnull(asr.[Status], '')) != 'RESOLVED'
		and not exists (
			select 1
			from WORKITEM wi
			where wi.SR_Number = asr.SRID
		);

		set @html = '<style type="text/css">div,table { font-family: Arial; font-size: 12px; } table { border-collapse: collapse; } th { padding: 5px 0px; background-color: #d7daf2; }</style>' +
			'<div>' +
			'<b># of Open CRs: </b>' + convert(nvarchar(10), @openCountCR) + '<br />' +
			'<b># of Open SRs: </b>' + convert(nvarchar(10), @openCountSR) + '<br />' +
			'<b># of Open CRs Without AOR: </b>' + convert(nvarchar(10), @openCountCRWithoutAOR) + '<br />' +
			'<b># of Open SRs Without Task: </b>' + convert(nvarchar(10), @openCountSRWithoutTask) + '<br />' +
			'<br /><hr><br /><br />' +
			'<b>Open CRs/SRs/Tasks:</b><br /><br />';

		--CR loop
		declare curCRs cursor for
		select *
		from (
			select distinct acr.CRID,
				acr.CRName,
				s.[STATUS]
			from AORCR acr
			left join [STATUS] s
			on acr.StatusID = s.STATUSID
			join AORSR asr
			on acr.CRID = asr.CRID
			where (upper(isnull(s.[STATUS], '')) != 'RESOLVED' or upper(isnull(asr.[Status], '')) != 'RESOLVED')
		) a
		order by upper(a.CRName);

		open curCRs

		fetch next from curCRs
		into @CRID, 
			@CRName,
			@CRStatus

		while @@fetch_status = 0
		begin
			set @html = @html + '<table cellpadding="0" cellspacing="0" style="width: 50%; border: 1px solid gray;">' +
				'<tr><th>CR</th></tr>' +
				'<tr><td style="padding: 5px;">' + [dbo].[Decode](@CRName) + case when upper(@CRStatus) = 'RESOLVED' then ' (Closed - Contains Open SR)' else '' end + '</td></tr>';

				--AOR loop
				set @html = @html + '<tr><td>' +
					'<table cellpadding="0" cellspacing="0" style="width: 100%;">' +
					'<tr><th>AOR</th></tr>';
				
				declare curAORs cursor for
				select *
				from (
					select distinct arl.AORName
					from AOR
					join AORRelease arl
					on AOR.AORID = arl.AORID
					join AORReleaseCR arc
					on arl.AORReleaseID = arc.AORReleaseID
					where AOR.Archive = 0
					and arl.[Current] = 1
					and arc.CRID = @CRID
				) a
				order by upper(a.AORName);

				open curAORs

				fetch next from curAORs
				into @AORName

				while @@fetch_status = 0
				begin
					set @html = @html + '<tr><td style="padding: 5px;">' + @AORName + '</td></tr>';
					set @AORLoopCount = @AORLoopCount + 1;

					fetch next from curAORs
					into @AORName
				end;
				close curAORs
				deallocate curAORs;
				
				if (@AORLoopCount = 0)
					begin
						set @html = @html + '<tr><td style="padding: 5px;">--</td></tr>';
					end;

				set @html = @html + '</table></td></tr>';
				--end AOR loop

				--SR loop
				select @SRCount = count(1)
				from AORSR
				where CRID = @CRID
				and upper(isnull([Status], '')) != 'RESOLVED';

				set @html = @html + '<tr><td>' +
					'<table cellpadding="0" cellspacing="0" style="width: 100%;">' +
					'<tr><th colspan="2">SR</th></tr>';

				declare curSRs cursor for
				select SRID,
					SubmittedBy,
					SubmittedDate,
					[Status],
					[Priority],
					[Description],
					LastReply
				from AORSR
				where CRID = @CRID
				and upper(isnull([Status], '')) != 'RESOLVED'
				order by SRID desc;

				open curSRs

				fetch next from curSRs
				into @SRID,
					@SubmittedBy,
					@SubmittedDate,
					@Status,
					@Priority,
					@Description,
					@LastReply

				while @@fetch_status = 0
				begin
					begin try
						set @Description = isnull([dbo].[Decode](@Description), '');
					end try
					begin catch
						set @Description = isnull(@Description, '');
					end catch;

					begin try
						set @LastReply = isnull([dbo].[Decode](@LastReply), '');
					end try
					begin catch
						set @LastReply = isnull(@LastReply, '');
					end catch;

					set @html = @html + '<tr><td style="padding: 5px;"><b>SR #:</b>&nbsp;' + convert(nvarchar(10), @SRID) + '</td><td style="text-align: right; padding: 5px;"><b>Submitted By:</b>&nbsp;' + lower(@SubmittedBy) + '&nbsp;&nbsp;&nbsp;<b>Submitted Date:</b>&nbsp;' + @SubmittedDate + '</td></tr>' +
						'<tr><td colspan="2" style="padding: 5px;"><b>Status:</b>&nbsp;' + @Status + '</td></tr>' +
						'<tr><td colspan="2" style="padding: 5px;"><b>Priority:</b>&nbsp;' + @Priority +  '</td></tr>' +
						'<tr><td colspan="2" style="padding: 5px;"><b>Description:</b>&nbsp;' + case when len(@Description) > 65 then substring(@Description, 1, 65) + '...' else @Description end + '</td></tr>' +
						'<tr><td colspan="2" style="padding: 5px;"><b>Last Reply:</b>&nbsp;' + case when len(@LastReply) > 65 then substring(@LastReply, 1, 65) + '...' else @LastReply end + '</td></tr>';
						
						--Task loop
						select @TaskCount = count(1)
						from WORKITEM wi
						join [STATUS] s
						on wi.STATUSID = s.STATUSID
						where wi.SR_Number = @SRID
						and upper(s.[STATUS]) != 'CLOSED';

						set @html = @html + '<tr><td colspan="2" style="padding-left: 25px;">' +
							'<table cellpadding="0" cellspacing="0" style="width: 100%;">' +
							'<tr><th>Task</th></tr>';
				
						declare curTasks cursor for
						select wi.WORKITEMID,
							ato.USERNAME,
							s.[STATUS]
						from WORKITEM wi
						join WTS_RESOURCE ato
						on wi.ASSIGNEDRESOURCEID = ato.WTS_RESOURCEID
						join [STATUS] s
						on wi.STATUSID = s.STATUSID
						where wi.SR_Number = @SRID
						and upper(s.[STATUS]) != 'CLOSED'
						order by wi.WORKITEMID desc;

						open curTasks

						fetch next from curTasks
						into @TaskID,
							@Assigned,
							@TaskStatus
						
						while @@fetch_status = 0
						begin
							set @html = @html + '<tr><td style="padding: 5px; border-left: 1px solid gray;"><b>Task #:</b>&nbsp;' + convert(nvarchar(10), @TaskID) + '</td></tr>' +
								'<tr><td style="padding: 5px; border-left: 1px solid gray;"><b>Assigned To:</b>&nbsp;' + @Assigned + '</td></tr>' +
								'<tr><td style="padding: 5px; border-left: 1px solid gray;' + case when (@SRLoopCount + 1) = @SRCount and (@TaskLoopCount + 1) = @TaskCount then '' else ' border-bottom: 1px solid gray;' end + '"><b>Status:</b>&nbsp;' + @TaskStatus + '</td></tr>';

							set @TaskLoopCount = @TaskLoopCount + 1;

							fetch next from curTasks
							into @TaskID,
								@Assigned,
								@TaskStatus
						end;
						close curTasks
						deallocate curTasks;
				
						if (@TaskLoopCount = 0)
							begin
								set @html = @html + '<tr><td style="padding: 5px; border-left: 1px solid gray;' + case when (@SRLoopCount + 1) = @SRCount then '' else ' border-bottom: 1px solid gray;' end + '">--</td></tr>';
							end;

						set @html = @html + '</table></td></tr>';
						set @TaskLoopCount = 0;
						--end Task loop

						set @SRLoopCount = @SRLoopCount + 1;

					fetch next from curSRs
					into @SRID,
						@SubmittedBy,
						@SubmittedDate,
						@Status,
						@Priority,
						@Description,
						@LastReply
				end;
				close curSRs
				deallocate curSRs;
				
				if (@SRLoopCount = 0)
					begin
						set @html = @html + '<tr><td style="padding: 5px;">--</td></tr>';
					end;

				set @html = @html + '</table></td></tr>';
				set @SRLoopCount = 0;
				--end SR loop
				
			set @html = @html + '</table><br /><br />';
			set @AORLoopCount = 0;

			fetch next from curCRs
			into @CRID,
				@CRName,
				@CRStatus
		end;
		close curCRs
		deallocate curCRs;
		--end CR loop

		set @html = @html + '</div>';
	end try
	begin catch
		select @error = error_message();

		set @subject = 'WTS: AOR Summary (Error)';
		set @html = '<style type="text/css">div,table { font-family: Arial; font-size: 12px; }</style>' +
			'<div>' +
			'<b>Error: </b>' + @error + '<br />' +
			'</div>';
	end catch;

	exec msdb.dbo.sp_send_dbmail @profile_name = 'Default'
		, @recipients = 'walkers@infintech.com;porubskyj@infintech.com;baileyn@infintech.com;mendozae@infintech.com;dormanc@infintech.com;harrisd@infintech.com;walkerk@infintech.com;loerao@infintech.com;glazerc@infintech.com;jonssone@infintech.com;waldenh@infintech.com;allisond@infintech.com;jacobsm@infintech.com;belcherm@infintech.com;brandesd@infintech.com'
		--, @copy_recipients = 'FolsomWorkload@infintech.com'
		, @subject = @subject
		, @body = @html
		, @body_format = 'HTML';

	exec LogEmail_Add @StatusId = 1
		, @Sender = 'FolsomWorkload@infintech.com'
		, @ToAddresses = 'walkers@infintech.com;porubskyj@infintech.com;baileyn@infintech.com;mendozae@infintech.com;dormanc@infintech.com;harrisd@infintech.com;walkerk@infintech.com;loerao@infintech.com;glazerc@infintech.com;jonssone@infintech.com;waldenh@infintech.com;allisond@infintech.com;jacobsm@infintech.com;belcherm@infintech.com;brandesd@infintech.com'
		--, @CcAddresses = 'FolsomWorkload@infintech.com'
		, @BccAddresses = ''
		, @Subject = @subject
		, @Body = @html
		, @SentDate = @date
		, @Procedure_Used = 'AORSummary_Email'
		, @ErrorMessage = @error
		, @CreatedBy = 'SQL Server'
		, @newID = null;
end;
