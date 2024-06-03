<?php
namespace Tualo\Office\DS\Commandline;
use Tualo\Office\Basic\ICommandline;
use Tualo\Office\Basic\CommandLineInstallSQL;

class InstallDocsystem extends CommandLineInstallSQL  implements ICommandline{
    public static function getDir():string {   return dirname(__DIR__,1); }
    public static $shortName  = 'ds-docsystem';
    public static $files = [

        'docsystem/docsystem_ds'=> 'setup docsystem_ds ',
        'docsystem/docsystem_ds_column'=> 'setup docsystem_ds_column ',
        'docsystem/docsystem_groups'=> 'setup docsystem_groups ',
        
        'docsystem/view_docsystem_ds_access'=> 'setup view_docsystem_ds_access ',
        'docsystem/view_docsystem_ds_column_documentation'=> 'setup view_docsystem_ds_column_documentation ',
        'docsystem/view_docsystem_ds_ds_reference_tables'=> 'setup view_docsystem_ds_ds_reference_tables ',
        'docsystem/view_docsystem_ds_ds_reference_tables_used_ds'=> 'setup view_docsystem_ds_ds_reference_tables_used_ds ',
        
        'docsystem/pug'=> 'setup pug templates ',

    ];
    
}