-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS one, two, answer CASCADE;

-- Define views for your intermediate steps here.

-- "one": select those question required attributes first
CREATE VIEW one AS
SELECT EXTRACT(YEAR from election.e_date) AS year, country.name AS countryName, party.name_short AS partyName, party.id AS partyID, election.id AS electionID, country.id AS countryID, election_result.votes::float / election.votes_valid::float * 100 AS resultOne
FROM election, country, party, election_result
WHERE country.id = party.country_id AND country.id = election.country_id AND party.country_id = election.country_id AND EXTRACT(YEAR from election.e_date) >= 1996 AND EXTRACT(YEAR from election.e_date) <= 2016 AND election_result.party_id = party.id AND election_result.election_id = election.id AND election_result.votes::float / election.votes_valid::float * 100 IS NOT NULL;

-- "two": table of the range with their lower bound and upper bound
CREATE VIEW two AS
SELECT * FROM (VALUES ('(0-5]',0,5), ('(5-10]',5,10), ('(10-20]',10,20), ('(20-30]',20,30), ('(30-40]',30,40), ('(40-100]',40,100)) AS t(voteRange, lower, upper);

-- "answer": combine the first selections from "one" with the voteRange according to the avg of the percent we calculated
CREATE VIEW answer AS
SELECT year, countryName, (SELECT voteRange FROM two WHERE avg(one.resultOne) <= upper and lower < avg(one.resultOne)), partyName
FROM one
GROUP BY year, countryName, partyName;


-- the answer to the query 
insert into q1 SELECT * FROM answer;

