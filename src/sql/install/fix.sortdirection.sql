delimiter ;

alter table ds add column if not exists sortdirection varchar(10) default 'ASC';
