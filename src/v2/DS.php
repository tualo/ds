<?php

namespace Tualo\Office\DS\v2;

use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\Basic\MYSQL\Database_mysql;

class DS
{
    private Database_mysql $db;
    private string $tablename;
    private DSDefinition $definition;

    function __construct(Database_mysql $db, $tablename)
    {
        $this->db = $db;
        $this->tablename = $tablename;
        $this->init();
    }

    function init()
    {
        return $this->definition = (new DSDefinition($this->db, $this->tablename))->query();
    }


    public function t(string $tablename): DS
    {
        return $this->table($tablename);
    }
    public function table(string $tablename): DS
    {
        $this->tablename = $tablename;
        return $this;
    }

    public function create(mixed $data): mixed
    {
        return $this;
    }

    public function read(mixed $id = null): mixed
    {

        return $this;
    }

    public function createReadSQL(): string
    {
        $sql = 'select 1';





        return $sql;
    }
}
