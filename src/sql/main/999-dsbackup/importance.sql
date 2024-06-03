DELIMITER //
create table if not exists ds_backup_importance (
  table_name varchar(128) primary key,
  type varchar(20),
  importance decimal(4,3) default 1.0,
  CONSTRAINT `fk_ds_backup_importance_ds` FOREIGN KEY (`table_name`) REFERENCES `ds` (`table_name`) ON DELETE CASCADE ON UPDATE CASCADE
) //

