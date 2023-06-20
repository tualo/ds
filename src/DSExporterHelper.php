<?php

namespace Tualo\Office\DS;
use Ramsey\Uuid\Uuid;
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\IOFactory;

class DSExporterHelper
{

    public static function rrmdir($dir)
    {
        if (is_dir($dir)) {
            DSExporterHelper::emptydir($dir);
            rmdir($dir);
        }
    }

    public static function emptydir($dir)
    {
        if (is_dir($dir)) {
            $objects = scandir($dir);
            foreach ($objects as $object) {
                if ($object != "." && $object != "..") {
                    if (filetype($dir . "/" . $object) == "dir") DSExporterHelper::rrmdir($dir . "/" . $object);
                    else unlink($dir . "/" . $object);
                }
            }
            reset($objects);
        }
    }


    public static function function($str, $how = '-')
    {
        $search = array(
            "ä", "ö", "ü", "ß", "Ä", "Ö",
            "Ü", "&", "é", "á", "ó",
            " :)", " :D", " :-)", " :P",
            " :O", " ;D", " ;)", " ^^",
            " :|", " :-/", ":)", ":D",
            ":-)", ":P", ":O", ";D", ";)",
            "^^", ":|", ":-/", "(", ")", "[", "]",
            "<", ">", "!", "\"", "§", "$", "%", "&",
            "/", "(", ")", "=", "?", "`", "´", "*", "'",
            "_", ":", ";", "²", "³", "{", "}",
            "\\", "~", "#", "+", ".", ",",
            "=", ":", "=)"
        );
        $replace = array(
            "ae", "oe", "ue", "ss", "Ae", "Oe",
            "Ue", "und", "e", "a", "o", "", "",
            "", "", "", "", "", "", "", "", "",
            "", "", "", "", "", "", "", "", "",
            "", "", "", "", "", "", "", "", "",
            "", "", "", "", "", "", "", "", "",
            "", "", "", "", "", "", "", "", "",
            "", "", "", "", "", "", "", "", "", ""
        );
        $str = str_replace($search, $replace, $str);
        $str = strtolower(preg_replace("/[^a-zA-Z0-9]+/", trim($how), $str));
        return $str;
    }

    public static function exportDataToXSLX($db, $tablename, $columns, $liste, $pathName, &$dateiname, $hcolumns)
    {
        $fn = 'XlsxWriter';
        $fn = 'PHPExcel';
        try {
            $res = $db->singleRow('select phpexporter from ds where table_name={table_name}', array('table_name' => $tablename));
            if ($res !== false) {
                $fn = $res['phpexporter'];
            }
        } catch (\Exception $e) {
        }
        if ($dateiname == '') {
            $dateiname = (Uuid::uuid4())->toString();
            try {
                $res = $db->singleRow('select phpexporterfilename from ds where table_name={table_name}', array('table_name' => $tablename));
                if ($res !== false) {
                    $dsrenderer = new DataRenderer($tablename, $db);
                    if (is_null($res['phpexporterfilename'])||($res['phpexporterfilename']=='')){
                        $res['phpexporterfilename'] = (Uuid::uuid4())->toString();
                    }
                    $dateiname = $dsrenderer->renderTemplate($res['phpexporterfilename'], $_REQUEST);
                }
            } catch (\Exception $e) {
            }
        }


        if ($fn == 'XlsxWriter') {
            $dateiname .= '.xlsx';
            if (class_exists("PhpOffice\PhpSpreadsheet\Spreadsheet")) {
                DSExporterHelper::exportDataToXSLX_PHPSpreadsheet($db, $tablename, $columns, $liste, $pathName, $dateiname, $hcolumns);
            } else {
                DSExporterHelper::exportDataToXSLX_PHPSpreadsheet($db, $tablename, $columns, $liste, $pathName, $dateiname, $hcolumns);
            }
        } else if ($fn == 'PHPExcel') {
            $dateiname .= '.xlsx';
            DSExporterHelper::exportDataToXSLX_PHPSpreadsheet($db, $tablename, $columns, $liste, $pathName, $dateiname, $hcolumns);
        } else if ($fn == 'PHPSpreadsheet') {
            $dateiname .= '.xlsx';
            DSExporterHelper::exportDataToXSLX_PHPSpreadsheet($db, $tablename, $columns, $liste, $pathName, $dateiname, $hcolumns);
        } else if ($fn == 'CSV') {
            $dateiname .= '.csv';
            DSExporterHelper::exportDataToXSLX_CsvWriter($db, $tablename, $columns, $liste, $pathName, $dateiname, $hcolumns);
        } else if ($fn == 'TAB') {
            $dateiname .= '.tab';
            DSExporterHelper::exportDataToXSLX_CsvWriter($db, $tablename, $columns, $liste, $pathName, $dateiname, $hcolumns, 'utf-8', "\t");
        } else if ($fn == 'CSV-ANSI') {
            $dateiname .= '.csv';
            DSExporterHelper::exportDataToXSLX_CsvWriter($db, $tablename, $columns, $liste, $pathName, $dateiname, $hcolumns, '"WINDOWS-1255');
        } else {
            $dateiname .= '.csv';
            DSExporterHelper::exportDataToXSLX_CsvWriter($db, $tablename, $columns, $liste, $pathName, $dateiname, $hcolumns);
//            throw new \Exception("No Library defined");
        }
    }

