<?php

namespace Tualo\Office\DS\Scopes;

use Tualo\Office\Basic\Scope;

class DSWriteScope extends Scope
{
    protected static string $identifier = 'ds.write';
    protected static array $name = [
        'EN' => 'DS Write',
        'DE' => 'DS Schreiben',
    ];
    protected static array $description = [
        'EN' => 'Access and manage DS write operations.',
        'DE' => 'Auf DS-Schreiboperationen zugreifen und sie verwalten.',
    ];
}
