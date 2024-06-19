<?php
namespace Tualo\Office\DS;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\DS\DataRenderer;


class Procedure {
    private mixed $db;
    private string $procedureName;
    private array $parameters=[];
    /*
    private int $limit=100000;
    private int $start=0;
    private array $filter=[];
    private array $sorter=[];
    private array $data=[];
    private bool $isQueried = false;
    private bool $isEmpty = true;
    */
    private bool $hasError = false;
    private string $errorMessage = "";
    private array $_warnings = [];
    private array $_moreResults = [];
    
    public static function instance(string $procedureName='test'):Procedure{
        return new Procedure( TualoApplication::get('session')->getDB(),$procedureName);
    }

    public static function init(mixed $db):Procedure{
        return new Procedure($db,'test');
    }
    

    function __construct(mixed $db,string $procedureName){
        $this->db=$db;
        $this->procedureName=$procedureName;
    }

    public function p(string $procedureName):Procedure{ 
        $this->procedureName=$procedureName;
        return  $this;
    }

    public function a( mixed $value ):Procedure{ 
        return $this->addParameter( $value );
    }

    public function addParameter(mixed $value):Procedure{
        $this->parameters[] =  $value;
        return $this;
    }

    


    public function error():bool { return $this->hasError; }
    public function errorMessage():string { return $this->errorMessage; }
    public function warnings():array { return $this->_warnings; }
    public function moreResults():array { return $this->_moreResults; }
    

    public function g():array{
        return $this->get();
    }


    private function call():Procedure{
        // $this->db->direct('set @log_dsx_commands=1',[],'r');
        // echo $this->db->singleValue('select @request r',[],'r').PHP_EOL;
        $pks = [];
        $pkv = [];
        foreach($this->parameters as $i=>$p){
            $pks[] = '{p_'.$i.'}';
            $pkv['p_'.$i] = $p;
        }
        $this->db->direct('call `',$this->procedureName,'`(',implode(',',$pks),')',$pkv,'');
        $this->readWarnings();
        $this->readMoreResults();
        return $this;
    }

    public function readWarnings():mixed{
        $this->_warnings = array_merge($this->_warnings,$this->db->getWarnings());
        return $this->_warnings;
    }
    public function readMoreResults():mixed{
        $mr = $this->db->moreResults();
        if (!is_null($mr)){
            $this->_moreResults = array_merge($this->_moreResults,$mr);
        }
        return $this->_moreResults;
    }
    

}