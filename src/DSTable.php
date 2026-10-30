<?php

namespace Tualo\Office\DS;

use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\DS\DataRenderer;
use Tualo\Office\DSX\Write\RestApiSet;


class DSTable
{
    private mixed $db;
    private string $tablename;
    private int $limit = 100000;
    private int $start = 0;
    private array $filter = [];
    private array $sorter = [];
    private array $data = [];
    private bool $isQueried = false;
    private bool $isEmpty = true;
    private bool $hasError = false;
    private string $errorMessage = "";
    private array $_warnings = [];
    private array $_moreResults = [];

    public static function instance(string $tablename = 'test'): DSTable
    {
        return new DSTable(TualoApplication::get('session')->getDB(), $tablename);
    }

    public static function init(mixed $db): DSTable
    {
        return new DSTable($db, 'test');
    }


    function __construct(mixed $db, string $tablename)
    {
        $this->db = $db;
        $this->tablename = $tablename;
    }

    public function t(string $tablename): DSTable
    {
        $this->tablename = $tablename;
        return  $this;
    }

    public function f(string $field, string $operator, mixed $value): DSTable
    {
        return $this->filter($field, $operator, $value);
    }

    public function filter(string $field, string $operator, mixed $value): DSTable
    {

        $this->filter[] = [
            'property' => /*$this->tablename.'__'.*/ $field,
            'operator' => $operator,
            'value'    =>  $value
        ];
        return $this;
    }

    public function s(string $field, string $direction): DSTable
    {
        return $this->sort($field, $direction);
    }

    public function sort(string $field, string $direction): DSTable
    {

        $this->sorter[] = [
            'property' => /*$this->tablename.'__'.*/ $field,
            'direction' => $direction
        ];
        return $this;
    }

    public function start(int $start): DSTable
    {
        $this->start = $start;
        return $this;
    }

    public function limit(int $limit): DSTable
    {
        $this->limit = $limit;
        return $this;
    }

    public function empty(): bool
    {
        return $this->isEmpty;
    }
    public function queried(): bool
    {
        return $this->isQueried;
    }
    public function error(): bool
    {
        return $this->hasError;
    }
    public function errorMessage(): string
    {
        return $this->errorMessage;
    }

    private function logError(string $operation, \Exception $error): void
    {
        $this->hasError = true;
        $this->errorMessage = $error->getMessage();

        $context = [
            'operation' => $operation,
            'tablename' => $this->tablename,
            'configured_schema' => $this->db->dbname ?? null,
            'galera_hostname' => $this->db->singleValue('SELECT @@hostname v', [], 'v'),
            'exceptions' => [],
        ];
        for ($exception = $error; $exception !== null; $exception = $exception->getPrevious()) {
            $details = [
                'class' => get_class($exception),
                'code' => $exception->getCode(),
                'message' => $exception->getMessage(),
            ];
            if ($exception instanceof \mysqli_sql_exception) {
                $details['sqlstate'] = $exception->getSqlState();
            }
            $context['exceptions'][] = $details;
        }

        if (
            isset($this->db->lastSQL) &&
            preg_match('/^\s*(CALL\s+`?[a-zA-Z0-9_]+`?|[a-zA-Z]+)/i', $this->db->lastSQL, $matches)
        ) {
            $context['last_statement_prefix'] = $matches[1];
        }

        if (isset($this->db->mysqli) && $this->db->mysqli instanceof \mysqli) {
            try {
                $context['mysqli_errno'] = $this->db->mysqli->errno;
                $context['mysqli_sqlstate'] = $this->db->mysqli->sqlstate;
                $context['connection_id'] = $this->db->mysqli->thread_id;
                $context['connection_host_info'] = $this->db->mysqli->host_info;
            } catch (\Error $diagnosticError) {
                // A closed connection must not hide the original database error.
                $context['connection_diagnostic_error'] = $diagnosticError->getMessage();
            }
        }

        TualoApplication::logger('dstable')->error($error->getMessage(), $context);
    }

    public function warnings(): array
    {
        return $this->_warnings;
    }
    public function moreResults(): array
    {
        return $this->_moreResults;
    }



