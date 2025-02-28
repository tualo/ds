<?php

namespace Tualo\Office\DS\Commandline;

use Tualo\Office\Basic\ICommandline;
use Tualo\Office\Basic\CommandLineInstallSQL;

class InstallMain extends CommandLineInstallSQL  implements ICommandline
{
    public static function getDir(): string
    {
        return dirname(__DIR__, 1);
    }
    public static $shortName  = 'ds-main';
    public static $files = [
        'main/000-basic/000.fieldquote' => 'setup 000.fieldquote ',
        'main/000-basic/000.standardize_version' => 'setup 000.standardize_version ',
        'main/000-basic/001.getdskeysql' => 'setup 001.getdskeysql ',
        'main/000-basic/002.fn_ds_defaults' => 'setup 002.fn_ds_defaults ',
        'main/000-basic/ds_privacy_rating' => 'setup ds_privacy_rating ',
        'main/100-insert/001.ds_insert' => 'setup 001.ds_insert ',
        'main/100-read/001.fn_ds_read_order_ex' => 'setup 001.fn_ds_read_order_ex ',
        'main/100-read/001.fn_json_attribute_values' => 'setup 001.fn_json_attribute_values ',
        'main/100-read/001.fn_json_filter_values' => 'setup 001.fn_json_filter_values ',
        'main/100-read/001.fn_json_filter_values_extract' => 'setup 001.fn_json_filter_values_extract ',
        'main/100-read/001.fn_json_operator' => 'setup 001.fn_json_operator ',
        'main/100-read/010.fn_ds_read' => 'setup 010.fn_ds_read ',
        'main/100-update/001.ds_update' => 'setup 001.ds_update ',
        'main/500-ui/000-types/000.custom_xtypes' => 'setup 000.custom_xtypes ',
        'main/500-ui/000-types/000.xtypes' => 'setup 000.xtypes ',
        'main/500-ui/000-types/001.custom' => 'setup 001.custom ',
        'main/500-ui/000-types/003.dstypes' => 'setup 003.dstypes ',
        'main/500-ui/010-model/010.view_ds_model' => 'setup 010.view_ds_model ',
        'main/500-ui/020-store/020.view_ds_store' => 'setup 020.view_ds_store ',
        'main/500-ui/030-column/030.view_ds_column' => 'setup 030.view_ds_column ',
        'main/500-ui/030-column/030.view_ds_columnfilters' => 'setup 030.view_ds_columnfilters ',
        'main/500-ui/040-field/040.display' => 'setup 040.display ',
        'main/500-ui/040-field/041.combobox' => 'setup 041.combobox ',
        'main/500-ui/040-field/042.displaylink' => 'setup 042.displaylink ',
        'main/500-ui/040-field/043.linkedcombobox' => 'setup 043.linkedcombobox ',

        'main/500-ui/050-list/050.view_ds_listcolumn' => 'setup 050.view_ds_listcolumn ',
        'install/ds/ds_listroutes' => 'setup ds_listroutes', // quickfix
        'main/500-ui/050-list/054.view_ds_list' => 'setup 054.view_ds_list ',
        'main/500-ui/050-list/view_dd_column' => 'setup view_dd_column ',
        'main/500-ui/060-form/064.view_ds_formfieldgroups' => 'setup 064.view_ds_formfieldgroups ',
        'main/500-ui/060-form/065.view_ds_formfields' => 'setup 065.view_ds_formfields ',
        'main/500-ui/060-form/066.view_ds_form' => 'setup 066.view_ds_form ',
        'main/500-ui/060-form/view_reportform_fieldgroups' => 'setup view_reportform_fieldgroups ',
        'main/500-ui/061-preview/061-preview' => 'setup 061-preview ',
        'main/500-ui/070-controller/070.view_ds_controller' => 'setup 070.view_ds_controller ',
        'main/500-ui/071-model/071.view_ds_viewmodel' => 'setup 071.view_ds_viewmodel ',
        'main/500-ui/080-dsview/080.view_ds_dsview' => 'setup 080.view_ds_dsview ',
        'main/999-dsbackup/importance' => 'setup importance ',
    ];
}
