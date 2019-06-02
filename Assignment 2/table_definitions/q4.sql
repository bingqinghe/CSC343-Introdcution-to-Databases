-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS zerototwo, twotofour, fourtosix, sixtoeight, eighttoten, answer CASCADE;

-- Define views for your intermediate steps here.

-- select country within [0,2)
CREATE VIEW zerototwo AS
SELECT name AS countryName, r0_2
FROM country LEFT JOIN 
	(SELECT count(left_right) AS r0_2, party.country_id 
	 FROM party_position, party 
	 WHERE party_position.party_id = party.id AND left_right IS NOT NULL 
	 	AND left_right >= 0 AND left_right < 2
	 GROUP BY party.country_id) t1
ON country.id = t1.country_id;

-- select country within [2,4)
CREATE VIEW twotofour AS
SELECT name AS countryName, r2_4
FROM country LEFT JOIN 
	(SELECT count(left_right) AS r2_4, party.country_id 
	 FROM party_position, party 
	 WHERE party_position.party_id = party.id AND left_right IS NOT NULL 
	 	AND left_right >= 2 AND left_right < 4
	 GROUP BY party.country_id) t2
ON country.id = t2.country_id;

-- select country within [4,6)
CREATE VIEW fourtosix AS
SELECT name AS countryName, r4_6
FROM country LEFT JOIN 
	(SELECT count(left_right) AS r4_6, party.country_id 
	 FROM party_position, party 
	 WHERE party_position.party_id = party.id AND left_right IS NOT NULL 
	 	AND left_right >= 4 AND left_right < 6
	 GROUP BY party.country_id) t3
ON country.id = t3.country_id;

-- select country within [6,8)
CREATE VIEW sixtoeight AS
SELECT name AS countryName, r6_8
FROM country LEFT JOIN 
	(SELECT count(left_right) AS r6_8, party.country_id 
	 FROM party_position, party 
	 WHERE party_position.party_id = party.id AND left_right IS NOT NULL 
	 	AND left_right >= 6 AND left_right < 8
	 GROUP BY party.country_id) t4
ON country.id = t4.country_id;

-- select country within [8,10]
CREATE VIEW eighttoten AS
SELECT name AS countryName, r8_10
FROM country LEFT JOIN 
	(SELECT count(left_right) AS r8_10, party.country_id 
	 FROM party_position, party 
	 WHERE party_position.party_id = party.id AND left_right IS NOT NULL 
	 	AND left_right >= 8 AND left_right <= 10
	 GROUP BY party.country_id) t5
ON country.id = t5.country_id;

-- combine all the information together
CREATE VIEW answer AS
SELECT *
FROM zerototwo NATURAL JOIN twotofour NATURAL JOIN fourtosix NATURAL JOIN sixtoeight NATURAL JOIN eighttoten;


-- the answer to the query 
INSERT INTO q4 SELECT * FROM answer;

