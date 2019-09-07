use [WTS]
go

INSERT INTO AORRelease_History
(
    ITEM_UPDATETYPEID,
    AORReleaseID,
    FieldChanged,
    OldValue,
    NewValue,
    CREATEDBY,
    CREATEDDATE
)
SELECT
    1,
    arl.AORReleaseID,
    CASE WHEN arl.SourceProductVersionID > 0 THEN 'Previous Release' ELSE 'AOR Release' END,
    (select pv.ProductVersion from ProductVersion pv where arl.SourceProductVersionID = pv.ProductVersionID),
    (select pv.ProductVersion from ProductVersion pv where arl.ProductVersionID = pv.ProductVersionID),
    arl.CreatedBy,
    arl.CreatedDate
FROM AORRelease arl
