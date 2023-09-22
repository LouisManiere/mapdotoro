-- network_axis

-- rename col with lowercase
DO $$
DECLARE row record;
BEGIN
  FOR row IN SELECT table_schema,table_name,column_name
             FROM information_schema.columns
             WHERE table_schema = 'public' AND
             table_name   = 'network_axis'
  LOOP
  IF row.column_name != lower(row.column_name) THEN
    EXECUTE format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
      row.table_schema,row.table_name,row.column_name,lower(row.column_name));
	  END IF;
  END LOOP;
END $$;

ALTER TABLE network_axis RENAME COLUMN "id_net" TO "fid";

ALTER TABLE network_axis ADD PRIMARY KEY (fid);

ALTER TABLE network_axis
ADD CONSTRAINT network_axis_unq_axis
UNIQUE (axis);

CREATE INDEX idx_fid_network_axis
ON network_axis USING btree(fid);

CREATE INDEX idx_geom_network_axis
ON network_axis USING GIST (geom);

-- add gid_region
ALTER TABLE network_axis
ADD COLUMN gid_region integer;

-- update gid_region with spatial join in buffer to fix some intersection
UPDATE network_axis AS nm
SET gid_region = rh.gid
FROM region_hydrographique AS rh
WHERE ST_Within(ST_TRANSFORM(nm.geom, 2154), ST_Buffer(ST_TRANSFORM(rh.geom, 2154), 1000));

-- création d'un index sur gid_region
CREATE INDEX idx_gid_region_network_axis
ON network_axis USING btree(gid_region);
