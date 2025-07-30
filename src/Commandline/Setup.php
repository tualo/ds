<?php

namespace Tualo\Office\DS\Commandline;

use Garden\Cli\Cli;
use Garden\Cli\Args;
use phpseclib3\Math\BigInteger\Engines\PHP;
use Tualo\Office\Basic\ISetupCommandline;
use Tualo\Office\ExtJSCompiler\Helper;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\PostCheck;
use Tualo\Office\Basic\CommandLineInstallSessionSQL;
use Tualo\Office\Basic\BaseSetupCommand as BaseSetup;

class Setup extends BaseSetup
{

    public static function getHeadLine(): string
    {
        return 'DS Setup Command';
    }
    public static function getCommands(Args $args): array
    {
        $parentCommands = parent::getCommands($args);
        return [
            ...$parentCommands,

            'install-sql-ds',
            'install-sql-ds-dsx',
            'install-sql-ds-privacy',
            'install-sql-ds-docsystem',
        ];
    }

    public static function getCommandName(): string
    {
        return 'ds';
    }
    public static function getCommandDescription(): string
    {
        return 'perform a complete ds setup';
    }
    public static function setup(Cli $cli)
    {
        $cli->command(self::getCommandName())
            ->description(self::getCommandDescription())
            ->opt('client', 'only use this client', true, 'string')
            ->opt('user', 'only use this user', true, 'string');
    }
}
