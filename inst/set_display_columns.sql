-- bassin hydrographique

alter table bassin_hydrographique
add column display bool;

update bassin_hydrographique
set display = TRUE
where gid in (6);

update bassin_hydrographique
set display = FALSE
where gid not in (6);

-- region hydrographique

alter table region_hydrographique
add column display bool;

update region_hydrographique
set display = TRUE
where gid in (11, 16, 31, 33);

update region_hydrographique
set display = FALSE
where gid not in (11, 16, 31, 33);
