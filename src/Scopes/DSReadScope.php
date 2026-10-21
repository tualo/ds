<?php

namespace Tualo\Office\DS\Scopes;

use Tualo\Office\Basic\Scope;

class DSReadScope extends Scope
{
    protected static string $identifier = 'ds.read';
    protected static array $name = [
        'EN' => 'DS Read',
        'DE' => 'DS Lesen',
    ];
    protected static array $description = [
        'EN' => 'Access and manage DS read operations.',
        'DE' => 'Auf DS-Leseoperationen zugreifen und sie verwalten.',
    ];
}
