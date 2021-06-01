-- caching table
CREATE TABLE IF NOT EXISTS tt_mapping_areas (
"tt_areaid" INT PRIMARY KEY,
"sandstein_areaid" INT
);
CREATE INDEX idx_tt_mapping_areas_sandstein ON tt_mapping_areas (sandstein_areaid)

-- caching view in table
DELETE FROM tt_mapping_areas;
INSERT INTO tt_mapping_areas
SELECT *
FROM tt_mapping_areas_view;

-- actual mapping view
CREATE VIEW tt_mapping_areas_view AS
SELECT 10 as tt_areaid, 123 as sandstein_areaid --	Affensteine
UNION
SELECT 2, 124 --	Bielatal
UNION
SELECT 11, 125 --	Erzgebirgsgrenzgebiet
UNION
SELECT 9, 126 --	Großer Zschand
UNION
SELECT 13, 127 --	Hinterhermsdorf
UNION
SELECT 7, 128 --	Brand
UNION
SELECT 8, 129 --	Kleiner Zschand
UNION
SELECT 5, 130 --	Rathen
UNION
SELECT 4, 131 --	Schmilka
UNION
SELECT 3, 132 --	Schrammsteine
UNION
SELECT 1, 133 --	Gebiet der Steine
UNION
SELECT 6, 134 --	Wehlen
UNION
SELECT 12, 135 --	Wildensteiner Gebiet
;