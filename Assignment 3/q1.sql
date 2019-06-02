SET SEARCH_PATH TO quizschema;
DROP TABLE IF EXISTS q1 CASCADE; 

CREATE TABLE q1 (
	studentID VARCHAR(20),
	firstName VARCHAR(100),
	lastName  VARCHAR(100)
);

DROP VIEW IF EXISTS answer CASCADE;

CREATE VIEW answer AS
SELECT sID AS studentID, firstName, lastName
FROM student
ORDER BY studentID;

-- insert the final answer to the table
INSERT INTO q1 SELECT * FROM answer;

SELECT * FROM q1 ORDER BY studentID;
