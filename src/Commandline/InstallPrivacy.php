<?php
namespace Tualo\Office\DS\Commandline;
use Tualo\Office\Basic\ICommandline;
use Tualo\Office\Basic\CommandLineInstallSQL;

class InstallPrivacy extends CommandLineInstallSQL  implements ICommandline{
    public static function getDir():string {   return dirname(__DIR__,1); }
    public static $shortName  = 'ds-privacy';
    public static $files = [

        'privacy/ds_privacy_rating_types'=> 'setup ds_privacy_rating_types ',
        'privacy/ds_privacy_rating'=> 'setup ds_privacy_rating ',
        'privacy/ds_privacy_rating_types.ds'=> 'setup ds_privacy_rating_types.ds ',
        'privacy/ds_privacy_rating.ds'=> 'setup ds_privacy_rating.ds ',

    ];
    
}