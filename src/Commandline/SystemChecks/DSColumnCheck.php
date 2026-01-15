<?php

namespace Tualo\Office\DS\Commandline\SystemChecks;

use Tualo\Office\Basic\SystemCheck;
use Tualo\Office\Basic\TualoApplication as App;

class DSColumnCheck extends SystemCheck
{

    public static function hasClientTest(): bool
    {
        return true;
    }

    public static function hasSessionTest(): bool
    {
        return false;
    }

    public static function getModuleName(): string
    {
        return 'ds table type check';
    }

    public static function testSessionDB(array $config): int
    {
        return 0;
    }

    public static function test(array $config): int
    {
        $return_value = 0;

        $clientdb = App::get('clientDB');
        if (is_null($clientdb)) {
            self::formatPrintLn(['red'], 'No Tables found.');
            return 1;
        }
        // self::formatPrintLn(['blue'], 'AuthTokens SystemCheck:');

        $allowed_valid_days = 21;


        $tables = $clientdb->direct('show tables');
        if (count($tables) == 0) {
            self::formatPrintLn(['red'], 'No Tables found.');
            return 2;
        }

        $tablestatus = $clientdb->direct('show table status', [], 'name');

        $key = 'tables_in_' . $clientdb->dbname;
        foreach ($tables as $table) {
            foreach ($table as $k => $v) {
                $key = $k;
                break;
            }
            break;
        }


        //echo $key;
        //print_r($tables);
        foreach ($tables as $table) {
            if (isset($table[$key])) {
                $tablename =  $table[$key];

                self::intent();
                self::formatPrintLn(['blue'], 'Table found: ' . $tablename);

                $isView = false;
                if (isset($tablestatus[$tablename])) {
                    $status = $tablestatus[$tablename];
                    if ($status['comment'] == 'VIEW') {
                        $isView = true;
                    }
                }

                $ds_columns = $clientdb->direct('select * from ds_column where table_name = {table_name} and existsreal=1 and writeable=1', ['table_name' => $tablename]);
                $explained_columns = $clientdb->direct('explain ' . $tablename);
                if (count($ds_columns) == 0) {
                    self::formatPrintLn([$isView ? 'yellow' : 'red'], 'No DS Columns found for table: ' . $tablename);
                    //self::unintent();

                    $return_value = 2;
                } else {
                    // self::formatPrintLn(['green'], 'DS Columns found for table: ' . $tablename);
                }
                $missing_columns = [];
                foreach ($ds_columns as $column) {
                    $column_name = $column['column_name'];
                    $found = false;
                    foreach ($explained_columns as $explained_column) {
                        if ($explained_column['field'] == $column_name) {
                            $found = true;
                            break;
                        }
                    }
                    if (!$found) {
                        $missing_columns[] = $column_name;
                    }
                }
                if (count($missing_columns) > 0) {
                    self::formatPrintLn([$isView ? 'yellow' : 'red'], 'Missing columns in table ' . $tablename . ': ' . implode(', ', $missing_columns));
                    //self::unintent();

                    $return_value = 2;
                } else {
                    // self::formatPrintLn(['green'], 'All DS Columns found in table: ' . $tablename);
                }
                $missing_ds_columns = [];
                foreach ($explained_columns as $explained_column) {
                    $column_name = $explained_column['field'];
                    $found = false;
                    foreach ($ds_columns as $ds_column) {
                        if ($ds_column['column_name'] == $column_name) {
                            $found = true;
                            break;
                        }
                    }
                    if (!$found) {
                        $missing_ds_columns[] = $column_name;
                    }
                }
                if (count($missing_ds_columns) > 0) {
                    self::formatPrintLn([$isView ? 'yellow' : 'red'], 'Missing DS Columns in ds_column for table ' . $tablename . ': ' . implode(', ', $missing_ds_columns));
                    // self::unintent();

                    $return_value = 2;
                } else {
                    // self::formatPrintLn(['green'], 'All DS Columns found in ds_column for table: ' . $tablename);
                }


                // compare explain type with ds_column column_type
                $wrong_types = [];
                foreach ($ds_columns as $ds_column) {
                    $column_name = $ds_column['column_name'];
                    $column_type = $ds_column['column_type'];
                    $found = false;
                    foreach ($explained_columns as $explained_column) {
                        if ($explained_column['field'] == $column_name) {
                            if ($explained_column['type'] != $column_type) {
                                if ($explained_column['type'] != 'mediumtext' && $column_type != 'longtext') {
                                    // allow mediumtext vs longtext difference

                                } else {
                                    $wrong_types[] = $column_name . ' (' . $explained_column['type'] . ' != ' . $column_type . ')';
                                }
                            }
                            $found = true;
                            break;
                        }
                    }
                    if (!$found) {
                        $missing_columns[] = $column_name;
                    }
                }
                if (count($wrong_types) > 0) {
                    self::formatPrintLn([$isView ? 'yellow' : 'red'], 'Wrong types in ds_columns for table ' . $tablename . ': ' . implode(', ', $wrong_types));
                    //self::unintent();
                    $return_value = 2;
                } else {
                    // self::formatPrintLn(['green'], 'All DS Column types match in ds_columns for table: ' . $tablename);
                }
                self::unintent();
            }
        }
        return $return_value;
    }
}
