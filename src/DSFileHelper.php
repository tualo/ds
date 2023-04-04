<?php
namespace Tualo\Office\DS;
use Tualo\Office\Basic\TualoApplication;
use Ramsey\Uuid\Uuid;
class DSFileHelper{

    public static function uploadRoute($tablename){
        $db = TualoApplication::get('session')->getDB();
        $session = TualoApplication::get('session');
        try {
            


            $id = -1;
            $success=false;
            $msg="";
            if (!function_exists("cmp_ds_error2txt")){
                function cmp_ds_error2txt($error){
                    switch($error){
                        case UPLOAD_ERR_INI_SIZE: return "UPLOAD_ERR_INI_SIZE: Die Datei ist zu gro&szlig"; break;
                        case UPLOAD_ERR_FORM_SIZE: return "UPLOAD_ERR_FORM_SIZE: Die Datei ist zu gro&szlig"; break;
                        case UPLOAD_ERR_PARTIAL: return "UPLOAD_ERR_PARTIAL: Die Datei wurde nur teilweise hochgeladen"; break;
                        case UPLOAD_ERR_NO_FILE: return "UPLOAD_ERR_NO_FILE: Es wurde keine Datei hochgeladen"; break;
                        case 0: return " "; break;
                        default: return "Unbekannter Fehler"; break;
                    }

                }
            }

            $writetable = $db->singleValue('select getDSWriteTable({tablename}) s',array('tablename'=>$tablename),'s');

            $error="";
            if (isset($_FILES['userfile'])){
                $sfile = $_FILES['userfile']['tmp_name'];
                $name = $_FILES['userfile']['name'];
                $type = $_FILES['userfile']['type'];
                $error = $_FILES['userfile']['error'];
                $request = $_REQUEST;

                if ($error == UPLOAD_ERR_OK){

                    $parts = explode('.',$name);
                    $ext = $parts[count($parts)-1];
                    $f = TualoApplication::get("basePath").'/temp/'.TualoApplication::get("sid").'/upload.'.$ext;

                    if (file_exists( $f )){
                        unlink( $f );
                    }
                    move_uploaded_file($sfile, $f );


                    
                    $res = DSFileHelper::setFile($db,$tablename,$writetable,$request,$f,$name,$ext);

                    TualoApplication::result('mime',$res['mime']);
                    TualoApplication::result('writetable',$writetable);
                            
                    TualoApplication::result('success', true );     
                    
                    if (file_exists(TualoApplication::get("basePath").'/temp/'.TualoApplication::get("sid").'/upload.'.$ext)){
                        unlink(TualoApplication::get("basePath").'/temp/'.TualoApplication::get("sid").'/upload.'.$ext);
                    }
                }
            }


            TualoApplication::result('error',cmp_ds_error2txt ($error));
            TualoApplication::result('msg',$msg);
            TualoApplication::result('file_id',$id);
            
        }catch(\Exception $e){

            TualoApplication::result('sql', $db->last_sql);
            TualoApplication::result('msg', $e->getMessage());
        }
        TualoApplication::contenttype('application/json');
    }
    public static function createDocumentDDL($tablename){
        $tablename=strtolower($tablename);

        $db = TualoApplication::get('session')->getDB();
        $sql = '
        create table if not exists #tablename_doc (
            #iddef,
            doc_id integer not null,
            mime varchar(150) not null,
            ext varchar(50) not null,
            column_name varchar(50) not null,
            primary key (doc_id)
        )
        ';
        $ids = array();
        $fks = array();
        $enclose='`';
        
        $explain = $db->direct('explain '.$tablename);

        foreach( $explain as $config ){
            if ( $config['key']=='PRI' ){

                $def =  $enclose.$config['field'].$enclose;
                $def .=  ' '.$config['type'].' not null';
                $ids[] = $def;
                $fks[] = $enclose.$config['field'].$enclose;
            }
        }
        $sql =str_replace('#iddef',implode(',',$ids),$sql);
        $sql =str_replace('#fk',implode(',',$fks),$sql);
        $sql =str_replace('#tablename',$tablename.'',$sql);
        $db->execute($sql);
    
