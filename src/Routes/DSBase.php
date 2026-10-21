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
}
