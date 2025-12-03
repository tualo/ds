<?php

namespace Tualo\Office\DS;

use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\DS\DataRenderer;


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




    private function requestData(array $input, array $merge): string
    {


        $data = json_encode(array_merge([
            'tablename' => $this->tablename,
            'data' => $input
        ], $merge), JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);


        // return  str_replace(chr(92) . chr(92), chr(92), $data);
        return  $data;
    }

    private function dsx_rest_api_set(): mixed
    {

        $this->db->direct('call dsx_rest_api_set(@request,@result)');
        $this->readWarnings();
        $this->readMoreResults();
        $res = $this->db->singleValue('select @result s', [], 's');
        TualoApplication::deferredTrigger();
        if ($res === false) return false;
        return json_decode($res, true);
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
        try {
            $input = $this->prepareRecords($record);
            $this->db->direct('set @request = {d}', [
                'd' => $this->requestData(
                    $input,
                    array_merge(['type' => 'delete'], $options)
                )
            ]);
            return $this->dsx_rest_api_set();
        } catch (\Exception $e) {
            $this->hasError = true;
            $this->errorMessage = $e->getMessage();
        }
        return false;
    }



    public function update(mixed $record = [], mixed $options = []): mixed
    {
        try {


            $input = $this->prepareRecords($record);
            $this->db->direct('set @request = {d}', [
                'd' => $this->requestData(
                    $input,
                    array_merge(['type' => 'update'], $options)
                )
            ]);

            TualoApplication::result('r', $record);
            TualoApplication::result('i', $input);

            TualoApplication::result('o', json_decode($this->requestData(
                $input,
                array_merge(['type' => 'update'], $options)
            ), true));

            return $this->dsx_rest_api_set();
        } catch (\Exception $e) {
            $this->hasError = true;
            $this->errorMessage = $e->getMessage();
        }
        return false;
    }

    public function insert(mixed $record = [], mixed $options = []): mixed
    {
        try {
            $input = $this->prepareRecords($record);
            $this->db->direct('set @request = {d}', [
                'd' => $this->requestData(
                    $input,
                    array_merge(['type' => 'insert', 'update' => true], $options)
                )
            ]);


            //$this->db->direct('set @request = {d}', [ 'd'=> $this->requestData($input,['type'=>'insert','update'=>true]) ]);
            return $this->dsx_rest_api_set();
        } catch (\Exception $e) {
            $this->hasError = true;
            $this->errorMessage = $e->getMessage();
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
            $this->hasError = true;
            $this->errorMessage = $e->getMessage();
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
