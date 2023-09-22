-- roe

-- rename col with lowercase
DO $$
DECLARE row record;
BEGIN
  FOR row IN SELECT table_schema,table_name,column_name
             FROM information_schema.columns
             WHERE table_schema = 'public' AND
             table_name   = 'roe'
  LOOP
  IF row.column_name != lower(row.column_name) THEN
    EXECUTE format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
      row.table_schema,row.table_name,row.column_name,lower(row.column_name));
	  END IF;
  END LOOP;
END $$;

ALTER TABLE roe ADD PRIMARY KEY (gid);

CREATE INDEX idx_gid_roe
ON roe USING btree(gid);

ALTER TABLE roe
ADD CONSTRAINT unq_cdobstecou
UNIQUE (cdobstecou);

CREATE INDEX idx_cdobstecou
ON roe USING btree(cdobstecou);

CREATE INDEX idx_geom_roe
ON roe USING GIST (geom);

-- add gid_region
ALTER TABLE roe
ADD COLUMN gid_region integer;

-- update gid_region with spatial join
UPDATE roe AS nm
SET gid_region = rh.gid
FROM region_hydrographique AS rh
WHERE ST_Within(nm.geom, rh.geom);

-- création d'un index sur gid_region
CREATE INDEX idx_gid_region_roe
ON roe USING btree(gid_region);
