USE WTS
GO

DECLARE @xml NVARCHAR(MAX) = '<crosswalkparameters><level><breakout><column>RQMT Type</column><sort>Ascending</sort></breakout></level><level><breakout><column>Work Area</column><sort>Ascending</sort></breakout><breakout><column>System</column><sort>Ascending</sort></breakout><breakout><column>RQMT Set</column><sort>Ascending</sort></breakout></level><level><breakout><column>Outline Index</column><sort>Ascending</sort></breakout><breakout><column>RQMT Primary #</column><sort>Ascending</sort></breakout><breakout><column>RQMT Primary</column><sort>Ascending</sort></breakout><breakout><column>RQMT Accepted</column><sort>Ascending</sort></breakout><breakout><column>RQMT Criticality</column><sort>Ascending</sort></breakout><breakout><column>RQMT Stage</column><sort>Ascending</sort></breakout><breakout><column>RQMT Status</column><sort>Ascending</sort></breakout><breakout><column>RQMT Defects</column><sort>Ascending</sort></breakout></level><level><breakout><column>Outline Index</column><sort>Ascending</sort></breakout><breakout><column>RQMT #</column><sort>Ascending</sort></breakout><breakout><column>RQMT</column><sort>Ascending</sort></breakout><breakout><column>RQMT Accepted</column><sort>Ascending</sort></breakout><breakout><column>RQMT Criticality</column><sort>Ascending</sort></breakout><breakout><column>RQMT Stage</column><sort>Ascending</sort></breakout><breakout><column>RQMT Status</column><sort>Ascending</sort></breakout><breakout><column>RQMT Defects</column><sort>Ascending</sort></breakout></level></crosswalkparameters>'

IF NOT EXISTS (SELECT 1 FROM GridView WHERE ViewName = 'TaskEditRQMTView')
BEGIN
	INSERT INTO GridView VALUES(13, 23, 'TaskEditRQMTView', 0, 0, 'WTS_ADMIN', GETDATE(), 'WTS_ADMIN', GETDATE(), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, @xml, 0)
END
ELSE
BEGIN
	UPDATE GridView SET SectionsXML = @xml WHERE ViewName = 'TaskEditRQMTView'
END