<?php
namespace tualo\Office\DS\DS;
use tualo\Office\Basic\TualoApplication;


class DataRenderer {
    
    public static $_stored=[];
    public static function store($key,$value) { self::$_stored[$key]=$value;  }
    public static function stored($key){
        return self::$_stored[$key];
    }

    public static function ansii($string) {

        $string = str_replace("ä", "ae", $string);
        $string = str_replace("ö", "oe", $string);
        $string = str_replace("ü", "ue", $string);
        $string = str_replace("ß", "ss", $string);
        $string = str_replace("/", "_", $string);
        $string = str_replace("\\", "_", $string);
        $string = str_replace("+", "_", $string);
        $string = str_replace("?", "_", $string);
        $string = str_replace("\"", "_", $string);
        $string = str_replace("'", "_", $string);

        $string = preg_replace("/[^a-z0-9]/i", "_", $string);
        return $string;

    }

    public static function renderFunctionTemplate($tpl, $ds) {
      $return = $tpl;
      $i = preg_match_all('/\{\:(?P<name>([a-z0-9\']|\(|\))+)\}/i', $tpl, $matches);

      if (($i !== false) && (isset($matches['name']))){
        foreach($matches['name'] as $match){
          $sql_func = $match;
          $v = TualoApplication::get('session')->getDB()->singleValue('select '.$sql_func.'  `res` ',array(),'res');
          $return = str_replace('{:'.$match.'}',$v,$return);
        }
      }
      return $return;
    }

    /*
    public static function renderXTemplate($xml, $ds,$pdf=null)
		{
      $txt='';
      require __REAL_PATH__.'/cmp/cmp_ds/p/ds_basic/render_x_template.php';
      return $txt;
    }
    */

    public static function getBetween($content, $start, $end) {
      $n = explode($start, $content);
      $result = Array();
      foreach ($n as $val) {
          $pos = strpos($val, $end);
          if ($pos !== false) {
              $result[] = substr($val, 0, $pos);
          }
      }
      return $result;
    }


    public static function renderCeil($val){
        return ceil($val);

    }
    public static function renderFloor($val ){
        return floor($val);

    }
    public static function renderRound($val,  $precision=2){
        return round($val,$precision);

    }

    public static function renderDENumberFormat($val){
        return number_format(floatval($val),2,",",".");
    }
    
    public static function renderTemplate($tpl, $ds, $runfunction=true, $replaceOnlyMatches=false){
            $return = $tpl;
            $return = str_replace('{DATE}', date('Y-m-d', time()), $return);
            $return = str_replace('{DEDATE}', date('d.m.Y', time()), $return);
            $return = str_replace('{TIME}', date('H:i:s', time()), $return);
            $return = str_replace('{GUID}', "TEST" /*generateGUID(25)*/, $return);
            
            
            

            $matches=array();
            $i = preg_match_all('/\{(?P<name>([a-z0-9_\:]+))\}/', $return, $matches);
            if (isset($matches['name'])&&(count($matches['name'])>0)) {
                foreach ($matches['name'] as $p) {
                    
                    $func = '';
                    $a = explode(':', $p);
                    $p = $a[0];
                    $p_r = $p;
                    if (isset($a[1])) {
                        $func = $a[1];
                        $p_r = $p . ':' . $func;
                    }

                    //$v = $this->xpathValue($p, $ds['ridx']);
                    $v = '';
                    /*
                    if ((!isset($ds[$p]))&&(isset($ds[$this->tablename_lower.'__'.$p]))){
                        $v = $ds[$this->tablename_lower.'__'.$p];
                    }else{
                    */
                    if (isset($ds[$p])){
                        $v = $ds[$p];
                        
                    }else if ($replaceOnlyMatches==true){
                        continue;
                    }
                    //}
                    if ($func != '') {
                    /*
                    if (!class_exists("rr_shunt_Context")){
                        require_once(__REAL_PATH__.'/cmp/cmp_ds/p/psy.php');
                        $ctx = new rr_shunt_Context;
                        foreach($ds as $field=>$value){
                        $ctx->def($field, $value);
                        $ctx->def(str_replace($field,$this->tablename().'__',''), $value);
                        }
                        $value = rr_shunt_Parser::parse($p, $ctx);
                        $return = str_replace('{[' . $p . ']}', ($value), $return);
                    }
                    */

                    if ($func == 'decompactdate') {
                        $v = str_replace('.', '', FormatDate($v));
                    }
                    if ($func == 'semisplit') {
                        $v = str_replace(';', "<br>",  $v );
                        $v = str_replace('|', "<br>",  $v );
                    }
                    if ($func == 'dedate') {
                        $v = FormatDate($v);
                    }
                    if ($func == 'ansii') {
                        $v = self::ansii($v);
                    }
                    if ($func == 'decurrency') {
                        $v = str_replace('.', ',', sprintf("%01.2f", $v));
                    }
                    if ($func == 'nl') {
                        if ($v != '') {
                        $v = $v . "\n";
                        }
                    }
                    if ($func == 'sp') {
                        if ($v != '') {
                        $v = $v . ' ';
                        }
                    }
                    }
                    if (is_array($v)){

                        $v = json_encode($v);

                    }
                    if (is_bool($v)){
                        $v= ($v)?'true':'false';
                    }
                    $return = str_replace('{' . $p_r . '}', ($v), $return);
                }
                
            } else {
                if ($runfunction){
                    return self::renderFunctionTemplate($return,$ds);
                }else{
                    return $return;
                }
            }
            if ($runfunction){
                return self::renderFunctionTemplate($return,$ds);
            }else{
                return $return;
            }
        }
        
    }
