<?php

namespace Tualo\Office\DS\Commandline;

use Garden\Cli\Cli;
use Garden\Cli\Args;
use phpseclib3\Math\BigInteger\Engines\PHP;
use Tualo\Office\Basic\ICommandline;
use Tualo\Office\ExtJSCompiler\Helper;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\PostCheck;

class DumpDS implements ICommandline
{

    public static function getCommandName(): string
    {
        return 'export-ds';
    }

    public static function setup(Cli $cli)
    {
        $cli->command(self::getCommandName())
            ->description('export dataset configuration')
            ->opt('client', 'the client system to export from', false)
            ->arg('dataset', 'dataset name to export', true, 'string');
    }


    public static function runOnClient(string $msg, string $clientName, callable $callback)
    {
        $_SERVER['REQUEST_URI'] = '';
        $_SERVER['REQUEST_METHOD'] = 'none';
        App::run();

        $session = App::get('session');
        $sessiondb = $session->db;
        $dbs = $sessiondb->direct('select username db_user, password db_pass, id db_name, host db_host, port db_port from macc_clients ');
        foreach ($dbs as $db) {
            if (($clientName != '') && ($clientName != $db['db_name'])) {
                continue;
            } else {
                App::set('clientDB', $session->newDBByRow($db));
                App::set('clientDBCredentials', $db);
                $callback();
                break;
            }
        }
    }

    public static function run(Args $args)
    {

        $export = function () {
            $clientDBCredentials = App::get('clientDBCredentials');
            $p = '';
            if ($clientDBCredentials['dbport'] != '') $p  = ' -P' . $clientDBCredentials['dbport'];
            if ($clientDBCredentials['dbpass'] != '') $p .= ' -p"' . $clientDBCredentials['dbpass'] . '"';

            exec(dirname(__DIR__, 1) . "/sqlexport/dump_ds_definition \"" . App::get('dataset') . "\" -h" . $clientDBCredentials['db_host'] . " -u" . $clientDBCredentials['db_user'] . " " . $p . " " . $clientDBCredentials['db_name'] . " ", $output, $return);
            echo implode(PHP_EOL, $output);
            exec(dirname(__DIR__, 1) . "/sqlexport/dump_ds_access \"" . App::get('dataset') . "\" -h" . $clientDBCredentials['db_host'] . " -u" . $clientDBCredentials['db_user'] . " " . $p . " " . $clientDBCredentials['db_name'] . " ", $output, $return);
            echo implode(PHP_EOL, $output);
        };
        App::set('dataset', $args->getArg('dataset'));

        $clientName = $args->getOpt('client');
        if (is_null($clientName)) $clientName = '';
        self::runOnClient("setup main compiler views ", $clientName, $export);
    }
}
