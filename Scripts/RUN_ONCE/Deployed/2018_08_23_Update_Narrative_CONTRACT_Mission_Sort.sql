use [WTS]
go

update Narrative_CONTRACT
set Sort = 1,
	UpdatedBy = 'WTS',
	UpdatedDate = getdate()
where Sort != 1
and Narrative_CONTRACTID in (54,55,56,67,68);