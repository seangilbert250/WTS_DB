USE WTS
GO

INSERT INTO RQMTAttribute VALUES (3, 'Plan', 'RQMT Stage: Plan', 1, 0, 'WTS_ADMIN', GETDATE(), 'WTS_ADMIN', GETDATE())
INSERT INTO RQMTAttribute VALUES (3, 'Design', 'RQMT Stage: Design', 1, 0, 'WTS_ADMIN', GETDATE(), 'WTS_ADMIN', GETDATE())
INSERT INTO RQMTAttribute VALUES (3, 'Develop', 'RQMT Stage: Develop', 1, 0, 'WTS_ADMIN', GETDATE(), 'WTS_ADMIN', GETDATE())
INSERT INTO RQMTAttribute VALUES (3, 'Test', 'RQMT Stage: Test', 1, 0, 'WTS_ADMIN', GETDATE(), 'WTS_ADMIN', GETDATE())
INSERT INTO RQMTAttribute VALUES (3, 'Deploy', 'RQMT Stage: Deploy', 1, 0, 'WTS_ADMIN', GETDATE(), 'WTS_ADMIN', GETDATE())
INSERT INTO RQMTAttribute VALUES (3, 'Review', 'RQMT Stage: Review', 1, 0, 'WTS_ADMIN', GETDATE(), 'WTS_ADMIN', GETDATE())

UPDATE RQMTSystem SET RQMTStageID = (SELECT RQMTAttributeid FROM RQMTAttribute WHERE RQMTAttribute = 'Deploy') WHERE RQMTStageID = 11

DELETE FROM RQMTAttribute WHERE RQMTAttributeTypeID = 3 AND CreatedDate < '8/1/2018'
