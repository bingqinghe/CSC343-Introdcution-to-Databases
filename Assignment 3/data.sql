-- insert class info (cID -- classID, rID -- roomID, grade, teacher)
INSERT INTO class VALUES
(1, 120, 8, 'Mr Higgins'),
(2, 366, 5, 'Miss Nyers');

-- insert student info (sID -- studentID, firstName, lastName, cID)
INSERT INTO student VALUES
('0998801234', 'Lena', 'Headey', 1),
('0010784522', 'Peter', 'Dinklage', 1),
('0997733991', 'Emilia', 'Clarke', 1),
('5555555555', 'Kit', 'Harrington', 1),
('1111111111', 'Sophie', 'Turner', 1),
('2222222222', 'Maisie', 'Williams', 2);

-- insert room info (rID, cID, teacher)
INSERT INTO room VALUES
(120, 1, 'Mr Higgins'),
(366, 2, 'Miss Nyers');

-- insert general question info (qID -- question ID, qText -- question text, qType -- question type)
INSERT INTO question VALUES
(782, 'What do you promise when you take the oath of citizenship?', 'Multiple-choice'),
(566, 'The Prime Minister, Justin Trudeau, is Canada''s Head of State.', 'True-False'),
(601, 'During the "Quiet Revolution," Quebec experienced rapid change. In what
decade did this occur? (Enter the year that began the decade, e.g., 1840.)', 'Numeric'),
(625, 'What is the Underground Railroad?', 'Multiple-choice'),
(790, 'During the War of 1812 the Americans burned down the Parliament Buildings in
York (now Toronto). What did the British and Canadians do in return?', 'Multiple-choice');

-- sepecific question types
-- insert multiple-choice (qID, option, int, rightAnswer)
INSERT INTO Multiple_Choice VALUES
(782, 'To pledge your loyalty to the Sovereign, Queen Elizabeth II', NULL, TRUE),
(782, 'To pledge your allegiance to the flag and fulfill the duties of a Canadian', NULL, FALSE),
(782, 'To pledge your allegiance to the flag and fulfill the duties of a Canadian', 'Think regally.', FALSE),
(782, 'To pledge your loyalty to Canada from sea to sea', NULL, FALSE),
(625, 'The first railway to cross Canada', ' The Underground Railroad was generally south to north, not east-west.', FALSE),
(625, 'The CPR''s secret railway line', 'The Underground Railroad was secret, but it had nothing to do with trains.', FALSE),
(625, 'The TTC subway system', 'The TTC is relatively recent; the Underground Railroad was in operation over 100 years ago.', FALSE),
(625, 'A network used by slaves who escaped the United States into Canada', NULL, TRUE),
(790, 'They attacked American merchant ships', NULL, FALSE),
(790, 'They expanded their defence system, including Fort York', NULL, FALSE),
(790, 'They burned down the White House in Washington D.C.', NULL, TRUE),
(790, 'They captured Niagara Falls', NULL, FALSE);

-- insert true or false (qID, answer)
INSERT INTO True_False VALUES
(566, FALSE);

-- insert numeric (qID, answer, lower_bound, higher_bound, hint)
INSERT INTO Numeric VALUES
(601, 1960, 1800, 1900, 'The Quiet Revolution happened during the 20th Century.'),
(601, 1960, 2000, 2010, 'The Quiet Revolution happened some time ago.'),
(601, 1960, 2020, 3000, 'The Quiet Revolution has already happened!');

-- quiz part insert
-- insert general quiz (quizID, title, due, ifHint, qID, cID)
INSERT INTO quiz VALUES
('Pr1-220310', 'Citizenship Test Practise Questions', '2017-10-01 13:30:00', TRUE);

-- insert questions in the quize (quizID, qID, cID)
INSERT INTO quiz_question VALUES
('Pr1-220310', 601, 1),
('Pr1-220310', 566, 1),
('Pr1-220310', 790, 1),
('Pr1-220310', 625, 1);

-- insert each question weight in THIS quiz (quizID, qID, weight)
INSERT INTO quiz_weight VALUES
('Pr1-220310', 601, 2),
('Pr1-220310', 566, 1),
('Pr1-220310', 790, 3),
('Pr1-220310', 625, 2);

-- student answer part
-- insert multiple-choice answers (sID, quizID, qID, answer)
INSERT INTO Multiple_Choice_Answer VALUES
('0998801234', 'Pr1-220310', 625, 'A network used by slaves who escaped the United States into Canada'),
('0998801234', 'Pr1-220310', 790, 'They expanded their defence system, including Fort York'),
('0010784522', 'Pr1-220310', 625, 'A network used by slaves who escaped the United States into Canada'),
('0010784522', 'Pr1-220310', 790, 'They burned down the White House in Washington D.C.'),
('0997733991', 'Pr1-220310', 625, 'The CPR''s secret railway line'),
('0997733991', 'Pr1-220310', 790, 'They burned down the White House in Washington D.C.'),
('5555555555', 'Pr1-220310', 625, NULL),
('5555555555', 'Pr1-220310', 790, 'They captured Niagara Falls'),
('1111111111', 'Pr1-220310', 625, NULL),
('1111111111', 'Pr1-220310', 790, NULL);

-- insert true or false answers (sID, quizID, qID, answer)
INSERT INTO True_False_Answer VALUES
('0998801234', 'Pr1-220310', 566, FALSE),
('0010784522', 'Pr1-220310', 566, FALSE),
('0997733991', 'Pr1-220310', 566, TRUE),
('5555555555', 'Pr1-220310', 566, FALSE),
('1111111111', 'Pr1-220310', 566, NULL);

-- insert numeric answers (sID, quizID, qID, answer)
INSERT INTO Numeric_Answer VALUES
('0998801234', 'Pr1-220310', 601, 1950),
('0010784522', 'Pr1-220310', 601, 1960),
('0997733991', 'Pr1-220310', 601, 1960),
('5555555555', 'Pr1-220310', 601, NULL),
('1111111111', 'Pr1-220310', 601, NULL);
