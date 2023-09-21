-- Bassin hydrographique

-- rename col with lowercase
DO $$
DECLARE row record;
BEGIN
  FOR row IN SELECT table_schema,table_name,column_name
             FROM information_schema.columns
             WHERE table_schema = 'public' AND 
             table_name   = 'bassin_hydrographique'
  LOOP
  IF row.column_name != lower(row.column_name) THEN
    EXECUTE format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
      row.table_schema,row.table_name,row.column_name,lower(row.column_name));  
	  END IF;
  END LOOP;
END $$;

ALTER TABLE bassin_hydrographique
ADD CONSTRAINT unq_code_bassin
UNIQUE (cdbh);

CREATE INDEX idx_code_bassin 
ON bassin_hydrographique USING btree(cdbh);

ALTER TABLE bassin_hydrographique ADD PRIMARY KEY (gid);

CREATE INDEX idx_gid_bassin_hydrographique
ON bassin_hydrographique USING btree(gid);

CREATE INDEX idx_geom_bassin_hydrographique 
ON bassin_hydrographique USING GIST (geom);