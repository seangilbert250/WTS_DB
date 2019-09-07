UPDATE RQMTAttribute SET SortOrder = 1 WHERE RQMTAttributeTypeID = 1 AND RQMTAttribute = 'Critical'
UPDATE RQMTAttribute SET SortOrder = 2 WHERE RQMTAttributeTypeID = 1 AND RQMTAttribute = 'Major'
UPDATE RQMTAttribute SET SortOrder = 3 WHERE RQMTAttributeTypeID = 1 AND RQMTAttribute = 'Minor'
UPDATE RQMTAttribute SET SortOrder = 4 WHERE RQMTAttributeTypeID = 1 AND RQMTAttribute = 'DNT'