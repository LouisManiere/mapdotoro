-- Région hydrographique

-- rename col with lowercase
DO $$
DECLARE row record;
BEGIN
  FOR row IN SELECT table_schema,table_name,column_name
             FROM information_schema.columns
             WHERE table_schema = 'public' AND
             table_name   = 'region_hydrographique'
  LOOP
  IF row.column_name != lower(row.column_name) THEN
    EXECUTE format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
      row.table_schema,row.table_name,row.column_name,lower(row.column_name));
	  END IF;
  END LOOP;
END $$;

ALTER TABLE region_hydrographique ADD PRIMARY KEY (gid);

CREATE INDEX idx_gid_region_hydrographique
ON region_hydrographique USING btree(gid);

ALTER TABLE region_hydrographique
ADD CONSTRAINT unq_code_region
UNIQUE (cdregionhy);

CREATE INDEX idx_code_region
ON region_hydrographique USING btree(cdregionhy);

-- create bassin hydographique link foreign key
ALTER TABLE region_hydrographique
ADD COLUMN gid_bassin int;

UPDATE region_hydrographique
SET gid_bassin =
bassin_hydrographique.gid
FROM bassin_hydrographique
WHERE bassin_hydrographique.cdbh LIKE region_hydrographique.cdbh

ALTER TABLE region_hydrographique
ADD CONSTRAINT fk_region_gid_bassin
FOREIGN KEY(gid_bassin)
REFERENCES bassin_hydrographique(gid);

-- geom is MultipolygonZ, change to Multipolygon
ALTER TABLE region_hydrographique
ALTER COLUMN geom TYPE geometry(Multipolygon)
    USING ST_Force2D(geom);

UPDATE region_hydrographique
SET geom = ST_Force2D(geom);

CREATE INDEX idx_geom_region_hydrographique
ON region_hydrographique USING GIST (geom);

