<?php

namespace Tualo\Office\DS\Routes;

class DefaultExpectedFields extends \Tualo\Office\Basic\RouteWrapper
{
    public static array $Fields  = [
        'page' => [
            'required' => false,
            'type' => 'int',
            'min' => 0,
            'max' => 10000000
        ],
        'start' => [
            'required' => false,
            'type' => 'int',
            'min' => 0,
            'max' => 10000000
        ],

        'limit' => [
            'required' => false,
            'type' => 'int',
            'min' => 0,
            'max' => 10000000
        ],
        'sort' => [
            'required' => false,
            'type' => 'array|string',
        ],
        'filter' => [
            'required' => false,
            'type' => 'array|string',
        ],

        'filter_by_search' => [
            'required' => false,
            'type' => 'int',
            'min' => 0,
            'max' => 2
        ],

        'search' => [
            'required' => false,
            'type' => 'string',
            'minlength' => 0,
            'maxlength' => 1000
        ],
        'fulltext' => [
            'required' => false,
            'type' => 'int',
            'min' => 0,
            'max' => 2
        ],
        'concat_set_table' => [
            'required' => false,
            'type' => 'int',
            'min' => 0,
            'max' => 1
        ],
        'tablename' => [
            'required' => false,
            'type' => 'string',
            'minlength' => 1,
            'maxlength' => 128,
            'pattern' => '/^[a-zA-Z0-9_]+$/'
        ],
        'query' => [
            'required' => false,
            'type' => 'string',
            'minlength' => 0,
            'maxlength' => 10000
        ],
        'reference' => [
            'required' => false,
            'type' => 'string',
            'minlength' => 0,
            'maxlength' => 10000
        ],
        '_dc' => [
            'required' => false,
            'type' => 'string',
            'minlength' => 0,
            'maxlength' => 10000
        ],
    ];
}
