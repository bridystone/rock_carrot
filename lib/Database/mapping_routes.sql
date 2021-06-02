-- caching table
CREATE TABLE IF NOT EXISTS tt_mapping_routes (
	tt_routeid INT PRIMARY KEY,
	sandstein_routeid INT 
);
CREATE INDEX idx_tt_mapping_routes_sandstein ON tt_mapping_routes (sandstein_routeid)

-- caching view in table
DELETE FROM tt_mapping_routes;
INSERT INTO tt_mapping_routes
SELECT *
FROM tt_mapping_routes_view;

-- actual mapping view
CREATE VIEW tt_mapping_routes_view AS
/*
lots of routes are still missing
*/
SELECT id as tt_routeid, weg_id as sandstein_routeid
FROM "tt_routes"
	INNER JOIN tt_mapping_rocks -- or tt_mapping_rocks_view
	ON tt_rockid = rockid
	INNER JOIN wege
	ON sandstein_rockid = gipfelid
	AND 
	(
	name = wegname_d collate nocase
	OR
	REPLACE(name, 'AW', 'Alter Weg') = REPLACE(wegname_d, '*', '')
	OR 
	REPLACE(name, 'ß', 'ss') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	REPLACE(name, 'NW-', 'Nordwest') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	REPLACE(name, 'N-', 'Nord') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	REPLACE(name, 'NO-', 'Nordost') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	REPLACE(name, 'O-', 'Ost') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	REPLACE(name, 'SO-', 'Südost') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	REPLACE(name, 'S-', 'Süd') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	REPLACE(name, 'SW-', 'Südwest') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	REPLACE(name, 'W-', 'West') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	REPLACE(name, 'Var.', 'Variante') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	REPLACE(name, 'EV', 'Variante') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	REPLACE(name, 'EV', 'Einstiegsvariante') = REPLACE(wegname_d, '*', '') collate nocase
	OR 
	name = TRIM(REPLACE(wegname_d,'*','')) collate nocase
	)
GROUP BY id -- because der is duplicates in db-sandsteinklettern
