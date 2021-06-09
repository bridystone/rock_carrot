DROP TABLE IF EXISTS "mapping_rocks";
CREATE TABLE IF NOT EXISTS "mapping_rocks" (
	"sandstein_rockname" TEXT NOT NULL COLLATE NOCASE,
	"tt_rockname" TEXT NOT NULL COLLATE NOCASE,
	PRIMARY KEY("sandstein_rockname")
);

INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Pascher (Dreifreundeturm)', 'Pascher');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Gemeinschaftsturm (Einsamer Turm)', 'Gemeinschaftsturm');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Keule (Osterspitze)', 'Keule');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Rabensteinturm (Ameisenturm)', 'Rabensteinturm' );
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Rätselturm (Späte Zinne)', 'Rätselturm' );
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Hexe (Hänsel)', 'Hexe' );
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Lößnitzturm (Brandriff)', 'Lößnitzturm' );
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Meilerstein (Stumpfes Horn)', 'Meilerstein' );
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Tarzan (Rotweinspitze)', 'Tarzan' );
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Pilzwand (Pilzturm)', 'Pilzwand' );
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Panoramascheibe (Rauensteinscheibe)', 'Panoramascheibe' );
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Dornröschen (Kapellenwand)', 'Dornröschen');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Waldschrat','Waldschratt');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Großer Felsenbrückenturm','Felsenbrückenturm');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Liebespaar, Südturm','Südturm Liebespaar');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Liebespaar, Nordturm','Nordturm Liebespaar');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Gralsburg, Nordostzinne','NO-Zinne Gralsburg');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Gralsburg, Südwestzinne','SW-Zinne Gralsburg');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Friedensturm (Pilzturm)','Pilzturm');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('1. Zerborstener Turm','Erster Zerborstener Turm');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('2. Zerborstener Turm','Zweiter Zerborstener Turm');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Festung Königstein','Königstein');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Lilienstein - Westecke','Lilienstein-Westecke');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Pfaffenkopf (Buchfinkenturm)','Buchfinkenturm');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Zwergfels','Zwerg');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Fünf Gipfel, Südturm','Südturm Fünf Gipfel');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Fünf Gipfel, Nordwestturm','Nordwestturm Fünf Gipfel');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Fünf Gipfel, Nordostturm','Nordostturm Fünf Gipfel');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Siamesische Zwillinge, Doof','Doof Siamesische Zwillinge');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Siamesische Zwillinge, Dick','Dick Siamesische Zwillinge');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Lokomotive-Esse','Lokomotive - Esse');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Burgenerturm','Burgener Turm');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Litfasssäule','Litfaßsäule');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Amboss','Amboß');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Kleiner Amboss','Kleiner Amboß');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Bloßstock','Bloszstock');
INSERT INTO mapping_rocks (sandstein_rockname, tt_rockname) VALUES ('Kleingießhübeler Turm','Kleingießhübler Turm');




-- caching table
CREATE TABLE IF NOT EXISTS tt_mapping_rocks (
	tt_rockid INT PRIMARY KEY,
	sandstein_rockid INT
);
CREATE INDEX idx_tt_mapping_rocks_sandstein ON tt_mapping_rocks (sandstein_rockid)

-- caching view in table
DELETE FROM tt_mapping_rocks;
INSERT INTO tt_mapping_rocks
SELECT *
FROM tt_mapping_rocks_view;

-- actual mapping view
CREATE VIEW tt_mapping_rocks_view AS 
/*
only 3 Rocks are missing in DB Sandsteinklettern
*/
SELECT tt_rocks.id as tt_rockid, gipfel.gipfel_id as sandstein_rockid
FROM tt_rocks
	INNER JOIN tt_mapping_areas -- or tt_mapping_areas_view
	ON tt_areaid = tt_rocks.areaid
	INNER JOIN gipfel
	ON sandstein_areaid = sektorid
	LEFT JOIN mapping_rocks
	ON gipfel.gipfelname_d = mapping_rocks.sandstein_rockname 
WHERE name = gipfelname_d OR name = tt_rockname
