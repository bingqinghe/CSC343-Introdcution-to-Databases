SET SEARCH_PATH TO quizschema;
DROP TABLE IF EXISTS q5 CASCADE; 

CREATE TABLE q5 (
	qID VARCHAR(100),
	correct INT,
	wrong INT,
	noResponse INT
); 

DROP VIEW IF EXISTS candidate, questionInQuiz, tookQuiz CASCADE; 
DROP VIEW IF EXISTS noAnswerMC, noAnswerTF, noAnswerNU CASCADE;
DROP VIEW IF EXISTS correctMC, correctTF, correctNU CASCADE;
DROP VIEW IF EXISTS getMC, getTF, getNU CASCADE;


-- find the Gr8 students in Rm120 with Mr Higgins
CREATE VIEW candidate AS
SELECT student.sID, class.cID
FROM student, class
WHERE student.cID = class.cID AND class.roomID = 120 AND class.grade = 8 AND class.teacher = 'Mr Higgins';

-- find all the questions in the quiz
CREATE VIEW questionInQuiz AS
SELECT DISTINCT quiz_question.quizID, quiz_question.qID
FROM quiz_question, candidate
WHERE quiz_question.quizID = 'Pr1-220310' AND quiz_question.cID = candidate.cID;

-- find how many student actually took that quiz
CREATE VIEW tookQuiz AS
SELECT quiz_question.quizID, count(DISTINCT candidate.sID) AS totalStudent
FROM quiz_question, candidate
WHERE quiz_question.cID = candidate.cID AND quiz_question.quizID = 'Pr1-220310'
GROUP BY quiz_question.quizID;


-- as in q4.sql, we have counted how many student did not answer the questions
-- find all the qudents and the questions they DO NOT answer
-- seperate into three part
-- first is multiple-choice
CREATE VIEW noAnswerMC AS
SELECT Multiple_Choice_Answer.quizID, Multiple_Choice_Answer.qID, count(candidate.sID) AS noResponse
FROM candidate, Multiple_Choice_Answer, questionInQuiz
WHERE candidate.sID = Multiple_Choice_Answer.sID 
	AND Multiple_Choice_Answer.quizID = questionInQuiz.quizID
	AND Multiple_Choice_Answer.qID = questionInQuiz.qID
	AND Multiple_Choice_Answer.answer IS NULL
GROUP BY Multiple_Choice_Answer.quizID, Multiple_Choice_Answer.qID;
	
-- second is true-false
-- a little bit different coz the answer is in boolean type
CREATE VIEW noAnswerTF AS
SELECT True_False_Answer.quizID, True_False_Answer.qID, count(candidate.sID) AS noResponse
FROM candidate LEFT JOIN True_False_Answer 
	ON candidate.sID = True_False_Answer.sID
	JOIN questionInQuiz
		ON True_False_Answer.quizID = questionInQuiz.quizID
			AND True_False_Answer.qID = questionInQuiz.qID
			AND True_False_Answer.answer IS UNKNOWN
GROUP BY True_False_Answer.quizID, True_False_Answer.qID;

-- last is numeric
CREATE VIEW noAnswerNU AS
SELECT Numeric_Answer.quizID, Numeric_Answer.qID, count(candidate.sID) AS noResponse
FROM candidate, Numeric_Answer, questionInQuiz
WHERE candidate.sID = Numeric_Answer.sID 
	AND Numeric_Answer.quizID = questionInQuiz.quizID
	AND Numeric_Answer.qID = questionInQuiz.qID
	AND Numeric_Answer.answer IS NULL
GROUP BY Numeric_Answer.quizID, Numeric_Answer.qID;



-- now we find right answers
-- find each questions' correct answers
-- sperate into three different types
-- first is multiple-choice
CREATE VIEW correctMC AS
SELECT questionInQuiz.quizID, Multiple_Choice.qID, option AS answer
FROM questionInQuiz, question, Multiple_Choice
WHERE question.qType = 'Multiple-choice' AND questionInQuiz.qID = question.qID AND question.qID = Multiple_Choice.qID AND Multiple_Choice.ifCorrect = TRUE;

-- second is true or false
CREATE VIEW correctTF AS
SELECT questionInQuiz.quizID, True_False.qID, True_False.answer
FROM questionInQuiz, question, True_False
WHERE question.qType = 'True-False' AND questionInQuiz.qID = question.qID AND question.qID = True_False.qID;

-- last one is numeric
CREATE VIEW correctNU AS
SELECT questionInQuiz.quizID, Numeric.qID, Numeric.answer
FROM questionInQuiz, question, Numeric
WHERE question.qType = 'Numeric' AND questionInQuiz.qID = question.qID AND question.qID = Numeric.qID;

-- check if student get correct answers
-- sperate into htree different types
-- first is multiple-choice
CREATE VIEW getMC AS
SELECT correctMC.quizID, correctMC.qID, count(DISTINCT candidate.sID) AS correct
FROM candidate, Multiple_Choice_Answer, correctMC
WHERE candidate.sID = Multiple_Choice_Answer.sID 
	AND Multiple_Choice_Answer.quizID = correctMC.quizID
	AND Multiple_Choice_Answer.qID = correctMC.qID
	AND Multiple_Choice_Answer.answer = correctMC.answer
GROUP BY correctMC.quizID, correctMC.qID;

-- second is true-false
CREATE VIEW getTF AS
SELECT correctTF.quizID, correctTF.qID, count(DISTINCT candidate.sID) AS correct
FROM candidate, True_False_Answer, correctTF
WHERE candidate.sID = True_False_Answer.sID 
	AND True_False_Answer.quizID = correctTF.quizID
	AND True_False_Answer.qID = correctTF.qID
	AND True_False_Answer.answer = correctTF.answer
GROUP BY correctTF.quizID, correctTF.qID;

-- last is numeric
CREATE VIEW getNU AS
SELECT correctNU.quizID, correctNU.qID, count(DISTINCT candidate.sID) AS correct
FROM candidate, Numeric_Answer, correctNU
WHERE candidate.sID = Numeric_Answer.sID 
	AND Numeric_Answer.quizID = correctNU.quizID
	AND Numeric_Answer.qID = correctNU.qID
	AND Numeric_Answer.answer = correctNU.answer
GROUP BY correctNU.quizID, correctNU.qID;


-- insert the view values into the table
INSERT INTO q5
SELECT noAnswerMC.qID, correct, totalStudent-correct-noResponse, noResponse
FROM noAnswerMC, getMC, tookQuiz
WHERE noAnswerMC.qID = getMC.qID AND noAnswerMC.quizID = getMC.quizID AND getMC.quizID = tookQuiz.quizID;

INSERT INTO q5
SELECT noAnswerTF.qID, correct, totalStudent-correct-noResponse, noResponse
FROM noAnswerTF, getTF, tookQuiz
WHERE noAnswerTF.qID = getTF.qID AND noAnswerTF.quizID = getTF.quizID AND getTF.quizID = tookQuiz.quizID;

INSERT INTO q5
SELECT noAnswerNU.qID, correct, totalStudent-correct-noResponse, noResponse
FROM noAnswerNU, getNU, tookQuiz
WHERE noAnswerNU.qID = getNU.qID AND noAnswerNU.quizID = getNU.quizID AND getNU.quizID = tookQuiz.quizID;

SELECT * FROM q5 ORDER BY qID;
