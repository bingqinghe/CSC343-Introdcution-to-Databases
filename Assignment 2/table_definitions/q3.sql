-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS participation_ratio, notnondecreasing, meetnondecreasing, answer CASCADE;

-- Define views for your intermediate steps here.

-- selection the basic information for the participation ratio
CREATE VIEW participation_ratio AS
SELECT country_id, EXTRACT(YEAR from e_date) AS year, avg(votes_cast::float / electorate::float) AS participationRatio
FROM election
WHERE EXTRACT(YEAR from e_date) >= 2001 AND EXTRACT(YEAR from e_date) <= 2016 AND votes_cast::float / electorate::float IS NOT NULL
GROUP BY country_id, EXTRACT(YEAR from e_date);

-- select those countries which are not always non-decreasing
CREATE VIEW notnondecreasing AS
SELECT DISTINCT t1.country_id
FROM participation_ratio AS t1 
WHERE EXISTS (
	SELECT * FROM participation_ratio AS t2 
	WHERE t1.country_id = t2.country_id AND t1.year < t2.year AND t1.participationRatio >= t2.participationRatio);
	
-- filter the question's requirement
CREATE VIEW meetnondecreasing AS
SELECT * FROM participation_ratio
WHERE NOT EXISTS (
	SELECT * FROM notnondecreasing
	WHERE participation_ratio.country_id = notnondecreasing.country_id);

CREATE VIEW answer AS
SELECT name AS countryName, year, participationRatio
FROM meetnondecreasing, country WHERE country_id = id; 


-- the answer to the query 
insert into q3 SELECT * FROM answer;

