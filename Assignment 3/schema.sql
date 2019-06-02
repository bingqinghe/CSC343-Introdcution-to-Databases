-- At the top of your DDL file, include a comment that answers these questions:
-- 1.  What constraints from the domain could not be enforced?
--	i) A room can have two classes in it but never more than one teacher
--	   In our schema, class schema has classID as a primary key , so one class can only have one unique room ID.
--	   While in room schema also use roomID as a primary key, so one room can only have one class
--	   If both of the schema dont use primary key, it will cause more problems.
--	ii) A multiple choice question has at least two options
--	    We can make sure option has at least one option and you can insert several times to add more options, but we can not make sure every multiple choice question has at least two questions if you don't insert values into it.
--	iii) Correct answers do not have hints
--	     It depends on the values we insert but not strict in our schema, if you want, you can add hint for every answer

-- 2.  What constraints that could have been enforced were not enforced?  Why not?
--	i) A class has one or more students who are in that class
--	   I don't add student ID in the class schema to avoid lots of duplicates and redundancy.
--	ii) All questions have a single correct answer
--	   Since true/false and numeric questions we can use UNIQUE to make sure only one correct answer, but multiple choice has different options, so in the schema, this part for multiple-choice questions cannot be forced
--	iii) Avoid designing your schema in such a way that there are attributes that can be null
--	     In the schema, if a student answer no question, then in the answer attribute, it will be null


DROP SCHEMA IF EXISTS quizschema CASCADE;
CREATE SCHEMA quizschema;
SET search_path TO quizschema;

-- basic student, class, class_room info
-- class info
CREATE TABLE class(
	-- unique class ID
	cID INT PRIMARY KEY,
	-- class room
	roomID INT,
	-- class grade
	grade INT,
	teacher VARCHAR(100) NOT NULL
);

-- student info
CREATE TABLE student (
	-- unique student ID (10-digit number)
	sID VARCHAR(20) CHECK (sID SIMILAR TO '[[:digit:]]{10}'),
	-- student name
	firstName VARCHAR(100) NOT NULL,
	lastName VARCHAR(100) NOT NULL,
	-- class number (>=0)
	cID INT REFERENCES class(cID),
	-- sudentID is the key of this schema
	PRIMARY KEY(sID)
);

-- room info
CREATE TABLE room (
	-- unique room ID
	rID INT PRIMARY KEY,
	-- class ID
	cID INT REFERENCES class(cID),
	-- teacher name
	teacher VARCHAR(100)
);

-- question bank and specific three types of question info
-- general question info
CREATE TABLE question (
	-- unique question ID
	qID INT PRIMARY KEY,
	-- question text
	qText VARCHAR(1000),
	-- question type
	qType VARCHAR(20),
	-- question type constraints
	CONSTRAINT CHK_qType CHECK (qType = 'Multiple-choice' OR qType = 'True-False' OR qType = 'Numeric')
);

-- multiple-choice
CREATE TABLE Multiple_Choice (
	-- foreign key question ID
	qID INT REFERENCES question(qID),
	-- answer options (>=2)
	option VARCHAR(1000) NOT NULL,
	-- hint (can be NULL)
	hint VARCHAR(1000),
	-- correcet/incorrect answer in boolean type	
	ifCorrect BOOLEAN NOT NULL,
	-- unique question with unique option & hint
	UNIQUE(qID, option, hint)
);

-- true or false
CREATE TABLE True_False (
	-- foreign key question ID
	qID INT PRIMARY KEY REFERENCES question(qID),
	-- two boolean answers for the questions
	answer BOOLEAN NOT NULL,
	-- unique question with unique answer
	UNIQUE(qID, answer)
);

-- numeric
CREATE TABLE Numeric (
	-- foreign key question ID
	qID INT REFERENCES question(qID),
	-- answer in INT type
	answer INT NOT NULL,
	-- incorrect lower_bound for optional hint
	lower_bound INT,
	-- incorrect higher_bound for optional hint
	higher_bound INT,
	-- hint message
	hint VARCHAR(1000)
);

-- quizes part info
-- general quiz part
CREATE TABLE quiz (
	-- unique quiz ID
	quizID VARCHAR(100) PRIMARY KEY,
	-- quize title
	title VARCHAR(1000) NOT NULL,
	-- due timestamp
	due TIMESTAMP NOT NULL,
	-- whether give hint or not
	ifHint BOOLEAN NOT NULL
);

-- since quiz has unique ID, we need to assign specific questions in differenct schema
CREATE TABLE quiz_question (
	-- foreign key quiz ID
	quizID VARCHAR(100) REFERENCES quiz(quizID),
	-- questions in the quiz
	qID INT REFERENCES question(qID),
	-- assigned class
	cID INT REFERENCES class(cID),
	-- unique quiz with unique questions for class
	UNIQUE(quizID, qID, cID)
);

-- quiz weight
CREATE TABLE quiz_weight (
	-- foreign key quiz ID
	quizID VARCHAR(100) REFERENCES quiz(quizID),
	-- foreign key question ID
	qID INT REFERENCES question(qID),
	-- in THIS quiz how much THIS question will be weighted
	weight INT NOT NULL,
	-- one question can only weight one number in one quiz
	UNIQUE(quizID, qID, weight)
);

-- answer part to calculate the score for every student
-- count in different types of questions
-- multiple-choice
CREATE TABLE Multiple_Choice_Answer (
	-- foreign key student ID
	sID VARCHAR(20) REFERENCES student(sID),
	-- foreign key quiz ID
	quizID VARCHAR(100) REFERENCES quiz(quizID),
	-- foreign key question ID
	qID INT REFERENCES question(qID),
	-- answer which is chose by the student
	answer VARCHAR(1000)
);

-- true or false
CREATE TABLE True_False_Answer (
	-- foreign key student ID
	sID VARCHAR(20) REFERENCES student(sID),
	-- foreign key quiz ID
	quizID VARCHAR(100) REFERENCES quiz(quizID),
	-- foreign key question ID
	qID INT REFERENCES question(qID),
	-- answer which is chose by the student in boolean(true/false)
	answer BOOLEAN
);

-- numeric
CREATE TABLE Numeric_Answer (
	-- foreign key student ID
	sID VARCHAR(20) REFERENCES student(sID),
	-- foreign key quiz ID
	quizID VARCHAR(100) REFERENCES quiz(quizID),
	-- foreign key question ID
	qID INT REFERENCES question(qID),
	-- answer which is chose by the student in INT
	answer INT
);
