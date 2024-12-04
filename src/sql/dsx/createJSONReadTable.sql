DELIMITER //


CREATE OR REPLACE PROCEDURE `createJSONReadTable`(in use_table_name varchar(128))
BEGIN 
    for rec in (
        select 
            concat(
                'create or replace view `view_readtable_',table_name,'_jsonrow`as select 
                    `',table_name,'`.*,
                    json_object(
                        ',
                        group_concat(
                            concat('"',column_name,'",`',table_name,'`.`',column_name,'`')
                            separator ','
                        )
                        ,'
                    ) json_row
                
                from `',table_name,'`
                '
            ) stmt
        from ds_column where table_name = use_table_name group by table_name
    ) do
        PREPARE stmt FROM rec.stmt;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    end for;

          
END //