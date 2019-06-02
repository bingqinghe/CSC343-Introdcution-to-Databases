-- Committed

SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

CREATE TABLE q5(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS cabinet20years, cabinet_party_information CASCADE;
DROP VIEW IF EXISTS cabinetcount, committedparty, committedparty_family, answer CASCADE;

-- Define views for your intermediate steps here.

-- select those cabinets in their country over the past 20 years
CREATE VIEW cabinet20years AS
SELECT id AS cabinet_id, country_id FROM cabinet
WHERE EXTRACT(YEAR FROM start_date) >= 1996 AND EXTRACT(YEAR FROM start_date) <= 2016;

-- combine cabinet_party information with countryName, and partyname first
CREATE VIEW cabinet_party_information AS
SELECT country_id, country.name AS countryName, party_id, party.name AS partyName, cabinet_id
FROM cabinet_party, party, country
WHERE party_id = party.id AND country_id = country.id;

-- count the number of cabinets each country has in te past 20 years
CREATE VIEW cabinetcount AS
SELECT country_id, count(cabinet_id) FROM cabinet20years GROUP BY country_id;

-- select those committed parties
CREATE VIEW committedparty AS
SELECT countryName, party_id, partyName
FROM cabinet20years, cabinet_party_information
WHERE cabinet20years.country_id = cabinet_party_information.country_id AND cabinet20years.cabinet_id = cabinet_party_information.cabinet_id
GROUP BY countryName, party_id, partyName, cabinet20years.country_id
HAVING count(cabinet20years.cabinet_id) = (SELECT count FROM cabinetcount WHERE country_id = cabinet20years.country_id);

-- add party family information to the exist committedparty information
CREATE VIEW committedparty_family AS
SELECT countryName, partyName, family AS partyFamily, committedparty.party_id
FROM committedparty LEFT JOIN party_family ON committedparty.party_id = party_family.party_id;

-- add state_market information to hte exist committedparty_family information as saved as final answer
CREATE VIEW answer AS
SELECT countryName, partyName, partyFamily, state_market AS stateMarket
FROM committedparty_family LEFT JOIN party_position ON committedparty_family.party_id = party_position.party_id;


-- the answer to the query 
insert into q5 SELECT * FROM answer;
