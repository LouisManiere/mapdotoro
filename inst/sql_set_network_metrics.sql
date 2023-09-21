-- network_metrics

-- rename col with lowercase
DO $$
DECLARE row record;
BEGIN
  FOR row IN SELECT table_schema,table_name,column_name
             FROM information_schema.columns
             WHERE table_schema = 'public' AND
             table_name   = 'network_metrics'
  LOOP
  IF row.column_name != lower(row.column_name) THEN
    EXECUTE format('ALTER TABLE %I.%I RENAME COLUMN %I TO %I',
      row.table_schema,row.table_name,row.column_name,lower(row.column_name));
	  END IF;
  END LOOP;
END $$;

ALTER TABLE network_metrics RENAME COLUMN "m" TO "measure";

ALTER TABLE network_metrics RENAME COLUMN "id_net" TO "fid";

ALTER TABLE network_metrics ADD PRIMARY KEY (fid);

ALTER TABLE network_metrics
ADD CONSTRAINT network_metrics_unq_axis_measure
UNIQUE (axis, measure);

CREATE INDEX idx_fid_network_metrics
ON network_metrics USING btree(fid);

CREATE INDEX idx_geom_network_metrics
ON network_metrics USING GIST (geom);

-- Ajouter la colonne gid_region à la table network_metrics
ALTER TABLE network_metrics
ADD COLUMN gid_region integer;

-- Mettre à jour la colonne gid_region en utilisant une jointure spatiale
UPDATE network_metrics AS nm
SET gid_region = rh.gid
FROM region_hydrographique AS rh
WHERE ST_Within(nm.geom, rh.geom);

-- création d'un index sur gid_region
CREATE INDEX idx_gid_region_network_metrics
ON network_metrics USING btree(gid_region);
