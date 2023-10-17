<?php
namespace Tualo\Office\DS;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\DS\DSTable;

class DSFiles {
    private mixed $db;
    private string $tablename;
    public static function instance(string $tablename='test'):DSFiles{
        return new DSFiles( App::get('session')->getDB(),$tablename);
    }
    function __construct(mixed $db,string $tablename){
        $this->db=$db;
        $this->tablename=$tablename;
    }

    // php:
    //    $logodata = \Tualo\Office\DS\DSFiles::instance('tualocms_bilder')->getBase64('titel','Wahllogo'));

    public function getBase64(string $fieldName,string $fieldValue):string{

        $table = new DSTable($this->db ,$this->tablename);
        $table->filter($fieldName,'=',$fieldValue);
        $table->read();
        if ($table->empty()) throw new \Exception('File not found!');

        $record = $table->getSingle();
        $record['tablename'] = $this->tablename;

        if (($mime = $this->db->singleValue("select type from ds_files where file_id = {file_id} and table_name= {tablename}",$record,'type'))===false){
            throw new \Exception('File not found!');
        }
        if (($dbcontent = $this->db->singleValue("select data from ds_files_data where file_id = {file_id}  ",$record,'data'))===false){
            throw new \Exception('File not found!');
        }
        return $dbcontent;

    }


}