    public static function exportDataToXSLX_PHPSpreadsheet($db, $tablename, $columns, $liste, $pathName, &$dateiname, $hcolumns)
    {
        if (class_exists("PhpOffice\PhpSpreadsheet\Spreadsheet")) {
        } else {
            throw new \Exception('PhpSpreadsheet needed');
        }

        $spreadsheet = new Spreadsheet();

        $grouped = '';

        foreach ($hcolumns as $key => $value) {
            if (isset($value['grouped']) && ($value['grouped'] == '1')) {
                $grouped = $value['column_name'];
            }
        }
        $grouped_list = [];
        foreach ($liste as $key => $zeile) {
            if ($grouped == '') {
                if (!isset($grouped_list['Daten'])) $grouped_list['Daten'] = [];
                $grouped_list['Daten'][] = $zeile;
            } else {
                if (isset($zeile[$tablename . '__' . $grouped])) {
                    if (!isset($grouped_list[$zeile[$tablename . '__' . $grouped]])) $grouped_list[$zeile[$tablename . '__' . $grouped]] = [];
                    $grouped_list[$zeile[$tablename . '__' . $grouped]][] = $zeile;
                }
            }
        }


        $s = 0;
        foreach ($grouped_list as $title => $liste) {



            $x = 0;
            $y = 0;
            $hash = [];

            $title = preg_replace("/[^0-9a-zäöü\s]/i", "", $title);

            if ($s == 0) {
                $sheet = $spreadsheet->getActiveSheet();
                $sheet->setTitle($title);
            } else {
                $sheet = new Worksheet($spreadsheet, $title);
            }

            foreach ($hcolumns as $key => $value) {
                $sheet->getCellByColumnAndRow($x + 1, $y + 1)->setValue($value['label']);
                $hash[$key] = $x + 1;
                $x++;
            }
            ++$y;

            foreach ($liste as $key => $zeile) {
                $x = 0;
                $rv = "";
                foreach ($hcolumns as $key => $value) {
                    if (isset($zeile[$tablename . '__' . $key])) {
                        $rv = $zeile[$tablename . '__' . $key];
                    } else if (isset($zeile[$key])) {
                        $rv = $zeile[$key];
                    } else {
                        $rv = "";
                    }
                    $sheet->getCellByColumnAndRow($hash[$key], $y + 1)->setValue($rv);
                }
                ++$y;
            }
            if ($s != 0) {
                $spreadsheet->addSheet($sheet, 0);
            }
            $s++;
        }

        $writer = IOFactory::createWriter($spreadsheet, 'Xlsx');
        $writer->save($pathName . $dateiname);
        //echo $pathName . $dateiname;
    }



