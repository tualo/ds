<?php

namespace Tualo\Office\DS\Routes;

use Exception;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSFileHelper;



class RegisterClient extends \Tualo\Office\Basic\RouteWrapper
{

    public static function scope(): string
    {
        return 'ds.registerclient';
    }

    public static function register()
    {
        Route::add('/ds/registerclient', function ($matches) {



            $session = App::getSession();


            try {

                if (!isset($_REQUEST['path'])) throw new Exception('path not set');
                $token = $session->registerOAuth($params = ['cmp' => 'cmp_ds'], $force = true, $anyclient = false, $path = $_REQUEST['path']);
                $session->oauthValidDays($token, 7);

                App::result('token', $token);
                App::result('success', true);
            } catch (Exception $e) {
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        }, ['get', 'post'], true, [], self::scope());
    }
};
