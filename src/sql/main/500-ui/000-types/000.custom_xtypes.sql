delimiter ;

-- drop table custom_types_attributes_boolean;
-- drop table custom_types_attributes_string;
-- drop table custom_types_attributes_integer;
-- drop table custom_types;

create table if not exists `custom_types` (
    id varchar(100) primary key,
    xtype_long_classic varchar(100) default null,
    xtype_long_modern varchar(100) default null,
    extendsxtype_classic varchar(100) default null,
    extendsxtype_modern varchar(100) default null,
    name varchar(100) not null,
    vendor varchar(50) not null,
    description varchar(255) default '',
    create_datetime datetime default CURRENT_TIMESTAMP,
    login varchar(100) default null
);




create or replace view view_readtable_custom_types as
select 
    `id`,
    `xtype_long_modern`,
    `xtype_long_classic`,

    SUBSTRING_INDEX(`xtype_long_modern`, '.', 1) `modern_typeclass`,
    SUBSTRING_INDEX(`xtype_long_modern`, '.', -1) `modern_type`,

    SUBSTRING_INDEX(`xtype_long_classic`, '.', 1) `classic_typeclass`,
    SUBSTRING_INDEX(`xtype_long_classic`, '.', -1) `classic_type`,

    `name`,
    `vendor`,
    `description`

from `custom_types` 
;


 

create table if not exists `custom_types_attributes_integer` (
    id varchar(100) not null,
    property varchar(100) not null,
    primary key(id,property),
    description varchar(255) default '',

    val integer default null,
    
    constraint `fk_custom_types_attributes_integer_id`
    foreign key (id)
    references custom_types(id)
    on delete cascade
    on update cascade
);

create table if not exists `custom_types_attributes_string` (
    id varchar(100) not null,
    property varchar(100) not null,
    primary key(id,property),
    description varchar(255) default '',

    val varchar(255) default null,
    
    constraint `fk_custom_types_attributes_string_id`
    foreign key (id)
    references custom_types(id)
    on delete cascade
    on update cascade
);


create table if not exists `custom_types_attributes_boolean` (
    id varchar(100) not null,
    property varchar(100) not null,
    primary key(id,property),
    description varchar(255) default '',

    val tinyint default null,

    constraint `fk_custom_types_attributes_boolean_id`
    foreign key (id)
    references custom_types(id)
    on delete cascade
    on update cascade
);

insert into custom_types 
(id,xtype_long_classic,xtype_long_modern,extendsxtype_classic,extendsxtype_modern,name,vendor) values 
('Tualo.grid.column.Number5','widget.tualocolumnnumber5','widget.tualocolumnnumber5','Ext.grid.column.Number','Ext.grid.column.Number',
'Tualo.grid.column.Number5','Tualo') on duplicate key update 
    id=values(id),
    extendsxtype_modern=values(extendsxtype_modern),
    name=values(name),
    vendor=values(vendor)
;

insert into custom_types_attributes_string (id,property,val) values 
('Tualo.grid.column.Number5','format','0.000,00000'),
('Tualo.grid.column.Number5','defaultFilterType','number'),
('Tualo.grid.column.Number5','align','right')
on duplicate key update id=values(id),val=values(val);

insert into custom_types 
(id,xtype_long_classic,xtype_long_modern,extendsxtype_classic,extendsxtype_modern,name,vendor) values 
('Tualo.grid.column.Number0','widget.tualocolumnnumber0','widget.tualocolumnnumber0','Ext.grid.column.Number','Ext.grid.column.Number',
'Tualo.grid.column.Number0','Tualo') on duplicate key update 
    id=values(id),
    extendsxtype_modern=values(extendsxtype_modern),
    name=values(name),
    vendor=values(vendor)
;
insert into custom_types_attributes_string (id,property,val) values 
('Tualo.grid.column.Number0','format','0.000/i'),
('Tualo.grid.column.Number0','defaultFilterType','number'),
('Tualo.grid.column.Number0','align','right')
on duplicate key update id=values(id),val=values(val);


insert into custom_types 
(id,xtype_long_classic,xtype_long_modern,extendsxtype_classic,extendsxtype_modern,name,vendor) values 
('Tualo.grid.column.Number2','widget.tualocolumnnumber2','widget.tualocolumnnumber2','Ext.grid.column.Number','Ext.grid.column.Number',
'Tualo.grid.column.Number2','Tualo') on duplicate key update 
    id=values(id),
    extendsxtype_modern=values(extendsxtype_modern),
    name=values(name),
    vendor=values(vendor)
;
insert into custom_types_attributes_string (id,property,val) values 
('Tualo.grid.column.Number2','format','0.000,00'),
('Tualo.grid.column.Number2','defaultFilterType','number'),
('Tualo.grid.column.Number2','align','right')
on duplicate key update id=values(id),val=values(val);


