<?php

namespace Tualo\Office\DS\Scopes;

use Tualo\Office\Basic\Scope;

class DSProceduresScope extends Scope
{
    protected static string $identifier = 'ds.procedures';
    protected static array $name = [
        'EN' => 'DS Procedures',
        'DE' => 'DS Prozeduren',
    ];
    protected static array $description = [
        'EN' => 'Access and manage DS procedures.',
        'DE' => 'Auf DS-Prozeduren zugreifen und sie verwalten.',
    ];
}
