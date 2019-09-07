USE WTS
GO

DECLARE @xml NVARCHAR(MAX) = '<crosswalkparameters><level><breakout><column>System</column><sort>Ascending</sort></breakout><breakout><column>Work Area</column><sort>Ascending</sort></breakout><breakout><column>RQMT Type</column><sort>Ascending</sort></breakout><breakout><column>RQMT Set</column><sort>Ascending</sort></breakout><breakout><column>RQMT Metrics</column><sort>Ascending</sort></breakout></level><level><breakout><column>Outline Index</column><sort>Ascending</sort></breakout><breakout><column>RQMT Primary #</column><sort>Ascending</sort></breakout><breakout><column>RQMT Primary</column><sort>Ascending</sort></breakout><breakout><column>RQMT #</column><sort>Ascending</sort></breakout><breakout><column>RQMT</column><sort>Ascending</sort></breakout><breakout><column>RQMT Defect Number</column><sort>Ascending</sort></breakout><breakout><column>RQMT Defect Description</column><sort>Ascending</sort></breakout><breakout><column>RQMT Defect Impact</column><sort>Ascending</sort></breakout><breakout><column>RQMT Defect Stage</column><sort>Ascending</sort></breakout><breakout><column>RQMT Defect Verified</column><sort>Ascending</sort></breakout><breakout><column>RQMT Defect Resolved</column><sort>Ascending</sort></breakout><breakout><column>RQMT Defect Review</column><sort>Ascending</sort></breakout><breakout><column>RQMT Defect Mitigation</column><sort>Ascending</sort></breakout></level></crosswalkparameters>'

IF NOT EXISTS (SELECT 1 FROM GridView WHERE ViewName = 'RQMT Defect Metrics')
BEGIN
	INSERT INTO GridView VALUES(13, NULL, 'RQMT Defect Metrics', 0, 0, 'WTS_ADMIN', GETDATE(), 'WTS_ADMIN', GETDATE(), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, @xml, 0)
END
ELSE
BEGIN
	UPDATE GridView SET SectionsXML = @xml WHERE ViewName = 'RQMT Defect Metrics'
END