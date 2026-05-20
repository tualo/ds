<?php

namespace Tualo\Office\DS\v2;

use Tualo\Office\Basic\MYSQL\Database_mysql;

class DSDefinition
{
    private Database_mysql $db;
    private array $columnDefinitions;
    private string $tablename;
    private string $title;
    private string $displayfield;
    private string $searchfield;
    private string $sortfield;
    private string $writetable;
    private string $read_table;
    private string $sortdirection;


    private bool $searchany;
    private bool $globalsearch;
    private bool $use_insert_for_update;


    private string $returnFields = '*';


    function __construct(Database_mysql $db, string $tablename)
    {
        $this->db = $db;
        $this->tablename = $tablename;
        $this->query();
        $this->queryColumns();
    }

    function query(): DSDefinition
    {
        $data = $this->db->singleRow(
            '
                select
                    title,
                    displayfield,
                    searchfield,
                    sortfield,
                    searchany,
                    writetable,
                    read_table,
                    globalsearch,
                    use_insert_for_update,
                    sortdirection
                from ds
                where table_name = {tablename}
                    
            ',
            [
                'tablename' => $this->tablename
            ]
        );
        $this->fromTableDefinition($data);
        return $this;
    }

    function fromTableDefinition(array $data): DSDefinition
    {
        $this->title = $data['title'];
        $this->displayfield = $data['displayfield'];
        $this->searchfield = $data['searchfield'];
        $this->sortfield = $data['sortfield'];
        $this->searchany = $data['searchany'];
        $this->writetable = $data['writetable'];
        $this->read_table = $data['read_table'];
        $this->globalsearch = $data['globalsearch'];
        $this->use_insert_for_update = $data['use_insert_for_update'];
        $this->sortdirection = $data['sortdirection'];
        return $this;
    }

    function queryColumns()
    {
        $this->columnDefinitions = DSColumnDefinition::queryStatic($this->db, $this->tablename);
    }

    function getTitle(): string
    {
        return $this->title;
    }

    function getDisplayfield(): string
    {
        return $this->displayfield;
    }

    function getSearchfield(): string
    {
        return $this->searchfield;
    }

    function getSortfield(): string
    {
        return $this->sortfield;
    }

    function getSearchany(): bool
    {
        return $this->searchany;
    }

    function getWritetable(): string
    {
        return $this->writetable;
    }

    function getReadTable(): string
    {

        return $this->read_table;
    }

    function getGlobalsearch(): bool
    {
        return $this->globalsearch;
    }

    function getUseInsertForUpdate(): bool
    {
        return $this->use_insert_for_update;
    }

    function getSortdirection(): string
    {
        return $this->sortdirection;
    }
}
