set foreign_key_checks=0;
alter table ds_renderer_stylesheet_groups modify id varchar(128);
alter table ds_renderer_stylesheet_groups_assign modify group_id varchar(128);
alter table ds_renderer_stylesheet modify `group` varchar(128);

set foreign_key_checks=1;
call fill_ds_column('ds_renderer_stylesheet_groups');
call fill_ds_column('ds_renderer_stylesheet_groups_assign');
call fill_ds_column('ds_renderer_stylesheet');
