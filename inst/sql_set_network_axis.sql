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