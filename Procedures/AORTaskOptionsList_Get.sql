USE [WTS]
GO

/****** Object:  StoredProcedure [dbo].[AORTaskOptionsList_Get]    Script Date: 7/5/2018 4:23:36 PM ******/
DROP PROCEDURE [dbo].[AORTaskOptionsList_Get]
GO

/****** Object:  StoredProcedure [dbo].[AORTaskOptionsList_Get]    Script Date: 7/5/2018 4:23:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[AORTaskOptionsList_Get]
	@AssignedToID int = 0,
	@PrimaryResourceID int = 0,
	@SystemID int = 0,
	@SystemAffiliated bit = 0,
	@ResourceAffiliated bit = 0,
	@AssignedToRankID int = 0,
	@All bit = 0
as
begin
	declare @sql nvarchar(max) = '';
	declare @applySystemFilter bit = 0;
	declare @applyResourceFilter bit = 0;

	if (@SystemAffiliated = 1 and @SystemID != 0) set @applySystemFilter = 1;
	if (@ResourceAffiliated = 1 and (@AssignedToID != 0 or @PrimaryResourceID != 0)) set @applyResourceFilter = 1;

	set @sql = '
		select *
		from (
			select distinct AOR.AORID,
				arl.AORName,
				arl.AORReleaseID,
				ps.WorkloadAllocationID,
				isnull(ps.[WorkloadAllocation], '''') as WorkloadAllocation,
				isnull(nullif(ps.Abbreviation, ''''), ''O'') as WorkloadAllocationAbbreviation,
				isnull(awt.AORWorkTypeName, ''No AOR Type'') as AORType';
				
			if (@All = 1)
				begin
					set @sql = @sql + ',
						wsy.WTS_SYSTEMID,
						isnull(wsy.WTS_SYSTEM,''No System'') as WTS_SYSTEM';
				end;

			set @sql = @sql + '
				from AOR
				join AORRelease arl
				on AOR.AORID = arl.AORID
				left join AORReleaseResource arr
				on arl.AORReleaseID = arr.AORReleaseID
				left join AORReleaseSystem ars
				on arl.AORReleaseID = ars.AORReleaseID
				left join WTS_SYSTEM wsy
				on ars.WTS_SYSTEMID = wsy.WTS_SYSTEMID
				left join [WorkloadAllocation] ps
				on arl.WorkloadAllocationID = ps.WorkloadAllocationID
				left join AORWorkType awt
				on arl.AORWorkTypeID = awt.AORWorkTypeID
				where AOR.Archive = 0
				and arl.[Current] = 1';

			if (@All != 1)
				begin
					if (@applySystemFilter = 1)
						begin
							set @sql = @sql + ' and ';

							if (@applyResourceFilter = 1) set @sql = @sql + '(';

							set @sql = @sql + 'ars.WTS_SYSTEMID = ' + convert(nvarchar(10), @SystemID);
							if (@AssignedToRankID != 31 and @AssignedToRankID != 0) set @sql = @sql + 'or ((AOR.AORID = 341 or AOR.AORID = 356 or AOR.AORID = 357) and arl.[Current] = 1) ';
						end;

					if (@applyResourceFilter = 1)
						begin
							if (@applySystemFilter = 1)
								begin
									set @sql = @sql + ' or ';
								end;
							else
								begin
									set @sql = @sql + ' and ';
								end;

							set @sql = @sql + 'arr.WTS_RESOURCEID in (' + convert(nvarchar(10), @AssignedToID) + ',' + convert(nvarchar(10), @PrimaryResourceID) + ')';

							if (@applySystemFilter = 1) set @sql = @sql + ')';
						end;
				end;

	set @sql = @sql + '
		) a
		order by a.AORType DESC, ';

	if (@AssignedToRankID != 31 and @AssignedToRankID != 0 and @All != 1) set @sql = @sql + 'a.AORID DESC, ';
	
	if (@All = 1) set @sql = @sql + 'case when a.WTS_SYSTEM = ''No System'' then 1 else 0 end, upper(a.WTS_SYSTEM), ';

	set @sql = @sql + 'case upper(a.WorkloadAllocation) when ''RELEASE'' then 0 when ''PRODUCTION'' then 1 else 2 end, upper(a.AORName)';

	execute sp_executesql @sql;
end;

SELECT 'Executing File [Procedures\Check_User_Reports_Exists.sql]';
GO
