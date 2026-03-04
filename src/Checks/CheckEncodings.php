<?php

namespace Tualo\Office\DS\Checks;

use Tualo\Office\Basic\Middleware\Session;
use Tualo\Office\Basic\PostCheck;
use Tualo\Office\Basic\TualoApplication as App;



class CheckEncodings  extends PostCheck
{

    public static function test(array $config)
    {
        $clientdb = App::get('clientDB');
        if (is_null($clientdb)) return;

        // /"SET NAMES 'utf8mb4' COLLATE 'utf8mb4_general_ci'")) 
        $found_differences = false;
        $data = $clientdb->direct('show procedure status');
        self::intent();
        self::formatPrintLn(['blue'], 'Check Procedure Status');
        self::intent();
        foreach ($data as $row) {
            if ($clientdb->dbname == $row['db']) {
                if ($row['collation_connection'] != $row['database collation']) {
                    self::formatPrintLn(['red'], $row['db'] . ': ' . $row['name'] . ' has different collations');
                    $found_differences = true;
                }
            }
        }
        self::unintent();


        $data = $clientdb->direct('show function status');
        self::formatPrintLn(['blue'], 'Check Function Status');
        self::intent();
        foreach ($data as $row) {
            if ($clientdb->dbname == $row['db']) {
                if ($row['collation_connection'] != $row['database collation']) {
                    self::formatPrintLn(['red'], $row['db'] . ': ' . $row['name'] . ' has different collations');
                    $found_differences = true;
                }
            }
        }
        self::unintent();
        if ($found_differences) {
            self::formatPrintLn(['yellow'], "please run the following command: `./tm configuration --section database --key set_names --value \"SET NAMES 'utf8mb4' COLLATE 'utf8mb4_general_ci'\"`");
            self::formatPrintLn(['yellow'], "and run recreate on that procedures and functions!");
        }
        self::unintent();
    }
}