    public static function exportDataToXSLX_CsvWriter($db, $tablename, $columns, $liste, $pathName, &$dateiname, $hcolumns, $encoding = 'utf-8', $delimiter = ';')
    {
        $header = array();
        $data = array();
        $x = 0;
        $y = 0;
        $row = array();
        //foreach ($columns as $key => $value) {
        foreach ($hcolumns as $key => $value) {

            if ($encoding != 'utf-8') {
                if (function_exists("mb_convert_encoding")) {
                    $value['label'] = utf8_decode($value['label']);
                }
            }

            $row[] = $value['label'];
            $header[] = 'string';
        }

        $data[] = $row;
        ++$y;

        foreach ($liste as $key => $zeile) {
            $x = 0;
            $row = array();
            foreach ($hcolumns as $key => $value) {
                if (isset($zeile[$tablename . '__' . $key])) {
                    $ivalue = $zeile[$tablename . '__' . $key];
                    if ($encoding != 'utf-8') {
                        if (function_exists("mb_convert_encoding")) {
                            $ivalue = utf8_decode($ivalue);
                        }
                    }

                    $row[] = $ivalue;
                } else {
                    $row[] = "";
                }
            }
            $data[] = $row;
            ++$y;
        }

        /*
    $csv = '';


    foreach($data as $row){
        $csv .= '"'.implode('"'.$delimiter.'"',$row).'"'."\r\n";
    }
    if ($encoding!='utf-8'){
        if (function_exists("mb_convert_encoding")){
            $csv = utf8_decode($csv);
        }
    }
    */

        $out = fopen($pathName . $dateiname, 'w');
        foreach ($data as $row) {
            fputcsv($out, $row, $delimiter, '"', "\\");
        }
        fclose($out);
        /*
    fputcsv ( resource $handle , array $fields [, string $delimiter = "," [, string $enclosure = '"' [, string $escape_char = "\\" ]]] ) : int

    file_put_contents( $pathName.$dateiname, $csv );
    */
    }



    public static function getExportColumns($db, $tablename)
    {

        $hcolumns = array();

        try {
            $hcolumns = $db->direct('
        select
            ds_column.`column_name`,
            ds_column.`data_type`,
            if( 
            ( ds_column_list_export.`label`<>\'\' ) or ( ds_column_list_export.`label` is not null ),
            ds_column_list_export.`label`,
            ds_column_list_export.`column_name`
            ) `label`,
            0 `grouped`
        from
            ds_column 
            left join ds_column_list_export
            on (ds_column_list_export.table_name,ds_column_list_export.column_name)  = (ds_column.table_name,ds_column.column_name) 
        where 
            ds_column.`table_name`={table_name}
            and (ifnull(ds_column_list_export.active,0)) > 0
        order by 
            ds_column_list_export.position
        ', array('table_name' => $tablename), 'column_name');
        } catch (\Exception $e) {
        }

        if (count($hcolumns) == 0) {
            try {
                $hcolumns = $db->direct('
            select
                ds_column.`column_name`,
                ds_column.`data_type`,
                if( 
                ( ds_column_list_label.`label`<>\'\' ) or ( ds_column_list_label.`label` is not null ),
                ds_column_list_label.`label`,
                ds_column_list_label.`column_name`
                ) `label`,
                ds_column_list_label.`grouped`
            from
                ds_column 
                left join ds_column_list_label
                on (ds_column_list_label.table_name,ds_column_list_label.column_name)  = (ds_column.table_name,ds_column.column_name) 
            where 
                ds_column.`table_name`={table_name}
                and (ifnull(ds_column_list_label.active,0)) > 0
            order by 
                ds_column_list_label.position
            ', array('table_name' => $tablename), 'column_name');
            } catch (\Exception $e) {
            }
        }


        if (count($hcolumns) == 0) {

            $hcolumns = $db->direct('select
        ds_column_form_label.`column_name`,
            ds_column.`data_type`,
            ds_column_form_label.`label`,
            0 `grouped`
        from
            ds_column_form_label
            join ds_column on (ds_column_form_label.table_name,ds_column_form_label.column_name)  = (ds_column.table_name,ds_column.column_name) 
        where 
            ds_column_form_label.`table_name`={table_name}
        order by 
            ds_column_form_label.position
        
        ', array('table_name' => $tablename), 'column_name');
        }
        return $hcolumns;
    }
}
