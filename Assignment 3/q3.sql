SET SEARCH_PATH TO quizschema;
DROP TABLE IF EXISTS q3 CASCADE; 

CREATE TABLE q3 (
	studentID VARCHAR(20),
	lastName  VARCHAR(100),
	totalGrade INT
);

DROP VIEW IF EXISTS candidate, questionInQuiz CASCADE;
DROP VIEW IF EXISTS correctMC, correctTF, correctNU CASCADE;
DROP VIEW IF EXISTS candidateMC, candidateTF, candidateNU CASCADE;
DROP VIEW IF EXISTS scoreMC, scoreTF, scoreNU CASCADE;
DROP VIEW IF EXISTS combination, listMark, answer CASCADE;


-- find the Gr8 students in Rm120 with Mr Higgins
CREATE VIEW candidate AS
SELECT student.sID, student.lastName, class.cID
FROM student, class
WHERE student.cID = class.cID AND class.roomID = 120 AND class.grade = 8 AND class.teacher = 'Mr Higgins';

-- find all the questions in the quiz
CREATE VIEW questionInQuiz AS
SELECT quiz_question.quizID, quiz_question.qID
FROM quiz_question, candidate
WHERE quiz_question.quizID = 'Pr1-220310' AND quiz_question.cID = candidate.cID;



-- find each questions' correct answers
-- sperate into three different types
-- first is multiple-choice
CREATE VIEW correctMC AS
SELECT DISTINCT Multiple_Choice.qID, questionInQuiz.quizID, option AS answer
FROM questionInQuiz, question, Multiple_Choice
WHERE question.qType = 'Multiple-choice' AND questionInQuiz.qID = question.qID AND question.qID = Multiple_Choice.qID AND Multiple_Choice.ifCorrect = TRUE;

-- second is true or false
CREATE VIEW correctTF AS
SELECT DISTINCT True_False.qID, questionInQuiz.quizID, True_False.answer
FROM questionInQuiz, question, True_False
WHERE question.qType = 'True-False' AND questionInQuiz.qID = question.qID AND question.qID = True_False.qID;

-- last one is numeric
CREATE VIEW correctNU AS
SELECT DISTINCT Numeric.qID, questionInQuiz.quizID, Numeric.answer
FROM questionInQuiz, question, Numeric
WHERE question.qType = 'Numeric' AND questionInQuiz.qID = question.qID AND question.qID = Numeric.qID;




-- now we need to compair what student answered to the correct answers
-- also sperate into three types
-- first is multiple-choice
CREATE VIEW candidateMC AS
SELECT candidate.sID, candidate.lastName, Multiple_Choice_Answer.qID, Multiple_Choice_Answer.quizID
FROM candidate LEFT JOIN Multiple_Choice_Answer ON candidate.sID = Multiple_Choice_Answer.sID RIGHT JOIN correctMC ON correctMC.quizID = Multiple_Choice_Answer.quizID AND correctMC.qID = Multiple_Choice_Answer.qID AND correctMC.answer = Multiple_Choice_Answer.answer;
				
-- second is true-false
CREATE VIEW candidateTF AS
SELECT candidate.sID, candidate.lastName, True_False_Answer.qID, True_False_Answer.quizID
FROM candidate LEFT JOIN True_False_Answer ON candidate.sID = True_False_Answer.sID RIGHT JOIN correctTF ON correctTF.quizID = True_False_Answer.quizID AND correctTF.qID = True_False_Answer.qID AND correctTF.answer = True_False_Answer.answer;

-- last one is numeric
CREATE VIEW candidateNU AS
SELECT candidate.sID, candidate.lastName, Numeric_Answer.qID, Numeric_Answer.quizID
FROM candidate LEFT JOIN Numeric_Answer ON candidate.sID = Numeric_Answer.sID RIGHT JOIN correctNU ON correctNU.quizID = Numeric_Answer.quizID AND correctNU.qID = Numeric_Answer.qID AND correctNU.answer = Numeric_Answer.answer;


				
-- after compairing the answers we can now sum their score
-- step one, combine with the weight of each question
-- first is multiple-choice
CREATE VIEW scoreMC AS
SELECT candidateMC.sID, candidateMC.lastName, sum(quiz_weight.weight)
FROM candidateMC, quiz_weight
WHERE candidateMC.qID = quiz_weight.qID
GROUP BY candidateMC.sID, candidateMC.lastName;

-- second is true-false
CREATE VIEW scoreTF AS
SELECT candidateTF.sID, candidateTF.lastName, sum(quiz_weight.weight)
FROM candidateTF, quiz_weight
WHERE candidateTF.qID = quiz_weight.qID
GROUP BY candidateTF.sID, candidateTF.lastName;

-- last one is numeric
CREATE VIEW scoreNU AS
SELECT candidateNU.sID, candidateNU.lastName, sum(quiz_weight.weight)
FROM candidateNU, quiz_weight
WHERE candidateNU.qID = quiz_weight.qID
GROUP BY candidateNU.sID, candidateNU.lastName;


-- step two, combine each students' three part-mark and count the total final mark
CREATE VIEW combination AS
SELECT scoreMC.sID, scoreMC.lastName, scoreMC.sum AS partalMark FROM scoreMC
UNION
SELECT scoreTF.sID, scoreTF.lastName, scoreTF.sum AS partalMark FROM scoreTF
UNION
SELECT scoreNU.sID, scoreNU.lastName, scoreNU.sum AS partalMark FROM scoreNU;

CREATE VIEW listMark AS
SELECT sID, lastName, sum(partalMark) AS totalGrade
FROM combination
GROUP BY sID, lastName;

-- since some students do not answer any questions, we need t add their name in the list
CREATE VIEW answer AS
SELECT candidate.sID, candidate.lastName, totalGrade
FROM candidate FULL JOIN listMark ON candidate.sID = listMark.sID AND candidate.lastName = listMark.lastName;
				
-- insert the final value into the table
INSERT INTO q3 SELECT * FROM answer;

SELECT * FROM q3 ORDER BY studentID;
