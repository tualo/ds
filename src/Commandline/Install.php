<?php
namespace Tualo\Office\DS\Commandline;
use Tualo\Office\Basic\ICommandline;
use Tualo\Office\Basic\CommandLineInstallSQL;

class Install extends CommandLineInstallSQL  implements ICommandline{
    public static function getDir():string {   return dirname(__DIR__,1); }
    public static $shortName  = 'ds';
    public static $files = [
        'main_compiler' => 'setup main compiler views ',
        'main_dsx' => 'setup main ds procedures ',
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
    ];
    
}