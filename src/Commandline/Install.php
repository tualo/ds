<?php
namespace Tualo\Office\DS\Commandline;
use Tualo\Office\Basic\ICommandline;
use Tualo\Office\Basic\CommandLineInstallSQL;

class Install extends CommandLineInstallSQL  implements ICommandline{
    public static function getDir():string {   return dirname(__DIR__,1); }
    public static $shortName  = 'ds';
    public static $files = [
        // 'main_compiler' => 'setup main compiler views ',
        // 'main_dsx' => 'setup main ds procedures ',
        'custom_types' => 'setup custom types ',
        'addcommand' => 'load addcommand ',
        'ds_files' => 'add ds files ',
        'ds_renderer_stylesheet_attributes_dd' => 'setup ds_renderer_stylesheet_attributes_dd  ',
        'ds_renderer_stylesheet_attributes_dd.ds' => 'setup ds_renderer_stylesheet_attributes_dd  ds ',
        'ds_listplugin'=> 'setup ds_listplugin ',
        'fix_primary_ds_reference_tables'=> 'setup fix_primary_ds_reference_tables ',
        'install/ds_preview_form_label'=> 'setup ds_preview_form_label ',
        'install/ds_preview_form_label.ds'=> 'setup ds_preview_form_label.ds ',

        'install/properties_template'=> 'setup properties_template ',
        'install/ds_property_types'=> 'setup ds_property_types ',
        'install/ds_property_types.ds'=> 'setup ds_property_types.ds ',
        'install/ds_property_definition'=> 'setup ds_property_definition ',
        'install/ds_property_definition.ds'=> 'setup ds_property_definition.ds ',
        'install/fix.id'=> 'setup fix.id ',
        'install/view_readtable_ds_column_list_label_all'=> 'setup view_readtable_ds_column_list_label_all ',
        'install/view_readtable_ds_column_form_label'=> 'setup view_readtable_ds_column_form_label ',

        'install/ds_listplugins'=> 'setup ds_listplugins ',
        'install/ds_listplugins_placements.ds'=> 'setup ds_listplugins_placements.ds ',
        'install/ds_listplugins_ptypes.ds'=> 'setup ds_listplugins_ptypes.ds ',
        'install/ds_listplugins.ds'=> 'setup ds_listplugins.ds ',
        
        
'install/ds/ds.ds' => 'setup ds.ds',
'install/ds/ds_access.ds' => 'setup ds_access.ds',
'install/ds/ds_addcommand_locations.ds' => 'setup ds_addcommand_locations.ds',
'install/ds/ds_addcommands.ds' => 'setup ds_addcommands.ds',
'install/ds/ds_addcommands_xtypes.ds' => 'setup ds_addcommands_xtypes.ds',
'install/ds/ds_additional_columns.ds' => 'setup ds_additional_columns.ds',
'install/ds/ds_class.ds' => 'setup ds_class.ds',
'install/ds/ds_column.ds' => 'setup ds_column.ds',
'install/ds/ds_column_form_label.ds' => 'setup ds_column_form_label.ds',
'install/ds/ds_column_form_properties.ds' => 'setup ds_column_form_properties.ds',
'install/ds/ds_column_list_export.ds' => 'setup ds_column_list_export.ds',
'install/ds/ds_column_list_label.ds' => 'setup ds_column_list_label.ds',
'install/ds/ds_column_tagfields.ds' => 'setup ds_column_tagfields.ds',
'install/ds/ds_column_types.ds' => 'setup ds_column_types.ds',
'install/ds/ds_combined_tables.ds' => 'setup ds_combined_tables.ds',
'install/ds/ds_contextmenu.ds' => 'setup ds_contextmenu.ds',
'install/ds/ds_contextmenu_groups.ds' => 'setup ds_contextmenu_groups.ds',
'install/ds/ds_contextmenu_params.ds' => 'setup ds_contextmenu_params.ds',
'install/ds/ds_contextmenu_session_groups.ds' => 'setup ds_contextmenu_session_groups.ds',
'install/ds/ds_custom_listview_config.ds' => 'setup ds_custom_listview_config.ds',
'install/ds/ds_db_types_fieldtype.ds' => 'setup ds_db_types_fieldtype.ds',
'install/ds/ds_dropdownfields.ds' => 'setup ds_dropdownfields.ds',
'install/ds/ds_export_file_transfer.ds' => 'setup ds_export_file_transfer.ds',
'install/ds/ds_form_properties.ds' => 'setup ds_form_properties.ds',
'install/ds/ds_import_file_transfer.ds' => 'setup ds_import_file_transfer.ds',
'install/ds/ds_listplugins.ds' => 'setup ds_listplugins.ds',
'install/ds/ds_listplugins_placements.ds' => 'setup ds_listplugins_placements.ds',
'install/ds/ds_listplugins_ptypes.ds' => 'setup ds_listplugins_ptypes.ds',
'install/ds/ds_nm_tables.ds' => 'setup ds_nm_tables.ds',
'install/ds/ds_preview_form_label.ds' => 'setup ds_preview_form_label.ds',
'install/ds/ds_property_definition.ds' => 'setup ds_property_definition.ds',
'install/ds/ds_property_types.ds' => 'setup ds_property_types.ds',
'install/ds/ds_pug_templates.ds' => 'setup ds_pug_templates.ds',
'install/ds/ds_reference_tables.ds' => 'setup ds_reference_tables.ds',
'install/ds/ds_referenced_manual.ds' => 'setup ds_referenced_manual.ds',
'install/ds/ds_referenced_manual_columns.ds' => 'setup ds_referenced_manual_columns.ds',
'install/ds/ds_renderer_stylesheet_attributes_dd.ds' => 'setup ds_renderer_stylesheet_attributes_dd.ds',
'install/ds/ds_searchfields.ds' => 'setup ds_searchfields.ds',
'install/ds/ds_statistics.ds' => 'setup ds_statistics.ds',
'install/ds/ds_sync_data.ds' => 'setup ds_sync_data.ds',
'install/ds/ds_trigger.ds' => 'setup ds_trigger.ds',
'install/ds/ds_used_tables.ds' => 'setup ds_used_tables.ds'
        /*
        ds.ds.sql
ds_access.ds.sql
ds_addcommand_locations.ds.sql
ds_addcommands.ds.sql
ds_addcommands_xtypes.ds.sql
ds_additional_columns.ds.sql
ds_class.ds.sql
ds_column.ds.sql
ds_column_form_label.ds.sql
ds_column_form_properties.ds.sql
ds_column_list_export.ds.sql
ds_column_list_label.ds.sql
ds_column_tagfields.ds.sql
ds_column_types.ds.sql
ds_combined_tables.ds.sql
ds_contextmenu.ds.sql
ds_contextmenu_groups.ds.sql
ds_contextmenu_params.ds.sql
ds_contextmenu_session_groups.ds.sql
ds_custom_listview_config.ds.sql
ds_db_types_fieldtype.ds.sql
ds_dropdownfields.ds.sql
ds_export_file_transfer.ds.sql
ds_form_properties.ds.sql
ds_import_file_transfer.ds.sql
ds_listplugins.ds.sql
ds_listplugins_placements.ds.sql
ds_listplugins_ptypes.ds.sql
ds_nm_tables.ds.sql
ds_preview_form_label.ds.sql
ds_property_definition.ds.sql
ds_property_types.ds.sql
ds_pug_templates.ds.sql
ds_reference_tables.ds.sql
ds_referenced_manual.ds.sql
ds_referenced_manual_columns.ds.sql
ds_renderer_stylesheet_attributes_dd.ds.sql
ds_searchfields.ds.sql
ds_statistics.ds.sql
ds_sync_data.ds.sql
ds_trigger.ds.sql
ds_used_tables.ds.sql
        */
    ];
    
}