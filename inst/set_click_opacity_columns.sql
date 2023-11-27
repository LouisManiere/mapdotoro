-- bassin hydrographique

alter table bassin_hydrographique
add column click bool;
alter table bassin_hydrographique
add column opacity numeric;

update bassin_hydrographique
set click = TRUE
where gid in (6);

update bassin_hydrographique
set click = FALSE
where gid not in (6);

update bassin_hydrographique
set opacity = 0.01
where gid in (6);

update bassin_hydrographique
set opacity = 0.10
where gid not in (6);

-- region hydrographique

alter table region_hydrographique
add column click bool;
alter table region_hydrographique
add column opacity numeric;

update region_hydrographique
set click = TRUE
where gid in (11, 16, 31, 33);

update region_hydrographique
set click = FALSE
where gid not in (11, 16, 31, 33);

update region_hydrographique
set opacity = 0.01
where gid in (11, 16, 31, 33);

update region_hydrographique
set opacity = 0.10
where gid not in (11, 16, 31, 33);
