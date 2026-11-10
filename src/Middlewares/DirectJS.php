<?php

namespace Tualo\Office\DS\Middlewares;

use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\Basic\IMiddleware;

/**
 * Bindet den Ext.Direct-API-Deskriptor nur ein, wenn das optionale
 * DS-Direct-Batching per Konfiguration ([ds] direct = 1) aktiviert ist.
 * Ohne das Script bleibt der Proxy-Override inaktiv und alle Stores
 * verhalten sich wie bisher.
 */
class DirectJS implements IMiddleware
{
    public static function register()
    {
        TualoApplication::use('ds_direct', function () {
            try {
                if (TualoApplication::configuration('ds', 'direct', '0') == '1') {
                    TualoApplication::javascript('ds_direct_api', './.ds/direct/api.js', [], 500);
                }
            } catch (\Exception $e) {
                TualoApplication::logger('ds')->error($e->getMessage(), []);
            }
        }, -100, [
            'needActiveSession' => true,
        ]);
    }
}
