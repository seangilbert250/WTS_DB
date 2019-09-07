use [WTS]
go

INSERT INTO STATUS(
    StatusTypeID,
    STATUS,
    DESCRIPTION,
    SORT_ORDER
    )
    VALUES (
    8,
    'Issue',
    'Reviewed/Concern',
    3
    );

INSERT INTO STATUS(
    StatusTypeID,
    STATUS,
    DESCRIPTION,
    SORT_ORDER
    )
    VALUES (
    8,
    'POAM',
    'Mitigated Issue',
    4
    );

INSERT INTO STATUS(
    StatusTypeID,
    STATUS,
    DESCRIPTION,
    SORT_ORDER
    )
    VALUES (
    8,
    'Rev Rqd',
    'Not Reviewed',
    5
    );

UPDATE STATUS
SET
    StatusTypeID = 8,
    STATUS = 'Not Rqs',
    DESCRIPTION = 'Not Required',
    SORT_ORDER = 1
WHERE
    STATUSID = 55;

UPDATE STATUS
SET
    StatusTypeID = 8,
    STATUS = 'No Risk',
    DESCRIPTION = 'Reviewed/No Risk',
    SORT_ORDER = 2
WHERE
    STATUSID = 56;

DECLARE @CyberID int = 0

SELECT @CyberID = STATUSID
FROM STATUS
WHERE STATUS = 'No Risk'

UPDATE AORRelease
SET
    CyberID = @CyberID
WHERE
    CyberID = 0;

SELECT @CyberID = STATUSID
FROM STATUS
WHERE STATUS = 'Issue'

UPDATE AORRelease
SET
    CyberID = @CyberID
WHERE
    CyberID = 1;

SELECT @CyberID = STATUSID
FROM STATUS
WHERE STATUS = 'Not Rqs'

UPDATE AORRelease
SET
    CyberID = @CyberID
WHERE
    CyberID = 2;

SELECT @CyberID = STATUSID
FROM STATUS
WHERE STATUS = 'Rev Rqd'

UPDATE AORRelease
SET
    CyberID = @CyberID
WHERE
    CyberID IS NULL;