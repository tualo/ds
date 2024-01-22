delimiter ;

alter table extjs_base_types add if not exists iscolumn tinyint default 0;
alter table extjs_base_types add if not exists isformfield tinyint default 0;


alter table ds add if not exists phpexporterfilename varchar(255) default 'export.xslx';
alter table ds modify phpexporterfilename varchar(255) default 'export.xslx';

alter table ds_reference_tables add if not exists existsreal  tinyint default 0;

update ds_column_list_label set summaryrenderer = 'number'  where summaryrenderer = 'count';


insert ignore into custom_types (        vendor,        name,        id, xtype_long_classic, extendsxtype_classic,        xtype_long_modern,        extendsxtype_modern    ) values ( "Tualo",  "Ext.tualo.form.field.IBAN", "Ext.tualo.form.field.IBAN", "widget.iban", "Ext.form.field.Text", "widget.textarea", "Ext.field.Text" ) on duplicate key update    id =values(id), xtype_long_classic = values(xtype_long_classic),    extendsxtype_classic = values(extendsxtype_classic),name = values(name),vendor = values(vendor);
insert ignore into custom_types (        vendor,        name,        id, xtype_long_classic, extendsxtype_classic,        xtype_long_modern,        extendsxtype_modern    ) values ( "Tualo",  "Ext.tualo.form.field.BIC", "Ext.tualo.form.field.BIC", "widget.bic", "Ext.form.field.ComboBox", "widget.textarea", "Ext.field.Text" ) on duplicate key update    id =values(id), xtype_long_classic = values(xtype_long_classic),    extendsxtype_classic = values(extendsxtype_classic),name = values(name),vendor = values(vendor);

insert ignore into custom_types (        vendor,        name,        id, xtype_long_classic, extendsxtype_classic,        xtype_long_modern,        extendsxtype_modern    ) values ( "Tualo",  "Ext.tualo.form.field.DocumentDisplayField", "Ext.tualo.form.field.DocumentDisplayField", "widget.dsdocumentdisplayfield", "Ext.form.field.Display", "widget.textarea", "Ext.field.Text" ) on duplicate key update    id =values(id), xtype_long_classic = values(xtype_long_classic),    extendsxtype_classic = values(extendsxtype_classic),name = values(name),vendor = values(vendor);


update ds set alternativeformxtype='' where alternativeformxtype in ('0','1');
update ds_column set column_name = lower(column_name) ;
update ds_column_list_label set column_name = lower(column_name) ;
update ds_column_form_label set column_name = lower(column_name) ;


update ds_column_list_label set renderer='' where renderer='Tualo.renderer.CSSMetaRenderer';

