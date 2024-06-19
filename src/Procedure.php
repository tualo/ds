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

    public function a( mixed $value ,string $type='string'):Procedure{ 
        return $this->addParameter( $value,$type );
    }

    public function addParameter(mixed $value,string $type='string'):Procedure{
        $this->parameters[] =  [$value,$type];
        return $this;
    }

    


    public function error():bool { return $this->hasError; }
    public function errorMessage():string { return $this->errorMessage; }
    public function warnings():array { return $this->_warnings; }
    public function moreResults():array { return $this->_moreResults; }
    

    public function g():array{
        return $this->get();
    }


    public function call():Procedure{
        // $this->db->direct('set @log_dsx_commands=1',[],'r');
        // echo $this->db->singleValue('select @request r',[],'r').PHP_EOL;
        $pks = [];
        $pkv = [];
        foreach($this->parameters as $i=>$p){

            $pks[] = '{p_'.$i.'}';
            if ($p[1]=='string'){ 
                $pkv[] = '\''.$this->db->escape_string($p[0]).'\''; 
            }else if (is_null($p[0])){ 
                $pkv[] = 'null';
            }else{
                $pkv[] = $p[0];
            }
        }
        try{
        $this->db->direct('call `'.$this->procedureName.'`('.implode(',',$pkv).')');
        $this->readWarnings();
        $this->readMoreResults();
        }catch(\Exception $e){
            $this->hasError = true;
            $this->errorMessage = $e->getMessage();
        }
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