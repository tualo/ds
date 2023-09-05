<?php
namespace Tualo\Office\DS;
use Tualo\Office\Basic\TualoApplication;

class DSFile {
    private mixed $db;
    private string $tablename;
    public static function instance(string $tablename='test'):DSFile{
        return new DSFile( TualoApplication::get('session')->getDB(),$tablename);
    }
    function __construct(mixed $db,string $tablename){
        $this->db=$db;
        $this->tablename=$tablename;
    }
    public function getBase64(string $fieldName,$fieldValue){
        $table = DSTable::instance($this->tablename)
                    ->filter($fieldName,'=',$fieldValue)
                    ->limit(1)
                    ->read();
        if ($table->empty()) return '';
        $data = $table->getSingle();
        $sql = "select data from `" . $this->tablename . "_docdata` where `doc_id`=" . (isset($data[$fieldName])?$data[$fieldName]:-1) . " order by page";
        return $this->db->singleValue($sql,[],'data');
    }

    
}