<?php

namespace Tualo\Office\DS\Routes\DS;

use Exception;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSTable;
use Tualo\Office\DS\ErrorLogger;
use Tualo\Office\DS\Routes\DSBase;
use Tualo\Office\DS\Routes\DefaultExpectedFields;
use Tualo\Office\DS\Scopes\DSReadScope;
use Tualo\Office\DSX\Read\StreamResponse;

class Cached extends DSBase
{
    public static function scope(): string
    {
        return DSReadScope::identifier();
    }

    public static function register()
    {

        Route::add('/.ds/cached', function () {
            $db = App::get('session')->getDB();
            $tables = []; //['zahlungsarten', 'zahlungsschluessel', 'rechnungsweg', 'kundenbetreuer', 'tualo_holding', 'mengeneinheiten', 'adressen_status', 'adressen_kundenklasse'];
            $result = [];
            foreach ($tables as $table) {
                $result[$table] = [
                    'checksum'  => $db->singleValue('checksum table `' . $table . '`', [], 'checksum'),
                    'data'      => DSTable::instance($table)->limit(1000000)->g()
                ];
            }
            $script = "Ext.define('Tualo.ds.Cached', { singleton: true, cached: " . json_encode($result) . "})";
            App::body($script);
            App::contenttype('application/javascript');
        }, ['get'], true, [], self::scope());
    }
}
