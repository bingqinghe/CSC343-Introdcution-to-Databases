-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS one, two, three, four, five, six, seven, eight, nine, ten, answer CASCADE;

-- Define views for your intermediate steps here.
-- select the max votes according to the election ids
CREATE VIEW one AS
SELECT election_id, MAX(votes) AS votes
FROM election_result
WHERE votes IS NOT NULL
GROUP BY election_id;

-- Those are for the elections in "one" that party has the maximum votes
-- "two": the winning party(ies) for the election
CREATE VIEW two AS
SELECT election_result.election_id, election_result.party_id, election_result.votes
FROM election_result JOIN one ON one.election_id = election_result.election_id AND one.votes = election_result.votes
WHERE election_result.votes IS NOT NULL;

-- "three": For every country, how many parties have won a election
CREATE VIEW three AS
SELECT country.id, count(two.party_id) AS partyNumber
FROM country, party, two
WHERE country.id = party.country_id AND party.id = two.party_id
GROUP BY country.id;

-- "four": For every country, how many parties each country has
CREATE VIEW four AS
SELECT country.id, count(party.id)
FROM country JOIN party ON country.id = party.country_id
GROUP BY country.id;

-- "five": according to the "three" & "four", we can get the average number of winning elections of parties of the same country
CREATE VIEW five AS
SELECT three.id, partyNumber, count, partyNumber / count::float AS result
FROM three NATURAL JOIN four;

-- "six": from the result of every election winning parties, we can get how many times each party has won a election
CREATE VIEW six AS
SELECT party_id, count(election_id) AS wonElections FROM two GROUP BY party_id;

-- "seven": just add one more attribute of country id to the results we get in "six"
CREATE VIEW seven AS
SELECT party.country_id, six.party_id, six.wonElections
FROM party JOIN six on party.id = six.party_id;

-- "eight": filter of the parties that have won more than three times the avg
CREATE VIEW eight AS
SELECT seven.country_id, seven.party_id, seven.wonElections
FROM five, seven
WHERE id = country_id AND wonElections > (3 * result);

-- "nine": do the most recentlyWonElectionYear & recentlyWonElectionID
CREATE VIEW nine AS
SELECT eight.country_id, eight.party_id, wonElections, MAX(EXTRACT(YEAR from election.e_date)) AS mostRecentlyWonElectionYear 
FROM two, eight, election
WHERE election.id = two.election_id AND eight.party_id = two.party_id AND election.country_id = eight.country_id
GROUP BY eight.country_id, eight.party_id, wonElections;

-- "ten" & "answer": filter the rest of information the question requires
CREATE VIEW ten AS
SELECT country.name AS countryName, party.name AS partyName, party.id AS party_id, wonElections, election.id AS mostRecentlyWonElectionId, mostRecentlyWonElectionYear
FROM country, party, election, nine
WHERE country.id = party.country_id AND party.country_id = election.country_id AND election.country_id = nine.country_id AND party.id = nine.party_id AND EXTRACT(YEAR from election.e_date) = mostRecentlyWonElectionYear;

CREATE VIEW answer AS
SELECT countryName, partyName, party_family.family AS partyFamily, wonElections, mostRecentlyWonElectionId, mostRecentlyWonElectionYear
FROM party_family RIGHT JOIN ten ON party_family.party_id = ten.party_id; 


-- the answer to the query 
insert into q2 SELECT * FROM answer;


