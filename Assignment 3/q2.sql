SET SEARCH_PATH TO quizschema;
DROP TABLE IF EXISTS q2 CASCADE; 

CREATE TABLE q2 (
	qID INT,
	qText VARCHAR(1000),
	numberHint INT
);

DROP VIEW IF EXISTS TF, MC, NU CASCADE;

-- for true/false question, no numberHint
CREATE VIEW TF AS
SELECT qID, qText
FROM question
WHERE qType = 'True-False';

-- for multiple choice, natural join with question and count the number of hint
CREATE VIEW MC AS
SELECT question.qID, question.qText, count(hint) AS numberHint
FROM question, Multiple_Choice
WHERE question.qID = Multiple_Choice.qID AND question.qType = 'Multiple-choice'
GROUP BY question.qID, question.qText;

-- for numeric, its similiar to the multiple choice, use count and group by
CREATE VIEW NU AS
SELECT question.qID, question.qText, count(hint) AS numberHint
FROM question, Numeric
WHERE question.qID = Numeric.qID AND question.qType = 'Numeric'
GROUP BY question.qID, question.qText;

-- insert three views into the table one by one
INSERT INTO q2 SELECT qID, qText, NULL AS numberHint FROM TF;
INSERT INTO q2 SELECT * FROM MC;
INSERT INTO q2 SELECT * FROM NU;

SELECT * FROM q2 ORDER BY qID;
