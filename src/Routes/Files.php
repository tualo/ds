<?php

namespace Tualo\Office\DS\Routes;

use Exception;
use Tualo\Office\Basic\TualoApplication as App;
use Tualo\Office\Basic\Route;
use Tualo\Office\Basic\IRoute;
use Tualo\Office\DS\DSReadRoute;
use Tualo\Office\DS\DSFileHelper;
use Tualo\Office\DS\DSTable;


class Files extends \Tualo\Office\Basic\RouteWrapper
{
    public static function register()
    {

        Route::add('/dsfiles/(?P<tablename>[\w\-\_\|]+)/(?P<file_id>[\w\-\_\|]+)', function ($match) {

            $db = App::get('session')->getDB();
            $session = App::get('session');
            try {
                $table = new DSTable($db, $match['tablename']);
                $table->filter('__file_id', '=', $match['file_id']);
                $table->read();
                if ($table->empty()) throw new Exception('File not found!');


                if (($mime = $db->singleValue("select type from ds_files where file_id = {file_id} and table_name= {tablename}", $match, 'type')) === false) {
                    throw new Exception('File not found!');
                }
                if (($name = $db->singleValue("select name from ds_files where file_id = {file_id} and table_name= {tablename}", $match, 'name')) === false) {
                    throw new Exception('File not found!');
                }

                if (($dbcontent = $db->singleValue("select data from ds_files_data where file_id = {file_id}  ", $match, 'data')) === false) {
                    throw new Exception('File not found!');
                }

                if ($dbcontent == 'chunks') {
                    $dbcontent = '';

                    header('Content-Type: ' . $mime);
                    header('Content-Transfer-Encoding: binary');
                    header('Content-Disposition: attachment; filename="' . $name . '"');


                    $fp = fopen(App::get('tempPath') . '/test.data', 'w+');
                    stream_filter_append($fp, "convert.base64-decode", STREAM_FILTER_WRITE);

                    $liste = $db->direct("select page from ds_files_data_chunks where file_id = {file_id} order by page ", $match);
                    foreach ($liste as $item) {
                        $match['page'] = $item['page'];
                        $dbcontent = $db->singleValue("select data from ds_files_data_chunks where file_id = {file_id} and page = {page} ", $match, 'data');
                        // echo $dbcontent;

                        if ($item['page'] == 0) {
                            list($dataprefix, $dbcontent) = explode(',', $dbcontent);
                        }
                        //echo 1;
                        $dbcontent = str_replace("\\", "", $dbcontent);
                        fwrite($fp, $dbcontent);
                    }
                    fclose($fp);



                    readfile(App::get('tempPath') . '/test.data');
                    unlink(App::get('tempPath') . '/test.data');
                } else {
                    list($dataprefix, $content) = explode(',', $dbcontent);

                    App::contenttype($mime);
                    header('Content-Disposition: attachment; filename="' . $name . '"');

                    App::body(base64_decode($content));
                    Route::$finished = true;
                }
            } catch (Exception $e) {
                App::contenttype('application/json');
                App::result('msg', $e->getMessage());
            }
        }, ['get', 'post'], true);


        Route::add('/dsfiles/(?P<tablename>[\w\-\_\|]+)/(?P<file_id>[\w\-\_\|]+)', function ($match) {
            $db = App::get('session')->getDB();
            $session = App::get('session');
            App::contenttype('application/json');
            try {



                $input = json_decode(file_get_contents('php://input'), true);
                if (is_null($input)) throw new Exception("Error Processing Request", 1);
                App::result('input', $input);

                $found = $db->singleRow('select * from ds_files where file_id = {file_id} and table_name= {tablename}', $match);
                if ($found === false) {
                    throw new Exception('File not found!');
                }


                $sql = 'insert into ds_files_data_chunks (file_id,page,data) values ({file_id},{page},{data}) on duplicate key update data= values(data) ';
                $db->direct($sql, [
                    'file_id' => $match['file_id'],
                    'page' => $input['data']['page'],
                    'data' => $input['data']['__file_data']
                ]);

                $sql = 'update ds_files set size = (select sum(length(data)) from ds_files_data_chunks where  file_id = {file_id} ) where  file_id = {file_id} ';
                $db->direct($sql, [
                    'file_id' => $match['file_id'],
                ]);

                App::result('sql', $db->last_sql);

                App::result('success', true);
            } catch (Exception $e) {
                App::contenttype('application/json');
                App::result('msg', $e->getMessage());
            }
        }, ['patch'], true);

        Route::add('/dsfilesdirect/(?P<tablename>[\w\-\_\|]+)/(?P<file_id>[\w\-\_\|]+)', function ($match) {

            $db = App::get('session')->getDB();
            $session = App::get('session');
            try {
                $table = new DSTable($db, $match['tablename']);
                $table->filter('__file_id', '=', $match['file_id']);
                $table->read();
                if ($table->empty()) throw new Exception('File not found!');


                if (($mime = $db->singleValue("select type from ds_files where file_id = {file_id} and table_name= {tablename}", $match, 'type')) === false) {
                    throw new Exception('File not found!');
                }
                if (($name = $db->singleValue("select name from ds_files where file_id = {file_id} and table_name= {tablename}", $match, 'name')) === false) {
                    throw new Exception('File not found!');
                }

                if (($dbcontent = $db->singleValue("select data from ds_files_data where file_id = {file_id}  ", $match, 'data')) === false) {
                    throw new Exception('File not found!');
                }
                list($dataprefix, $content) = explode(',', $dbcontent);

                App::contenttype($mime);
                // header('Content-Disposition: attachment; filename="'.$name.'"');

                App::body(base64_decode($content));
                Route::$finished = true;
            } catch (Exception $e) {
                App::contenttype('application/json');
                App::result('msg', $e->getMessage());
            }
        }, ['get', 'post'], true);


        Route::add('/dsfilesdirect/(?P<output>[\w\-\_\|]+)/(?P<tablename>[\w\-\_\|]+)/(?P<file_id>[\w\-\_\|]+)', function ($match) {
            $db = App::get('session')->getDB();
            $session = App::get('session');
            try {
                $table = new DSTable($db, $match['tablename']);
                $table->filter('__file_id', '=', $match['file_id']);
                $table->read();
                if ($table->empty()) throw new Exception('File not found!');


                if (($mime = $db->singleValue("select type from ds_files where file_id = {file_id} and table_name= {tablename}", $match, 'type')) === false) {
                    throw new Exception('File not found!');
                }
                if (($name = $db->singleValue("select name from ds_files where file_id = {file_id} and table_name= {tablename}", $match, 'name')) === false) {
                    throw new Exception('File not found!');
                }

                if (($dbcontent = $db->singleValue("select data from ds_files_data where file_id = {file_id}  ", $match, 'data')) === false) {
                    throw new Exception('File not found!');
                }
                list($dataprefix, $content) = explode(',', $dbcontent);

                App::contenttype($mime);
                // application/vnd.openxmlformats-officedocument.wordprocessingml.document
                // header('Content-Disposition: attachment; filename="'.$name.'"');

                App::body(base64_decode($content));
                Route::$finished = true;
            } catch (Exception $e) {
                App::contenttype('application/json');
                App::result('msg', $e->getMessage());
            }
        }, ['get', 'post'], true);
    }
}
