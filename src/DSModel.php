<?php
namespace Tualo\Office\DS;

class DSModel{


    private $tablename;
    private $data = array();

    public static function fromArray($tablename,$data){
        $o = new DSModel($tablename);
        $o->setData($data);
        return $o;
    }

    function __construct($tablename) {
        $this->tablename = $tablename;
        $this->data = array();
    }

    public function setData($dataArray){
        foreach($dataArray as $key=>$value) $this->set($key,$value);
        return $this;
    }
    

    protected function getUseKey($key){
        $isLongKey = strpos($key,$this->tablename.'__')===0;
        $useKey = $this->tablename.'__'.$key;
        if ($isLongKey) $useKey = $key;
        return $useKey;
    }

    public function get($key,$defaultValue=NULL){
        $useKey = $this->getUseKey($key);
        if(isset($this->data[$useKey])){
            return $this->data[$useKey];
        }
        return $defaultValue;
    }

    public function set($key,$value=NULL){
        $useKey = $this->getUseKey($key);
        $this->data[$useKey]=$value;
        return $this;
    }

    public function toArray(){
        return $this->data;
    }

    public function toJSON($options=0,$depth=512){
        return json_encode($this->data,$options,$depth);
    }

    public function toString( ){
        return $this->toJSON();
    }


}
