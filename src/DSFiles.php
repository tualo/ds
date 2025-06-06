<?php

namespace Tualo\Office\DS;

use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\DS\DSTable;
use Ramsey\Uuid\Uuid;

class DSFiles
{
    private mixed $db;
    private string $tablename;
    private string $error = '';
    public static function instance(string $tablename = 'test'): DSFiles
    {
        return new DSFiles(App::get('session')->getDB(), $tablename);
    }
    function getError(): string
    {
        return $this->error;
    }
    function __construct(mixed $db, string $tablename)
    {
        $this->db = $db;
        $this->tablename = $tablename;
    }

    public static function fromUploadForm(string $attribute): array
    {
        $result = [
            "__file_data" => "data:application/pdf;base64,",
            "__file_id" => "",
            "__file_name" => $_FILES[$attribute]['name'],
            "__file_size" => 0,
            "__file_type" => "application/pdf"
        ];
        $sfile = $_FILES[$attribute]['tmp_name'];
        $type = $_FILES[$attribute]['type'];
        $local_file_name = App::get('tempPath') . '/.ht_' . (Uuid::uuid4())->toString();
        $result['error'] = $_FILES[$attribute]['error'];
        if ($result['error']  == UPLOAD_ERR_OK) {
            if (file_exists($local_file_name)) {
                unlink($local_file_name);
            }
            move_uploaded_file($sfile, $local_file_name);
            $result['__file_size'] = filesize($local_file_name);
            $result['__file_type'] = $type;
            $result['__file_data'] = 'data:' . $type . ';base64,' . base64_encode(file_get_contents($local_file_name));
            unlink($local_file_name);
        }
        return $result;
    }
    // :php
    //    $logodata = \Tualo\Office\DS\DSFiles::instance('tualocms_bilder')->getBase64('titel','Wahllogo'));

    public function getRecord(string $fieldName, string $fieldValue, bool $emptyOnError = false): array
    {
        $table = new DSTable($this->db, $this->tablename);
        $table->filter($fieldName, '=', $fieldValue);
        $table->read();
        if ($table->empty()) {
            $this->error = 'File not found! (in ' . $this->tablename . ')';
            if ($emptyOnError) return [];
            throw new \Exception('File not found!');
        }
        return $table->getSingle();
    }


    public function getInfo(string $fieldName, string $fieldValue, bool $emptyOnError = false, array $record = []): array|false
    {
        if (empty($record)) {
            $record = $this->getRecord($fieldName, $fieldValue, $emptyOnError);
            if (!isset($record['__file_id'])) {
                throw new \Exception('__file_id not found!');
            }
        }
        $record['tablename'] = $this->tablename;
        return $this->db->singleRow("select * from ds_files where file_id = {__file_id} and table_name= {tablename}", $record);
    }

    public function decode(string $dbcontent): string
    {
        if (strpos($dbcontent, 'data:') === 0) {
            $parts = explode(',', $dbcontent, 2);
            if (count($parts) == 2) {
                return base64_decode($parts[1]);
            }
        }
        return base64_decode($dbcontent);
    }

    public function getDecoded(string $fieldName, string $fieldValue, bool $emptyOnError = false): string
    {
        return $this->decode($this->getBase64($fieldName, $fieldValue, $emptyOnError));
    }




    public function getBase64(string $fieldName, string $fieldValue, bool $emptyOnError = false): string
    {

        $record = $this->getRecord($fieldName, $fieldValue, $emptyOnError);
        $record['tablename'] = $this->tablename;
        $info = $this->getInfo($fieldName, $fieldValue, $emptyOnError, $record);

        if (($mime = $this->db->singleValue("select type from ds_files where file_id = {__file_id} and table_name= {tablename}", $record, 'type')) === false) {

            $this->error = 'File not found! (in ds_files)';
            if ($emptyOnError) return '';
            throw new \Exception('File not found!');
        }
        if (($dbcontent = $this->db->singleValue("select data from ds_files_data where file_id = {__file_id}  ", $record, 'data')) === false) {
            $this->error = 'File not found! (in ds_files_data)';
            if ($emptyOnError) return '';
            throw new \Exception('File not found!');
        }
        if ($dbcontent == 'chunks') {
            $dbcontent = '';
            $liste = $this->db->direct("select page from ds_files_data_chunks where file_id = {__file_id} order by page ", $record);
            foreach ($liste as $item) {
                $record['page'] = $item['page'];
                $dbcontent .= $this->db->singleValue("select data from ds_files_data_chunks where file_id = {__file_id} and page = {page} ", $record, 'data');
            }
        }
        return $dbcontent;
    }
}
