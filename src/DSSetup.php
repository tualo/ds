<?php
namespace Tualo\Office\DS;
use Tualo\Office\Basic\TualoApplication;
use Tualo\Office\DS\DataRenderer;
use Tualo\Office\DS\DSTable;

class DSSetup {
    private mixed $db = "";
    private mixed $tablename = "";
    private array $tables = [
        'ds'=>['insert_command'=>'INSERT INTO','update_command'=>'ON DUPLICATE KEY UPDATE'],
        'ds_column'=>['insert_command'=>'INSERT IGNORE INTO','update_command'=>''],
        'ds_column_list_label'=>['insert_command'=>'INSERT IGNORE INTO','update_command'=>''],
        'ds_column_form_label'=>['insert_command'=>'INSERT IGNORE INTO','update_command'=>''],
        'ds_dropdownfields'=>['insert_command'=>'INSERT IGNORE INTO','update_command'=>''],
        'ds_reference_tables'=>['insert_command'=>'INSERT IGNORE INTO','update_command'=>''],
        'ds_addcommands'=>['insert_command'=>'INSERT IGNORE INTO','update_command'=>''],
        'ds_access'=>['insert_command'=>'INSERT IGNORE INTO','update_command'=>'','where'=>['role','in',['administration','_default_',]]],
        'ds_renderer'=>['insert_command'=>'INSERT IGNORE INTO','update_command'=>''],
    ];
    function __construct(mixed $db,string $tablename){
        $this->db=$db;
        $this->tablename = $tablename;
    }
    public function table($tablename):DSSetup{
        return new DSSetup($this->db,$tablename);
    }

    public function export(){
        $data = [];
        foreach($this->tables as $tablename=>$info){
            $table = DSTable::init($this->db)
                ->t('ds_column')
                ->f('table_name','=',$tablename)
                ->f('writeable','=',1)
                ->f('existsreal','=',1);
                
            $this->tables[$tablename]['config'] = $table->get();
        }
        foreach($this->tables as $tablename=>$info){
            $table = DSTable::init($this->db)
                ->t($tablename)
                ->f('table_name','=',$this->tablename);
            if (isset($info['where'])){
                $table->f($info['where'][0],$info['where'][1],$info['where'][2]);
            }
                
            $values = $table->get();


            if ($table->error()){
                throw new \Exception($table->errorMessage());
            }
            $flds = [];
            $vals = [];
            $upds = [];
            foreach($values as $key=>$value){
                
                foreach($info['config'] as $config){
                    $config['column_name']=strtolower($config['column_name']);
                    if (isset($value[$config['column_name']])){
                        $flds[] = '`'.$config['column_name'].'`';
                        $upds[] = '`'.$config['column_name'].'`=values(`'.$config['column_name'].'`)';
                        $vals[] = $this->db->escape_string($value[$config['column_name']]);
                    }
                }
                $cmd = $info['insert_command'];
                $update_command = $info['update_command'];
                if ($update_command!=''){
                    $update_command = 'ON DUPLICATE KEY UPDATE '.implode(',',$upds);
                }
                $data[] = "$cmd `$tablename` (".implode(',',$flds).") VALUES ('".implode("','",$vals)."') $update_command; ";
            
            }
        }
        //print_r($this->tables);
        return $data;
    }
}
/*

cd -P -- "$(dirname -- "$0")"
DS_DATA=$(mysqldump --compact --complete-insert --no-create-info --tables ${@:2} ds --where "table_name = '$1'")
DATA=$(echo $DS_DATA | sed -e 's/;/ ON DUPLICATE KEY UPDATE title=VALUES(title), reorderfield=VALUES(reorderfield), use_history=VALUES(use_history), searchfield=VALUES(searchfield), displayfield=VALUES(displayfield), sortfield=VALUES(sortfield), searchany=VALUES(searchany), hint=VALUES(hint), overview_tpl=VALUES(overview_tpl), sync_table=VALUES(sync_table), writetable=VALUES(writetable), globalsearch=VALUES(globalsearch), listselectionmodel=VALUES(listselectionmodel), sync_view=VALUES(sync_view), syncable=VALUES(syncable), cssstyle=VALUES(cssstyle), alternativeformxtype=VALUES(alternativeformxtype), read_table=   VALUES(read_table), class_name=VALUES(class_name), special_add_panel=VALUES(special_add_panel), existsreal=VALUES(existsreal), character_set_name=VALUES(character_set_name), read_filter=VALUES(read_filter), listxtypeprefix=VALUES(listxtypeprefix), phpexporter=VALUES(phpexporter), phpexporterfilename=VALUES(phpexporterfilename), combined=VALUES(combined), default_pagesize=VALUES(default_pagesize), allowForm=VALUES(allowForm), listviewbaseclass=VALUES(listviewbaseclass), showactionbtn=VALUES(showactionbtn), modelbaseclass=VALUES(modelbaseclass);/' )
./remove_info "$DATA"
DATA=$(mysqldump --insert-ignore --compact --complete-insert --no-create-info --tables ${@:2} ds_column --where "table_name = '$1'")
./remove_info "$DATA"
DATA=$(mysqldump --insert-ignore --compact --complete-insert --no-create-info --tables ${@:2} ds_column_list_label --where "table_name = '$1'")
./remove_info "$DATA"
DATA=$(mysqldump --insert-ignore --compact --complete-insert --no-create-info --tables ${@:2} ds_column_form_label --where "table_name = '$1'")
./remove_info "$DATA"
DATA=$(mysqldump --insert-ignore --compact --complete-insert --no-create-info --tables ${@:2} ds_dropdownfields --where "table_name = '$1'")
./remove_info "$DATA"
DATA=$(mysqldump --insert-ignore --compact --complete-insert --no-create-info --tables ${@:2} ds_reference_tables --where "table_name = '$1'")
./remove_info "$DATA"
DATA=$(mysqldump --insert-ignore --compact --complete-insert --no-create-info --tables ${@:2} ds_addcommands --where "table_name = '$1'")
./remove_info "$DATA"
DATA=$(mysqldump --insert-ignore --compact --complete-insert --no-create-info --tables ${@:2} ds_access --where "table_name = '$1' and \`role\` in ('administration','_default_')")
./remove_info "$DATA"
DATA=$(mysqldump --insert-ignore --compact --complete-insert --no-create-info --tables ${@:2} ds_renderer --where "table_name = '$1' ")
./remove_info "$DATA"


*/