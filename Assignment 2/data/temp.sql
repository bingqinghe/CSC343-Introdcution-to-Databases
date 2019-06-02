SELECT election.id, meetrequirement.cabinet_id 
FROM election NATURAL LEFT JOIN 
	(SELECT country.id AS country_id, e1.id, cabinet.id AS cabinet_id, cabinet.start_date 
	FROM country, cabinet, election AS e1 
	WHERE country.name = 'France' AND country.id = cabinet.country_id AND country.id = e1.country_id AND 
	cabinet.start_date >= e1.e_date AND (cabinet.start_date < (SELECT MIN(e2.e_date) FROM election AS e2
	WHERE e1.country_id = e2.country_id AND e1.e_type = e2.e_type AND e1.e_date < e2.e_date) OR NOT EXISTS (SELECT * FROM election AS e3 WHERE e1.country_id = e3.country_id AND e1.e_type = e3.e_type AND e1.e_date < e3.e_date))) AS meetrequirement
	WHERE election.country_id = meetrequirement.country_id ORDER BY election.e_date DESC, meetrequirement DESC;
