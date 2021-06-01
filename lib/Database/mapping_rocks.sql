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
AND
(
name = gipfelname_d collate nocase
OR 
name = REPLACE(gipfelname_d,'ss','ß') collate nocase
OR 
name = REPLACE(gipfelname_d,'ß','sz') collate nocase
OR 
name = REPLACE(gipfelname_d, ' (Dreifreundeturm)','') collate nocase --Pascher
OR 
name = REPLACE(gipfelname_d, ' (Einsamer Turm)','') collate nocase --Gemeinschaftsturm
OR 
name = REPLACE(gipfelname_d, ' (Osterspitze)','') collate nocase --Keule
OR 
name = REPLACE(gipfelname_d, ' (Ameisenturm)','') collate nocase --Rabensteinturm
OR 
name = REPLACE(gipfelname_d, ' (Späte Zinne)','') collate nocase --Rätselturm
OR 
name = REPLACE(gipfelname_d, ' (Hänsel)','') collate nocase --Rätselturm
OR 
name = REPLACE(gipfelname_d, ' (Brandriff)','') collate nocase --Lößnitzturm
OR 
name = REPLACE(gipfelname_d, ' (Stumpfes Horn)','') collate nocase --Meilerstein
OR 
name = REPLACE(gipfelname_d, ' (Rotweinspitze)','') collate nocase --Tarzan
OR 
name = REPLACE(gipfelname_d, ' (Buchfinkenturm)','') collate nocase --Pfaffenkopf
OR 
name = REPLACE(gipfelname_d, ' (Pilzturm)','') collate nocase --Pilzwand
OR 
name = REPLACE(gipfelname_d, ' (Rauensteinscheibe)','') collate nocase --Panoramascheibe
OR 
name = REPLACE(gipfelname_d, ' (Kapellenwand)','') collate nocase --Dornröschen
OR 
name = REPLACE(gipfelname_d, 'Waldschrat','Waldschratt') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Großer Felsenbrückenturm','Felsenbrückenturm') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Liebespaar, Südturm','Südturm Liebespaar') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Liebespaar, Nordturm','Nordturm Liebespaar') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Gralsburg, Nordostzinne','NO-Zinne Gralsburg') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Gralsburg, Südwestzinne','SW-Zinne Gralsburg') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Friedensturm (Pilzturm)','Pilzturm') collate nocase
OR 
name = REPLACE(gipfelname_d, '1. Zerborstener Turm','Erster Zerborstener Turm') collate nocase
OR 
name = REPLACE(gipfelname_d, '2. Zerborstener Turm','Zweiter Zerborstener Turm') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Festung Königstein','Königstein') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Lilienstein - Westecke','Lilienstein-Westecke') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Pfaffenkopf (Buchfinkenturm)','Buchfinkenturm') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Zwergfels','Zwerg') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Fünf Gipfel, Südturm','Südturm Fünf Gipfel') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Fünf Gipfel, Nordwestturm','Nordwestturm Fünf Gipfel') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Fünf Gipfel, Nordostturm','Nordostturm Fünf Gipfel') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Siamesische Zwillinge, Doof','Doof Siamesische Zwillinge') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Siamesische Zwillinge, Dick','Dick Siamesische Zwillinge') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Lokomotive-Esse','Lokomotive - Esse') collate nocase
OR 
name = REPLACE(gipfelname_d, 'Burgenerturm','Burgener Turm') collate nocase
)