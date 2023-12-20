<?php
namespace Tualo\Office\DS;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\DS\DataRenderer;
use Tualo\Office\DS\DSTable;

class DS {
    private mixed $db = "";
    function __construct(mixed $db){
        $this->db=$db;
    }
    public function table($tablename):DSTable{
        return new DSTable($this->db,$tablename);
    }
    public function t($tablename):DSTable{
        return $this->table($tablename);
    }
}


