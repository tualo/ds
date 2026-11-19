<?php

namespace Tualo\Office\DS\Routes;

use Exception;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSTable;


class DSBase extends \Tualo\Office\Basic\RouteWrapper
{
    public static function sanitizeInput($input)
    {
        return preg_replace('/[\'";#]/', '', $input);
    }

    public static function setRequestParameter()
    {
        $db = App::get('session')->getDB();
        if (isset($_REQUEST['query_parameter'])) {
            $json = json_decode($_REQUEST['query_parameter'], true);
            if (!is_null($json)) {
                $db->execute('set @request_parameter={request_parameter}', [
                    'request_parameter' => json_encode($json)
                ]);
            }
        }
    }

    /**
     * Enforces table-level sub-scopes: a session scoped to e.g. "ds.read:ds"
     * may only access the table "ds". Sessions whose scope has no sub-scopes
     * (plain "ds.read") remain unrestricted.
     *
     * @throws Exception with code 15403 when the table is not covered
     */
    public static function assertTableScope(string $scope, string $tablename): void
    {
        $subScopes = Route::getUserSubScopes($scope);
        if ($subScopes !== [] && !in_array($tablename, $subScopes, true)) {
            throw new Exception(
                'Access to table "' . $tablename . '" is not covered by scope "' . $scope . '"',
                15403
            );
        }
    }
}
