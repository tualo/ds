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
        return 'cms auth tokens';
    }

    public static function testSessionDB(array $config): int
    {
        return 0;
    }

    public static function test(array $config): int
    {
        $return_value = 0;

        $clientdb = App::get('clientDB');
        if (is_null($clientdb)) return 1;
        // self::formatPrintLn(['blue'], 'AuthTokens SystemCheck:');

        $allowed_valid_days = 21;


        $tables = $clientdb->direct('show tables');
        if (count($tables) == 0) {
            self::formatPrintLn(['red'], 'No Tables found.');
            return 2;
        }

        foreach ($tables as $table) {

            if (isset($table['Tables_in_' . $clientdb->dbname])) {
                $tablename =  $table['Tables_in_' . $clientdb->dbname];
                self::intent();
                self::formatPrintLn(['blue'], 'Table found: ' . $tablename);

                $ds_columns = $clientdb->direct('select * from ds_columns where table_name = {table_name}', ['table_name' => $tablename]);
                $explained_columns = $clientdb->direct('explain ' . $tablename);
                if (count($ds_columns) == 0) {
                    self::formatPrintLn(['red'], 'No DS Columns found for table: ' . $tablename);
                    self::unintent();
                    return 2;
                } else {
                    self::formatPrintLn(['green'], 'DS Columns found for table: ' . $tablename);
                }
                $missing_columns = [];
                foreach ($ds_columns as $column) {
                    $column_name = $column['column_name'];
                    $found = false;
                    foreach ($explained_columns as $explained_column) {
                        if ($explained_column['Field'] == $column_name) {
                            $found = true;
                            break;
                        }
                    }
                    if (!$found) {
                        $missing_columns[] = $column_name;
                    }
                }
                if (count($missing_columns) > 0) {
                    self::formatPrintLn(['red'], 'Missing columns in table ' . $tablename . ': ' . implode(', ', $missing_columns));
                    self::unintent();
                    return 2;
                } else {
                    self::formatPrintLn(['green'], 'All DS Columns found in table: ' . $tablename);
                }
                $missing_ds_columns = [];
                foreach ($explained_columns as $explained_column) {
                    $column_name = $explained_column['Field'];
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
                    self::formatPrintLn(['red'], 'Missing DS Columns in ds_columns for table ' . $tablename . ': ' . implode(', ', $missing_ds_columns));
                    self::unintent();
                    return 2;
                } else {
                    self::formatPrintLn(['green'], 'All DS Columns found in ds_columns for table: ' . $tablename);
                }


                // compare explain type with ds_column coluzmn_type
                $wrong_types = [];
                foreach ($ds_columns as $ds_column) {
                    $column_name = $ds_column['column_name'];
                    $column_type = $ds_column['column_type'];
                    $found = false;
                    foreach ($explained_columns as $explained_column) {
                        if ($explained_column['Field'] == $column_name) {
                            if ($explained_column['Type'] != $column_type) {
                                $wrong_types[] = $column_name . ' (' . $explained_column['Type'] . ' != ' . $column_type . ')';
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
                    self::formatPrintLn(['red'], 'Wrong types in ds_columns for table ' . $tablename . ': ' . implode(', ', $wrong_types));
                    self::unintent();
                    return 2;
                } else {
                    self::formatPrintLn(['green'], 'All DS Column types match in ds_columns for table: ' . $tablename);
                }

                /*
                $tualocms_domain_ips = $clientdb->direct('select * from tualocms_domain_ip where domain = {domain}', $domain);
                if (count($tualocms_domain_ips) == 0) {

                    $dns = dns_get_record($domain['domain'], DNS_A | DNS_AAAA);
                    if (count($dns) == 0) {
                        self::formatPrintLn(['red'], 'No DNS records found for domain: ' . $domain['domain']);
                        self::unintent();
                        return 2;
                    } else {
                        self::formatPrintLn(['yellow'], 'No IPs found in database for domain: ' . $domain['domain'] . ', using DNS records instead.');
                        $tualocms_domain_ips = array_map(function ($ip) {
                            if (isset($ip['ipv6'])) {
                                $ip['ip'] = $ip['ipv6'];
                            }
                            return ['ip' => $ip['ip']];
                        }, $dns);

                        foreach ($tualocms_domain_ips as $domain_ip) {
                            //tualocms_domain_ip
                            $sql = '
                            insert ignore into tualocms_domain_ip (domain, ip) values ({domain}, {ip}) 
                            ';
                            $clientdb->direct($sql, [
                                'domain' => $domain['domain'],
                                'ip' => $domain_ip['ip']
                            ]);
                            self::formatPrintLn(['green'], '✅  Added IP: ' . $domain['domain'] . ' -> ' . $domain_ip['ip']);
                        }
                    }
                }
                $last_fingerprint = '';
                $last_valid_date = 0;
                */
                self::unintent();
            }
        }
        return $return_value;
    }
}
