-- Sequences

SET SEARCH_PATH TO parlgov;
drop table if exists q6 cascade;

-- You must not change this table definition.

CREATE TABLE q6(
        countryName VARCHAR(50),
        cabinetId INT, 
        startDate DATE,
        endDate DATE,
        pmParty VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS accordingtotime, pmparty, accordingtotime_pm, answer CASCADE;

-- Define views for your intermediate steps here.

-- first to make a link list according to the previous_cabinet_id
CREATE VIEW accordingtotime AS
SELECT id AS cabinet_id, country_id, start_date AS startDate, 
	(SELECT start_date FROM cabinet AS t1 WHERE t1.previous_cabinet_id = t2.id) AS endDate
FROM cabinet AS t2;

-- the cabinet_party which has the prime minister
CREATE VIEW pmparty AS
SELECT cabinet_id, party.name AS pmParty
FROM party, cabinet_party
WHERE party_id = party.id AND pm = 't';

-- combine the pm information with the accordingtotime relation
CREATE VIEW accordingtotime_pm AS
SELECT country_id, accordingtotime.cabinet_id AS cabinetId, startDate, endDate, pmParty
FROM accordingtotime LEFT JOIN pmparty ON accordingtotime.cabinet_id = pmparty.cabinet_id;

-- change accordingtotime_pm's country_id to its according country name
CREATE VIEW answer AS
SELECT country.name AS countryName, cabinetId, startDate, endDate, pmParty
FROM country LEFT JOIN accordingtotime_pm ON id = country_id;

-- the answer to the query 
insert into q6 SELECT * FROM answer;
