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
    private array $_warnings = [];
    private array $_moreResults = [];
    
    

    function __construct(mixed $db,string $tablename){
        $this->db=$db;
        $this->tablename=$tablename;
    }

    public function f(string $field,string $operator,mixed $value):DSTable{ 
        return $this->filter($field,$operator,$value);
    }

    public function filter(string $field,string $operator,mixed $value):DSTable{

        $this->filter[] = [
            'property' => /*$this->tablename.'__'.*/$field,
            'operator' => $operator,
            'value'    =>  $value
        ];
        return $this;
    }

    public function s(string $field,string $direction):DSTable{ 
        return $this->s($field,$direction);
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
    public function warnings():array { return $this->_warnings; }
    public function moreResults():array { return $this->_moreResults; }
    

    public function g():array{
        return $this->get();
    }


    public function prepareRecord(array $record):array{
        $rec = [];
        foreach($record as $key=>$value){
            if (
                ( strpos($key,'__') === false ) ||
                ( strpos($key,$this->tablename.'__') === false )
            ){
                $rec[$this->tablename.'__'.$key]=$value;
            }else{
                $rec[$key]=$value;
            }
        }
        return $rec;
    }


    public function delete(mixed $record):mixed{
        try{
            $record=$this->prepareRecord($record);
            $input = $record; 
            if (isset( $input['__id'] )){ 
                $input = [$input];
            }
            $this->db->direct('set @request = {d}',
            [
                'd'=>json_encode([
                    'tablename'=>$this->tablename,
                    'type'=>'delete',
                    'data'=>$input
                ])
            ]
            );
            echo (json_encode([
                'tablename'=>$this->tablename,
                'type'=>'delete',
                'data'=>$input
            ]));
            $this->db->direct('call dsx_rest_api_set(@request,@result)');
            $this->_warnings = $this->db->getWarnings();
            $mr = $this->db->moreResults();
            if (!is_null($mr)){
                $this->_moreResults = $mr;
            }
            return json_decode($this->db->singleValue('select @result s',[],'s'),true);
        }catch(\Exception $e){
            $this->hasError=true;
            $this->errorMessage=$e->getMessage();
        }
        return false;
    }


    public function update(mixed $record):mixed{
        try{
            $record=$this->prepareRecord($record);
            $input = $record; 
            if (isset( $input['__id'] )){ 
                $input = [$input];
            }
            $this->db->direct('set @request = {d}',
            [
                'd'=>json_encode([
                    'tablename'=>$this->tablename,
                    'type'=>'update',
                    'data'=>$input
                ])
            ]
            );
            $this->db->direct('call dsx_rest_api_set(@request,@result)');
            $this->_warnings = $this->db->getWarnings();
            $mr = $this->db->moreResults();
            if (!is_null($mr)){
                $this->_moreResults = $mr;
            }
            return json_decode($this->db->singleValue('select @result s',[],'s'),true);
        }catch(\Exception $e){
            $this->hasError=true;
            $this->errorMessage=$e->getMessage();
        }
        return false;
    }

    public function insert(mixed $record):mixed{
        try{
            $record=$this->prepareRecord($record);
            $input = $record; 
            if (isset( $input['__id'] )){ 
                echo 123; exit();
                $input = [$input];
            }

            $this->db->direct('set @request = {d}',
            [
                'd'=>json_encode([
                    'tablename'=>$this->tablename,
                    'type'=>'insert',
                    'update'=>true,
                    'data'=>$input
                ])
            ]
            );
            $this->db->direct('call dsx_rest_api_set(@request,@result)');
            $this->_warnings = $this->db->getWarnings();
            $mr = $this->db->moreResults();
            if (!is_null($mr)){
                $this->_moreResults = $mr;
            }
            return json_decode($this->db->singleValue('select @result s',[],'s'),true);
        }catch(\Exception $e){
            $this->hasError=true;
            $this->errorMessage=$e->getMessage();
        }
        return false;
    }
        


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