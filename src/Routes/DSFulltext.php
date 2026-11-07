<?php

namespace Tualo\Office\DS\Routes;

use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route;
use Tualo\Office\DS\ErrorLogger;
use Tualo\Office\DS\Scopes\DSProceduresScope;

class DSFulltext extends \Tualo\Office\Basic\RouteWrapper
{
    public static function scope(): string
    {
        return DSProceduresScope::identifier();
    }

    public static function register()
    {
        Route::add('/dsft/run', function ($matches) {
            $db = App::get('session')->getDB();
            $tableName = '';
            App::result('success', false);
            try {
                if (!App::get('session')->isMaster()) {
                    http_response_code(403);
                    throw new \Exception('Keine Berechtigung zum Aufbau der Volltextsuche.');
                }
                $tableName = $_POST['table_name'] ?? '';
                $stage = $_POST['stage'] ?? '';
                if (
                    !is_string($tableName) || !preg_match('/^[a-zA-Z0-9_]+$/D', $tableName)
                    || strlen('refresh_searchft_' . $tableName) > 64
                ) {
                    throw new \Exception('Ungültiger Tabellenname.');
                }
                if (!in_array($stage, ['build', 'refresh'], true)) {
                    throw new \Exception('Ungültiger Schritt für den Aufbau der Volltextsuche.');
                }
                if (!$db->singleRow('select table_name from ds where table_name={table_name}', ['table_name' => $tableName])) {
                    throw new \Exception('Die Tabelle ist nicht im Datenstamm vorhanden.');
                }
                if (!$db->singleRow(
                    'select column_name from ds_searchfields where table_name={table_name} and active=1 limit 1',
                    ['table_name' => $tableName]
                )) {
                    throw new \Exception('Bitte zuerst durchsuchbare Felder im Datenstamm festlegen.');
                }
                set_time_limit(600);
                if ($stage === 'build') {
                    $db->direct('call ds_create_fulltext_search({table_name})', ['table_name' => $tableName]);
                } else {
                    $db->direct('call `refresh_searchft_' . $tableName . '`()');
                }
                $db->moreResults();
                App::result('warnings', $db->getWarnings());
                App::result('success', true);
                App::result('msg', $stage === 'build' ? 'Suchstruktur erstellt.' : 'Bestandsdaten indexiert.');
            } catch (\Throwable $e) {
                ErrorLogger::log($db, 'fulltext', is_string($tableName) ? $tableName : '', $e);
                App::result('msg', $e->getMessage());
            }
            App::contenttype('application/json');
        }, ['post'], true, [], self::scope());
    }
}
