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
    public function getBase64(string $fieldName,string $fieldValue,string $docfieldName=''):string{
        $table = DSTable::instance($this->tablename)
                    ->filter($fieldName,'=',$fieldValue)
                    ->limit(1)
                    ->read();
        if ($docfieldName=='') $docfieldName = $fieldName;
        if ($table->empty()) return '';
        $data = $table->getSingle();
        $sql_mime = "select mime from `" . $this->tablename . "_doc` where `doc_id`=" . (isset($data[$docfieldName])?$data[$docfieldName]:-1) . "  ";
        $sql = "select data from `" . $this->tablename . "_docdata` where `doc_id`=" . (isset($data[$docfieldName])?$data[$docfieldName]:-1) . " order by page";
        return "data:".$this->db->singleValue($sql_mime,[],'mime').";base64, ".$this->db->singleValue($sql,[],'data');
    }


}