DROP TABLE IF EXISTS "mapping_routes";
CREATE TABLE IF NOT EXISTS "mapping_routes" (
	"sandstein_routename" TEXT NOT NULL COLLATE NOCASE,
	"tt_routename" TEXT NOT NULL COLLATE NOCASE,
	PRIMARY KEY("sandstein_routename")
);

INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('Alter Weg', 'AW');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('Alter Weg direkt', 'AW direkt');

INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordweg', 'N-Weg');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordostweg', 'NO-Weg');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('ostweg', 'O-Weg');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südostweg', 'SO-Weg');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südweg', 'S-Weg');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südwestweg', 'SW-Weg');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('westweg', 'W-Weg');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordwestweg', 'NW-Weg');

INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordwand', 'N-wand');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordostwand', 'NO-wand');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('ostwand', 'O-wand');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südostwand', 'SO-wand');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südwand', 'S-wand');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südwestwand', 'SW-wand');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('westwand', 'W-wand');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordwestwand', 'NW-wand');

INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordkante', 'N-kante');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordostkante', 'NO-kante');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('ostkante', 'O-kante');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südostkante', 'SO-kante');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südkante', 'S-kante');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südwestkante', 'SW-kante');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('westkante', 'W-kante');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordwestkante', 'NW-kante');

INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordkamin', 'N-kamin');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordostkamin', 'NO-kamin');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('ostkamin', 'O-kamin');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südostkamin', 'SO-kamin');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südkamin', 'S-kamin');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('südwestkamin', 'SW-kamin');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('westkamin', 'W-kamin');
INSERT INTO mapping_routes (sandstein_routename, tt_routename) VALUES ('nordwestkamin', 'NW-kamin');


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
		  LEFT JOIN mapping_routes
		  ON REPLACE(wege.wegname_d,'*','') = mapping_routes.sandstein_routename
		WHERE 
		REPLACE(
		REPLACE(
			name 
		,'-','')
		,' ','')
		= 
		REPLACE(
		REPLACE(
			REPLACE(
				REPLACE(
					wegname_d,
				'*',''),
			'ss','ß') -- sometimes replaced - but not always
		,'-','')
		,' ','')
			collate nocase 
		OR
		name = 
			REPLACE(
				wegname_d,
			'*','')collate nocase -- sometimes ß replaced - but not always
		OR 
		name = mapping_routes.tt_routename collate nocase
		GROUP BY id
