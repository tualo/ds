<?php
namespace Tualo\Office\DS;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\DS\DataRenderer;

class DSTable {
    private mixed $db;
    private string $tablename;
    private int $limit=100000;
    private int $start=0;
    private array $filter=[];
    private array $sorter=[];
    private bool $isQueried = false;
    private bool $isEmpty = true;
    private bool $hasError = false;
    private string $errorMessage = "";
    

    function __construct(mixed $db,string $tablename){
        $this->db=$db;
        $this->tablename=$tablename;
    }

    public function filter(string $field,string $operator,mixed $value):DSTable{

        $this->filter[] = [
            'property' => /*$this->tablename.'__'.*/$field,
            'operator' => $operator,
            'value'    =>  $value
        ];
        return $this;
    }

    public function sort(string $field,string $direction):DSTable{

        $this->sorter[] = [
            'property' => /*$this->tablename.'__'.*/$field,
            'direction' => $direction
        ];
        return $this;
    }

    public function start(int $start):DSTable{
        $this->start = $start;
        return $this;
    }

    public function limit(int $limit):DSTable{
        $this->limit = $limit;
        return $this;
    }

    public function empty():bool { return $this->isEmpty; }
    public function queried():bool { return $this->isQueried; }
    public function error():bool { return $this->hasError; }
    public function errorMessage():string { return $this->errorMessage; }

    public function get():array{
        $request = array(
            'start' => $this->start,
            'shortfieldnames'=>1,
            'limit' => $this->limit,
            'filter' => $this->filter,
            'sort' => $this->sorter
        );
        try{
        $read = DSReadRoute::read($this->db,$this->tablename,$request);
        $this->isQueried=true;
        /*
        if ($read===false){
            $this->hasError=true;
            return [];
        }else{
            */
            if (count($read['data'])==0){ $this->isEmpty=true; }else{ $this->isEmpty=false; }
            return $read['data'];
        //}
        }catch(\Exception $e){
            $this->hasError=true;
            $this->errorMessage=$e->getMessage();
        }
        return [];
    }
}