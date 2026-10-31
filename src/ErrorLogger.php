<?php

namespace Tualo\Office\DS;

use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\DSX\ErrorLogger as DSXErrorLogger;

class ErrorLogger
{
    public static function log(mixed $db, string $operation, string $tablename, \Throwable $error): void
    {
        if (class_exists(DSXErrorLogger::class)) {
            DSXErrorLogger::log($db, $operation, $tablename, $error);
            return;
        }

        $dependencyError = DSXErrorLogger::class
            . ' ist nicht verfuegbar; tualo/dsx ab Version 1.0.5 installieren und die Composer-Abhaengigkeiten aktualisieren.';
        try {
            TualoApplication::logger('dstable')->error($error->getMessage(), [
                'operation' => $operation,
                'tablename' => $tablename,
                'code' => $error->getCode(),
                'configured_schema' => $db->dbname ?? null,
                'dependency_error' => $dependencyError,
            ]);
        } catch (\Throwable $loggingError) {
            error_log('dstable logging failed: ' . $loggingError->getMessage()
                . '; ' . $operation . ' on ' . $tablename . ': ' . $error->getMessage()
                . '; ' . $dependencyError);
        }
    }
}
