-- Alliances

SET SEARCH_PATH TO parlgov;
drop table if exists q7 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q7 CASCADE;
CREATE TABLE q7(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS allianceparty, limitation, allianceparty_count, answer CASCADE;

-- Define views for your intermediate steps here.

-- select pair of the parties that have ben allies with each other first
CREATE VIEW allianceparty AS
SELECT t1.election_id, t1.party_id AS alliedPartyId1, t2.party_id AS alliedPartyId2
FROM election_result AS t1, election_result AS t2
WHERE t1.election_id = t2.election_id AND t1.party_id < t2.party_id AND (t1.alliance_id = t2.id OR t2.alliance_id = t1.id OR t1.alliance_id = t2.alliance_id);

-- count the limitation of the 30% elections in the country
CREATE VIEW limitation AS
SELECT country_id AS countryId, count(id) * 0.3 AS limitnumber FROM election GROUP BY country_id;

-- count the number of times happened for the allianceparty
CREATE VIEW allianceparty_count AS
SELECT country.id AS countryId, alliedPartyId1, alliedPartyId2, count(DISTINCT allianceparty.election_id)
FROM country, allianceparty, election
WHERE allianceparty.election_id = election.id AND election.country_id = country.id
GROUP BY country.id, alliedPartyId1, alliedPartyId2;

-- do the filter whether the allianceparty_count is above the limitation
CREATE VIEW answer AS
SELECT countryId, alliedPartyId1, alliedPartyId2
FROM limitation NATURAL JOIN allianceparty_count
WHERE count >= limitnumber;


-- the answer to the query 
insert into q7 SELECT * FROM answer;
