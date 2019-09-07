use [WTS]
go

if exists (select * from sysobjects where id = object_id('[dbo].[AORCRLookupMetrics_Get]') and objectproperty(id, 'IsProcedure') = 1)
drop procedure [dbo].[AORCRLookupMetrics_Get]
go

set ansi_nulls on
go
set quoted_identifier on
go

create procedure [dbo].[AORCRLookupMetrics_Get]
	@CRContract nvarchar(255) = ''
as
begin
	with crs as (
		select acr.CRID, upper(isnull(s.[STATUS], '')) as [STATUS], acr.Imported
		from AORCR acr
		left join [STATUS] s
		on acr.StatusID = s.STATUSID
		where (@CRContract = '' or charindex(',' + convert(nvarchar(10), isnull(acr.ContractID, 0)) + ',', ',' + @CRContract + ',') > 0)
	),
	srs as (
		select asr.SRID, upper(isnull(asr.[Status], '')) as [Status], asr.Imported
		from AORSR asr
		join AORCR acr
		on asr.CRID = acr.CRID
		where (@CRContract = '' or charindex(',' + convert(nvarchar(10), isnull(acr.ContractID, 0)) + ',', ',' + @CRContract + ',') > 0)
	)
	select '# of CRs' as Metric,
		count(1) as Value
	from crs
	union all
	select '# of Open CRs' as Metric,
		count(1) as Value
	from crs
	where crs.[STATUS] != 'RESOLVED'
	union all
	select '# of Closed CRs' as Metric,
		count(1) as Value
	from crs
	where crs.[STATUS] = 'RESOLVED'
	union all
	select '# of Imported CRs' as Metric,
		count(1) as Value
	from crs
	where crs.Imported = 1
	union all
	select '# of Added CRs' as Metric,
		count(1) as Value
	from crs
	where crs.Imported = 0
	union all
	select '# of SRs' as Metric,
		count(1) as Value
	from srs
	union all
	select '# of Open SRs' as Metric,
		count(1) as Value
	from srs
	where srs.[Status] != 'RESOLVED'
	union all
	select '# of Closed SRs' as Metric,
		count(1) as Value
	from srs
	where srs.[Status] = 'RESOLVED'
	union all
	select '# of Imported SRs' as Metric,
		count(1) as Value
	from srs
	where srs.Imported = 1
	union all
	select '# of Added SRs' as Metric,
		count(1) as Value
	from srs
	where srs.Imported = 0
	union all
	select '# of SRs With Task' as Metric,
		count(distinct srs.SRID) as Value
	from srs
	join WORKITEM wi
	on srs.SRID = wi.SR_Number
	union all
	select '# of SRs Without Task' as Metric,
		count(srs.SRID) as Value
	from srs
	where not exists (
		select 1
		from WORKITEM wi
		where wi.SR_Number = srs.SRID
	);
end;
