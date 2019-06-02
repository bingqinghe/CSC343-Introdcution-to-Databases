SET SEARCH_PATH TO quizschema;
DROP TABLE IF EXISTS q4 CASCADE; 

CREATE TABLE q4 (
	studentID VARCHAR(20),
	qID       VARCHAR(100),
	qText     VARCHAR(1000)
);

DROP VIEW IF EXISTS candidate, questionInQuiz CASCADE; 
DROP VIEW IF EXISTS noAnswerMC, noAnswerTF, noAnswerNU CASCADE;



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


-- find all the qudents and the questions they DO NOT answer
-- seperate into three part
-- first is multiple-choice
CREATE VIEW noAnswerMC AS
SELECT candidate.sID, Multiple_Choice_Answer.qID
FROM candidate, Multiple_Choice_Answer, questionInQuiz
WHERE candidate.sID = Multiple_Choice_Answer.sID 
	AND Multiple_Choice_Answer.quizID = questionInQuiz.quizID
	AND Multiple_Choice_Answer.qID = questionInQuiz.qID
	AND Multiple_Choice_Answer.answer IS NULL;
	
-- second is true-false
-- a little bit different coz the answer is in boolean type
CREATE VIEW noAnswerTF AS
SELECT candidate.sID, True_False_Answer.qID
FROM candidate LEFT JOIN True_False_Answer 
	ON candidate.sID = True_False_Answer.sID
	JOIN questionInQuiz
		ON True_False_Answer.quizID = questionInQuiz.quizID
			AND True_False_Answer.qID = questionInQuiz.qID
			AND True_False_Answer.answer IS UNKNOWN;

-- last is numeric
CREATE VIEW noAnswerNU AS
SELECT candidate.sID, Numeric_Answer.qID
FROM candidate, Numeric_Answer, questionInQuiz
WHERE candidate.sID = Numeric_Answer.sID 
	AND Numeric_Answer.quizID = questionInQuiz.quizID
	AND Numeric_Answer.qID = questionInQuiz.qID
	AND Numeric_Answer.answer IS NULL;


-- insert those information back into the table
INSERT INTO q4 
SELECT noAnswerMC.sID, noAnswerMC.qID, question.qText
FROM noAnswerMC, question
WHERE noAnswerMC.qID = question.qID;

INSERT INTO q4 
SELECT noAnswerTF.sID, noAnswerTF.qID, question.qText
FROM noAnswerTF, question
WHERE noAnswerTF.qID = question.qID;

INSERT INTO q4 
SELECT noAnswerNU.sID, noAnswerNU.qID, question.qText
FROM noAnswerNU, question
WHERE noAnswerNU.qID = question.qID;

SELECT * FROM q4 ORDER BY studentID, qID;