    public function appendFileFromUploadForm(array $record, string $attribute): array
    {
        $record = array_merge($record, DSFiles::fromUploadForm($attribute));
        return $record;
    }


    public function differentRows(array $records)
    {
        $keymap = [];
        if (count($records) == 0) return false;
        foreach ($records as $record) {
            foreach ($record as $key => $value) {
                $keymap[$key] = true;
            }
        }
        foreach ($records as $index => $record) {
            foreach ($keymap as $key => $value) {
                if (!isset($records[$index][$key])) {
                    return true;
                }
            }
        }
        return false;
    }

    public function prepareRecords(array $records): array
    {

        if ($records !== array_values($records)) {
            $records = [$records];
        }

        if ($this->differentRows($records)) {
            // throw new \Exception('Different keys in rows');
        }
        return $records;
    }




    public function readWarnings(): mixed
    {
        $this->_warnings = array_merge($this->_warnings, $this->db->getWarnings());
        return $this->_warnings;
    }
    public function readMoreResults(): mixed
    {
        $mr = $this->db->moreResults();
        if (!is_null($mr)) {
            $this->_moreResults = array_merge($this->_moreResults, $mr);
        }
        return $this->_moreResults;
    }


    public function delete(mixed $record = [], mixed $options = []): mixed
    {
        return $this->write('delete', $record, $options);
    }



    public function update(mixed $record = [], mixed $options = []): mixed
    {
        return $this->write('update', $record, $options);
    }

    public function insert(mixed $record = [], mixed $options = []): mixed
    {
        return $this->write('insert', $record, array_merge(['update' => true], is_array($options) ? $options : []));
    }

    private function write(string $type, mixed $record, mixed $options): mixed
    {
        try {
            if (!class_exists(RestApiSet::class)) {
                throw new \RuntimeException(
                    RestApiSet::class . ' ist nicht verfuegbar; tualo/dsx ab Version 1.0.3 installieren und den Composer-Autoloader aktualisieren.'
                );
            }
            $input = $this->prepareRecords($record);
            $request = array_merge(is_array($options) ? $options : [], [
                'tablename' => $this->tablename,
                'type' => $type,
                'data' => $input,
            ]);
            $result = RestApiSet::write($this->db, $request);
            $this->readWarnings();
            TualoApplication::deferredTrigger();
            return $result;
        } catch (\Exception $e) {
            $this->logError($type, $e);
        }
        return false;
    }



    public function r(): DSTable
    {
        return $this->read();
    }

    public function read(): DSTable
    {
        $request = array(
            'start' => $this->start,
            'shortfieldnames' => 1,
            'limit' => $this->limit,
            'filter' => $this->filter,
            'sort' => $this->sorter
        );
        try {
            $read = DSReadRoute::read($this->db, $this->tablename, $request);
            $this->isQueried = true;
            if (count($read['data']) == 0) {
                $this->isEmpty = true;
            } else {
                $this->isEmpty = false;
            }
            $this->data = $read['data'];
        } catch (\Exception $e) {
            $this->logError('read', $e);
        }
        return $this;
    }


    public function g(string $hashKey = '', string $valueKey = ''): array
    {
        return $this->get($hashKey, $valueKey);
    }
    public function get(string $hashKey = '', string $valueKey = ''): array
    {
        $this->read();
        if ($hashKey !== '') {
            $hash = [];
            foreach ($this->data as $record) {

                if ($valueKey !== '' && isset($record[$valueKey])) {
                    $hash[$record[$hashKey]] = $record[$valueKey];
                } else {
                    $hash[$record[$hashKey]] = $record;
                }
            }
            return $hash;
        }
        return $this->data;
    }

    public function getSingle(): array
    {
        if (!$this->isQueried) {
            $this->read();
        }

        if (count($this->data) > 0) {
            return $this->data[0];
        }
        return [];
    }

    public function getSingleValue(string $column): mixed
    {
        if (!$this->isQueried) {
            $this->read();
        }

        if (($elem = $this->getSingle()) &&  isset($elem[$column])) {
            return $elem[$column];
        }
        return false;
    }
}
