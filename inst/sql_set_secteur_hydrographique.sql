-- Secteur hydrographique

-- rename col with lowercase
DO $$
DECLARE row record;
BEGIN
  FOR row IN SELECT table_schema,table_name,column_name
             FROM information_schema.columns
             WHERE table_schema = 'public' AND 
             table_name   = 'secteur_hydrographique'
  LOOP
  IF row.column_name != lower(row.column_name) THEN
    EXECUTE format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
      row.table_schema,row.table_name,row.column_name,lower(row.column_name));  
	  END IF;
  END LOOP;
END $$;

ALTER TABLE secteur_hydrographique ADD PRIMARY KEY (gid);

CREATE INDEX idx_gid_secteur_hydrographique
ON secteur_hydrographique USING btree(gid);

ALTER TABLE secteur_hydrographique
ADD CONSTRAINT unq_code_secteur
UNIQUE (cdsecteurh);

ALTER TABLE secteur_hydrographique
ADD CONSTRAINT fk_code_region
FOREIGN KEY (cdregionhy)
REFERENCES region_hydrographique(cdregionhy);

CREATE INDEX idx_code_secteur
ON secteur_hydrographique USING btree(cdsecteurh);

CREATE INDEX idx_geom_secteur_hydrographique
ON secteur_hydrographique USING GIST (geom);