insert into custom_types 
(id,xtype_long_classic,xtype_long_modern,extendsxtype_classic,extendsxtype_modern,name,vendor) values 
('Tualo.grid.column.MoneyColumn2','widget.moneycolumn2','widget.moneycolumn2','Ext.grid.column.Number','Ext.grid.column.Number',
'Tualo.grid.column.MoneyColumn2','Tualo') on duplicate key update 
    id=values(id),
    extendsxtype_modern=values(extendsxtype_modern),
    name=values(name),
    vendor=values(vendor)
;
insert into custom_types_attributes_string (id,property,val) values 
('Tualo.grid.column.MoneyColumn2','format','0.000,00'),
('Tualo.grid.column.MoneyColumn2','defaultFilterType','number'),
('Tualo.grid.column.MoneyColumn2','align','right')
on duplicate key update id=values(id),val=values(val);

insert into custom_types 
(id,xtype_long_classic,xtype_long_modern,extendsxtype_classic,extendsxtype_modern,name,vendor) values 
('Tualo.grid.column.MoneyColumn5','widget.moneycolumn5','widget.moneycolumn5','Ext.grid.column.Number','Ext.grid.column.Number',
'Tualo.grid.column.MoneyColumn5','Tualo') on duplicate key update 
    id=values(id),
    extendsxtype_modern=values(extendsxtype_modern),
    name=values(name),
    vendor=values(vendor)
;
insert into custom_types_attributes_string (id,property,val) values 
('Tualo.grid.column.MoneyColumn5','format','0.000,00/i'),
('Tualo.grid.column.MoneyColumn5','defaultFilterType','number'),
('Tualo.grid.column.MoneyColumn5','align','right')
on duplicate key update id=values(id),val=values(val);




insert into custom_types 
(id,xtype_long_classic,xtype_long_modern,extendsxtype_classic,extendsxtype_modern,name,vendor) values 
('Tualo.grid.column.DEDateDisplayColumn','widget.tualodedatedisplaycolumn','widget.tualodedatedisplaycolumn','Ext.grid.column.Date','Ext.grid.column.Date',
'Tualo.grid.column.DEDateDisplayColumn','Tualo') on duplicate key update 
    id=values(id),
    extendsxtype_modern=values(extendsxtype_modern),
    name=values(name),
    vendor=values(vendor)
;
insert into custom_types_attributes_string (id,property,val) values 
('Tualo.grid.column.DEDateDisplayColumn','format','d.m.Y'),
('Tualo.grid.column.DEDateDisplayColumn','defaultFilterType','date'),
('Tualo.grid.column.DEDateDisplayColumn','align','center')
on duplicate key update id=values(id),val=values(val);


insert into custom_types 
(id,xtype_long_classic,xtype_long_modern,extendsxtype_classic,extendsxtype_modern,name,vendor) values 
('Tualo.grid.column.DatetimeDisplayColumn','widget.tualodatetimedisplaycolumn','widget.tualodatetimedisplaycolumn','Ext.grid.column.Date','Ext.grid.column.Date',
'Tualo.grid.column.DatetimeDisplayColumn','Tualo') on duplicate key update 
    id=values(id),
    extendsxtype_modern=values(extendsxtype_modern),
    name=values(name),
    vendor=values(vendor)
;
insert into custom_types_attributes_string (id,property,val) values 
('Tualo.grid.column.DatetimeDisplayColumn','format','d.m.Y H:i'),
('Tualo.grid.column.DatetimeDisplayColumn','defaultFilterType','date'),
('Tualo.grid.column.DatetimeDisplayColumn','align','center')
on duplicate key update id=values(id),val=values(val);



insert ignore into custom_types (        vendor,        name,        id, xtype_long_classic, extendsxtype_classic,        xtype_long_modern,        extendsxtype_modern    ) values ( "Tualo",  "Ext.tualo.form.field.DSFields", "Ext.tualo.form.field.DSFields", "widget.tualodsfields", "Ext.form.field.ComboBox", "widget.textarea", "Ext.field.Text" ) on duplicate key update    id =values(id), xtype_long_classic = values(xtype_long_classic),    extendsxtype_classic = values(extendsxtype_classic),name = values(name),vendor = values(vendor);
insert ignore into custom_types (        vendor,        name,        id, xtype_long_classic, extendsxtype_classic,        xtype_long_modern,        extendsxtype_modern    ) values ( "Tualo",  "Ext.tualo.form.field.ListSelection", "Ext.tualo.form.field.ListSelection", "widget.tualolistselection", "Ext.form.field.ComboBox", "widget.textarea", "Ext.field.Text" ) on duplicate key update    id =values(id), xtype_long_classic = values(xtype_long_classic),    extendsxtype_classic = values(extendsxtype_classic),name = values(name),vendor = values(vendor);
