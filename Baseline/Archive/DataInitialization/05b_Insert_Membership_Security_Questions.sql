USE WTS
GO

INSERT INTO PASSWORD_QUESTION(PASSWORD_QUESTION, ARCHIVE)
SELECT 'What was the make and model of your first car?', 0 UNION ALL
SELECT 'What is your first pet''s name?', 0 UNION ALL
SELECT 'What was your high school mascot?', 0 UNION ALL
SELECT 'What year did you graduate from High School?', 0 UNION ALL
SELECT 'What was your childhood nickname?', 0 UNION ALL
SELECT 'What is your grandmother''s first name?', 0 UNION ALL
SELECT 'What is your mother''s maiden name?', 0 UNION ALL
SELECT 'What is the name of the company of your first job?', 0 UNION ALL
SELECT 'What is the middle name of your oldest child?', 0 UNION ALL
SELECT 'What was your childhood nickname?', 0
EXCEPT
SELECT PASSWORD_QUESTION, ARCHIVE FROM PASSWORD_QUESTION

GO