        $sql = 'create table if not exists #tablename_docdata(
            doc_id integer,
            page integer default 0,
            data longtext,
            primary key (doc_id,page),
            foreign key (doc_id) references `#tablename_doc` (doc_id)
            on update cascade
            on delete cascade
        )';
        $sql =str_replace('#iddef',implode(',',$ids),$sql);
        $sql =str_replace('#fk',implode(',',$fks),$sql);
        $sql =str_replace('#tablename',$tablename.'',$sql);


        $db->execute($sql);
    
        try{
            $sql = 'alter table #tablename_doc
            add  constraint `fk_#tablename_doc`
            foreign key (#fk) references `#tablename` (#fk)
            on update cascade
            on delete cascade
            ';
            $sql =str_replace('#iddef',implode(',',$ids),$sql);
            $sql =str_replace('#fk',implode(',',$fks),$sql);
            $sql =str_replace('#tablename',$tablename.'',$sql);
            $db->execute($sql);
        }catch(\Exception $e){
    
        }
      
    }

    public static function uploadFileToDB(string $attribute,string $table_name, array $hash):void{
        $db = TualoApplication::get('session')->getDB();
        $sfile = $_FILES[$attribute]['tmp_name'];
        $name = $_FILES[$attribute]['name'];
        $extension = pathinfo($name, PATHINFO_EXTENSION);
        $type = $_FILES[$attribute]['type'];
        $error = $_FILES[$attribute]['error'];
        $local_file_name = TualoApplication::get('tempPath').'/.ht_'.(Uuid::uuid4())->toString().$extension;
        if ($error == UPLOAD_ERR_OK){
            if (file_exists($local_file_name)){
                unlink($local_file_name);
            }
            move_uploaded_file($sfile,$local_file_name);
        }
        $res = self::setFile($db,$table_name,$table_name,$hash,$local_file_name,$name,$extension);
        if (file_exists($local_file_name)){
            unlink($local_file_name);
        }
    }


    public static function setFile($db,$tablename,$writetable,$request,$file,$originalname,$ext){
        self::createDocumentDDL($writetable);

            $key = array();
            $keyHash = array();
            $upd = array();
            $explain = $db->direct('explain '.$writetable);
            foreach( $explain as $config ){
                if ( $config['key']=='PRI' ){
                    $key[] = $config['field'];
                    $upd[] = '`'.$config['field'].'`={'.$config['field'].'}';
                    $keyHash[$config['field']]=$request[$tablename.'__'.$config['field']];
                }
            }
    
            $explain = $db->direct('explain '.$writetable.'_docdata');
            foreach( $explain as $config ){
                if ( ($config['field']=='data') && ($config['type']!='longtext') ){
                    $db->direct("alter table ".$writetable . "_docdata modify data longtext");
                }
            }
    
            $key[]='doc_id';
            $key[]='mime';
            $key[]='ext';
            $key[]='column_name';
            $key[]='original_filename';
            $key[]='filesize';

            $db->direct("call addFieldIfNotExists('".$writetable . "_doc','column_name','varchar(50)');");
            $db->direct("call addFieldIfNotExists('".$writetable . "_doc','original_filename','varchar(255)');");
            $db->direct("call addFieldIfNotExists('".$writetable . "_doc','filesize','bigint');");
        


            $sql1 = "insert into " . $writetable . "_doc(`".implode('`,`',$key)."`) values ({".implode('},{',$key)."});";
            $sql2 = "insert into " . $writetable . "_docdata(doc_id,page,data) values ({doc_id},{page},{data});";
            $sql3 = "update " . $writetable . " set " . substr($request['fieldName'],strlen($tablename.'__')) . "={doc_id} where ".implode(' and ',$upd).";";


            $finfo = finfo_open(FILEINFO_MIME_TYPE); // return mime type ala mimetype extension
            $mime = finfo_file($finfo, $file );
            finfo_close($finfo);
            if ($mime == '') {
                $mime = 'unkown';
            }
            $keyHash['filesize'] = filesize( $file );

            $keyHash['doc_id'] = $db->singleValue('select ifnull(max(doc_id),0)+1 v from '.$writetable.'_doc',array(),'v');
            $keyHash['mime'] = $mime;
            $keyHash['ext'] = $ext;
            $keyHash['original_filename'] = $originalname;
            $id = $keyHash['doc_id'];
            $keyHash['column_name'] = substr($request['fieldName'],strlen($tablename.'__'));
            $keyHash['page'] = 0;
            $keyHash['data'] = base64_encode(file_get_contents( $file ) );
            $db->direct($sql1,$keyHash);
            $db->direct($sql2,$keyHash);
            $db->direct($sql3,$keyHash);
            
            return $keyHash;
    }

    public static function getFileMimeType($db,$tablename,$id){
        $req = array();

        $req['success'] = false;
        try {
            $sql = "select * from " . $tablename . "_doc where doc_id=" . $id . "";
            $c = $db->direct($sql);
            if (count($c) == 1) {
                $req['mime'] = $c[0]['mime'];
                $req['original_filename'] = 'not set';
                if (isset( $c[0]['original_filename'] )){
                    $req['original_filename'] = $c[0]['original_filename'];

                }
                if (isset( $c[0]['filesize'] )){
                    $req['filesize'] = $c[0]['filesize'];

                }
                $req['success'] = true;
                $req['id'] = $id;//$request['id'];
            }else{
                $req['msg'] = 'File not found';
            }
        } catch (\Exception $e) {
            $req['msg'] = $e->getMessage();
            $req['success'] = false;
        }
        return $req;
    }


    public static function getFile($db,$tablename,$id,$direct=false,$base64=false,$maxwidth=-1,$maxheight=-1,$path='',$usename=''){
        if ($path == ''){
            $path = TualoApplication::get('basePath') . '/temp/' . TualoApplication::get('sid') . '/';
        }
        $req = array();
        $req['success'] = false;
        try {
            $sql = "select ext,mime from " . $tablename . "_doc where doc_id=" . $id . "  ";

            $c1 = $db->direct($sql);
            $ext = 'dat';
            $mime = 'application/octet-stream';
            if (count($c1) == 1) {
                $ext = $c1[0]['ext'];
                $mime = $c1[0]['mime'];
            }
            $sql = "select data from " . $tablename . "_docdata where doc_id=" . $id . " order by page";

            $c = $db->direct($sql);
            $d = "";
            foreach ($c as $p) {
                $d .= $p['data'];
            }
            if ($d==''){
                ob_start();
                $im = imagecreate(5, 5);
                imagepng($im);
                $d = base64_encode(ob_get_contents());
                ob_end_clean();
            }

            if (($maxwidth>0)||($maxheight>0)){
                if (strlen($d)>100){
                    if (($mime=='image/png')||($mime=='image/jpeg')){
                        if (function_exists('imagescale')){
                
                            $img_data = base64_decode($d);
                            $size = getimagesizefromstring($img_data);
                            if (($size[0]>$maxwidth)||($size[1]>$maxheight)){
                                if ($maxwidth<0){ $maxwidth = $size[0]*($maxheight/$size[1]); }
                                $im = imagecreatefromstring($img_data);
                                $im = imagescale($im,$maxwidth);
                                ob_start();
                                imagepng($im);
                                $d = base64_encode(ob_get_contents());
                                ob_end_clean();
                    
                            }
                        }
                    }
                }
            }

            if ($direct===true){
                if ($base64==true){
                    $req['data']=($d);
                }else{
                    $req['data']=base64_decode($d);
                }
                $req['length']=strlen($d);
            
            }else{

                $o = base64_decode($d);
                if ( (strlen($usename)>0) ){
                    $fname = $usename . '.' . $ext;
                }else{
                    $fname = (Uuid::uuid4())->toString() . '.' . $ext;
                }
                file_put_contents($path . $fname, $o);
                $req['file'] = $fname;
            }
            $req['success'] = true;
            $req['mime'] = $mime;
        } catch (\Exception $e) {
            $req['msg'] = $e->getMessage();
            $req['success'] = false;
        }
        return $req;
    }


    

    
}