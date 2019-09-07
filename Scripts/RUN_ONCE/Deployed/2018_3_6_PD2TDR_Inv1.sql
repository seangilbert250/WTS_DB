use [WTS]
go

update AORRelease
set InvestigationStatusID = (
	select s.STATUSID
	from [STATUS] s
	join StatusType st
	on s.StatusTypeID = st.StatusTypeID
	where s.[STATUS] = 'Inv1'
	and st.StatusType = 'Inv'
)
where exists (
	select 1
	from AORWorkType awt
	where awt.AORWorkTypeName in ('MGMT Release', 'PD2TDR Managed AORs')
	and AORRelease.AORWorkTypeID = awt.AORWorkTypeID
)
and InvestigationStatusID is null
and TechnicalStatusID is null
and CustomerDesignStatusID is null
and CodingStatusID is null
and InternalTestingStatusID is null
and CustomerValidationTestingStatusID is null
and AdoptionStatusID is null;