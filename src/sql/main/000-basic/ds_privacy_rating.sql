DELIMITER //
create table if not exists  ds_privacy_rating_types (
  id varchar(36) primary key,
  name varchar(255) not null,
  `score` integer default 0
) //

insert IGNORE into ds_privacy_rating_types (id,name,score) 
values ('undefined','Unbestimmt',0) //

create table if not exists ds_privacy_rating (
  table_name varchar(128) ,
  type_id varchar(36) not null,
  active tinyint default 0,
  primary key (table_name,type_id),
  
  constraint `fk_ds_privacy_rating_type_id`
  foreign key (type_id)
  references ds_privacy_rating_types (id)
  on delete cascade
  on update cascade,
  
  constraint `fk_ds_privacy_rating_table_name`
  foreign key (table_name)
  references ds (table_name)
  on delete cascade
  on update cascade
) //

create or replace view view_readtable_ds_privacy_rating as 
select
ds.table_name,
ds_privacy_rating_types.id type_id,
ifnull(ds_privacy_rating.active,0) active
from
ds
join ds_privacy_rating_types
left join ds_privacy_rating 
	on ds.table_name = ds_privacy_rating.table_name and ds_privacy_rating_types.id = ds_privacy_rating.type_id //