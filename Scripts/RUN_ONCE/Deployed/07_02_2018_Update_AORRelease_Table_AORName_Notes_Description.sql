use [WTS]
go

UPDATE AORRelease
SET AORName = AOR.AORName,
    Notes = AOR.Notes,
    Description = AOR.Description
FROM AOR
WHERE AORRelease.AORID = AOR.AORID