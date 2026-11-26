<?php

namespace Tualo\Office\DS;

use Tualo\Office\Basic\MYSQL\Database;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\DSX\Read\RestApiGet;

class DSXRead
{
    public static function read(mixed $db, array $request, bool &$readLogged): array
    {
        if (!class_exists(RestApiGet::class)) {
            throw new \RuntimeException(RestApiGet::class . ' ist nicht verfuegbar; tualo/dsx installieren und den Composer-Autoloader aktualisieren.');
        }
        if (!$db instanceof Database) {
            throw new \TypeError('Eine gueltige Datenbankverbindung ist erforderlich.');
        }
        $db->tinyIntAsBoolean(true);
        TualoApplication::deferredTrigger();
        if ($db->direct('SET SESSION group_concat_max_len = 173741820') !== true) {
            throw new \RuntimeException('group_concat_max_len konnte nicht gesetzt werden.');
        }
        $reader = new RestApiGet($db);
        $readLogged = class_exists(\Tualo\Office\DSX\ErrorLogger::class);
        return $reader->execute($request);
    }
}
