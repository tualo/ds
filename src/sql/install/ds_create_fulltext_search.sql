
DELIMITER //



CREATE OR REPLACE PROCEDURE `ds_create_fulltext_search`( in_table_name varchar(128) )
    MODIFIES SQL DATA
BEGIN


    declare proc_sub text;


    declare insert_sqlstmt text;
    declare update_sqlstmt text;
    declare refresh_sqlstmt text;
    declare sqlstmt text;
    declare table_template text default '
    create table if not exists `ds_ftsearch_<tablename>` (

      <column_defs>,
      primary key (<columns>),

      `searchvalue` text,
      FULLTEXT(`searchvalue`),
      
      CONSTRAINT `fk_dsftsearch_<tablename>` 
          FOREIGN KEY (<columns>) 
      REFERENCES `<tablename>` (<columns>) 
          ON DELETE CASCADE 
          ON UPDATE CASCADE
    )
    ';

    declare proc_sqlstmt text;
    declare proc_template text default '
    CREATE OR REPLACE PROCEDURE `ft_searchproc_<tablename>`( <in_parameter> )
        MODIFIES SQL DATA
    BEGIN
        declare newvalue text;
        declare addvalue text;

        set newvalue = "";

        <main_block>

        if addvalue is not null then
          set newvalue = concat_ws(char(10),newvalue,addvalue);
        end if;


        <reference_block>

        if newvalue is not null then
            insert into `ds_ftsearch_<tablename>` (<columns>,searchvalue)
            values (<parameter_def_columns>,newvalue)
            on duplicate key update searchvalue=values(searchvalue);
        end if;



    END
    ';

    declare insert_trigger_template text default '
    CREATE OR REPLACE TRIGGER `trg_searchproc_<tablename>_ai` AFTER INSERT ON `<tablename>` FOR EACH ROW
    BEGIN
      call `ft_searchproc_<tablename>`(<trigger_columns>);
    END';

    declare update_trigger_template text default '
    CREATE OR REPLACE TRIGGER `trg_searchproc_<tablename>_au` AFTER UPDATE ON `<tablename>` FOR EACH ROW
    BEGIN
      call `ft_searchproc_<tablename>`(<trigger_columns>);
    END';

    declare refresh_searchproc text default '
    CREATE OR REPLACE PROCEDURE `refresh_searchft_<tablename>`(  )
        MODIFIES SQL DATA
    BEGIN
      for record in (
        select <columns> from `<tablename>`
      ) do
        call `ft_searchproc_<tablename>`(<trigger_columns>);
      end for;
    END';


    for x_table in (
      select 
         
        ds_searchfields.table_name,
        concat(" select concat_ws('#',",group_concat(concat('`tn`.`',ds_searchfields.column_name,'`') separator ","),") as v into addvalue from `<tablename>` tn where (<table_keycolumns>) = (<parameter_def_columns>);") main_block
      from 
        ds_searchfields
        join ds_column 
          on (ds_column.column_name,ds_column.table_name) = (ds_searchfields.column_name,ds_searchfields.table_name)
          and ds_searchfields.active=1
      where 
        ds_searchfields.table_name = in_table_name 
        or in_table_name=''
      group by 
        ds_searchfields.table_name
    ) do

      set sqlstmt = table_template;
      set sqlstmt = replace(sqlstmt,'<tablename>',x_table.table_name);

      set proc_sqlstmt = proc_template;
      set proc_sqlstmt = replace(proc_sqlstmt,'<tablename>',x_table.table_name);

      set proc_sub='';

      for defs in (
        select
            group_concat(
              if (
                  column_key like '%PRI%',

                  concat('`',column_name,'` ',column_type, if (is_nullable='NO',' not null','') )
                  ,
                  ''
              )
              order by column_name 
              separator ','
            ) column_def,


            group_concat(
              if (
                  column_key like '%PRI%',

                  concat('`',column_name,'`' )
                  ,
                  ''
              )
              order by column_name 
              separator ','
            ) columns,



            group_concat(
              if (
                  column_key like '%PRI%',

                  concat('`tn`.`',column_name,'`' )
                  ,
                  ''
              )
              order by column_name 
              separator ','
            ) tn_columns,

            group_concat(
              if (
                  column_key like '%PRI%',

                  concat('`__in__',column_name,'` ',column_type )
                  ,
                  ''
              )
              order by column_name 
              separator ','
            ) parameter_def,


            group_concat(
              if (
                  column_key like '%PRI%',

                  concat('`__in__',column_name,'`' )
                  ,
                  ''
              )
              order by column_name 
              separator ','
            ) parameter_def_columns,


            group_concat(
              if (
                  column_key like '%PRI%',

                  concat('NEW.`',column_name,'`')
                  ,
                  ''
              )
              order by column_name 
              separator ','
            ) trigger_columns
          
          from  ds_column where 
            table_name = x_table.table_name  
            and column_key like '%PRI%'
      ) do


        set sqlstmt = replace(sqlstmt,'<column_defs>',defs.column_def);
        set sqlstmt = replace(sqlstmt,'<columns>',defs.columns);


        set proc_sqlstmt = replace(proc_sqlstmt,'<in_parameter>',defs.parameter_def);
        set proc_sqlstmt = replace(proc_sqlstmt,'<main_block>',x_table.main_block);

        set proc_sqlstmt = replace(proc_sqlstmt,'<tablename>',x_table.table_name);
        set proc_sqlstmt = replace(proc_sqlstmt,'<keycolumns>',defs.columns);
        set proc_sqlstmt = replace(proc_sqlstmt,'<table_keycolumns>',defs.tn_columns);

        set proc_sqlstmt = replace(proc_sqlstmt,'<columns>',defs.columns);
        set proc_sqlstmt = replace(proc_sqlstmt,'<parameter_def_columns>',defs.parameter_def_columns);
        



          
        


          for refcdef  in (
                select 


                  referenced_table_name,

                  concat("(",group_concat(
                      concat('tn.`',referenced_column_name,'`')
                      order by column_name
                      separator ','
                  ),")") x,

                  concat("( select ",group_concat(
                      concat(' `',column_name,'`')
                      order by column_name
                      separator ','
                  )," from <tablename> tn where (<table_keycolumns>) = (<parameter_def_columns>) ) limit 1") y


                  from
                  (
                  select
                      referential_constraints.table_name,
                      referential_constraints.referenced_table_name,


                  key_column_usage.column_name,
                  key_column_usage.referenced_column_name
                      
                  from
                      (
                          select
                              *
                          from
                              information_schema.referential_constraints
                          where
                              constraint_schema = database()
                      ) referential_constraints
                      join (
                          select
                              *
                          from
                              information_schema.key_column_usage
                          where
                              information_schema.key_column_usage.constraint_schema = database()
                      ) key_column_usage on key_column_usage.table_name = referential_constraints.table_name
                      and key_column_usage.constraint_name = referential_constraints.constraint_name
                      and key_column_usage.constraint_schema = database()
                      join ds_reference_tables
                        on ds_reference_tables.constraint_name = key_column_usage.constraint_name
                        and ds_reference_tables.searchable=1
                  group by
                      referential_constraints.constraint_name,
                      referential_constraints.referenced_table_name,
                      referential_constraints.table_name,
                      key_column_usage.column_name
                  having table_name= x_table.table_name
                      
                  union
                  select
                      ds_referenced_manual.table_name,
                      ds_referenced_manual.referenced_table_name,
                      ds_referenced_manual_columns.referenced_column_name,
                        ds_referenced_manual_columns.column_name
                    
                  from
                      ds_referenced_manual
                      join ds_referenced_manual_columns on (
                          ds_referenced_manual.table_name,
                          ds_referenced_manual.referenced_table_name
                      ) = (
                          ds_referenced_manual_columns.table_name,
                          ds_referenced_manual_columns.referenced_table_name
                      )
                      join ds_reference_tables
                        on ds_reference_tables.constraint_name = concat(
                            'manual_',
                            md5(
                                concat(
                                    ds_referenced_manual.table_name,
                                    '_',
                                    ds_referenced_manual.referenced_table_name
                                )
                            )
                        )
                        and ds_reference_tables.searchable=1
                  group by
                      ds_referenced_manual.referenced_table_name,
                      ds_referenced_manual.table_name,
                      ds_referenced_manual_columns.column_name 
                  having table_name= x_table.table_name
                      

                  ) c

                  
                  group by referenced_table_name
          ) do 


            for xblock in (
              select 
          
                ds_searchfields.table_name,
                concat(" select concat_ws('#',",group_concat(concat('`tn`.`',ds_searchfields.column_name,'`') separator ","),") as v into addvalue from `",ds_column.table_name,"` tn where (",refcdef.x,") = (",refcdef.y,");") main_block
              from 
                ds_searchfields
                join ds_column 
                  on (ds_column.column_name,ds_column.table_name) = (ds_searchfields.column_name,ds_searchfields.table_name)
                  and ds_searchfields.active=1
              where 
                ds_searchfields.table_name in (
                  select 
                    reference_table_name
                  from 
                    ds_reference_tables
                  where ds_reference_tables.table_name = x_table.table_name
                    and searchable=1
                ) 
                and ds_searchfields.table_name =  refcdef.referenced_table_name
              group by 
                ds_searchfields.table_name
            ) do -- xblock



                set proc_sub=concat(proc_sub,'

                -- Mein Kommentar steht hier

                set addvalue=null;

                ',
                xblock.main_block
                ,'

                        if addvalue is not null then
                          set newvalue = concat_ws(char(10),newvalue,addvalue);
                        end if;

                '
                );

              set proc_sub = replace(proc_sub,'<tablename>',x_table.table_name);
              set proc_sub = replace(proc_sub,'<keycolumns>',defs.columns);
              set proc_sub = replace(proc_sub,'<table_keycolumns>',defs.tn_columns);
              set proc_sub = replace(proc_sub,'<parameter_def_columns>',defs.parameter_def_columns);

              




            end for; -- xblock


          end for ;


          set proc_sqlstmt = replace(proc_sqlstmt,'<main_block>',x_table.main_block);
          set proc_sqlstmt = replace(proc_sqlstmt,'<reference_block>',proc_sub);



          set insert_sqlstmt = insert_trigger_template;
          set insert_sqlstmt = replace(insert_sqlstmt,'<tablename>',x_table.table_name); 
          set insert_sqlstmt = replace(insert_sqlstmt,'<trigger_columns>',defs.trigger_columns); 


          set update_sqlstmt = update_trigger_template;
          set update_sqlstmt = replace(update_sqlstmt,'<tablename>',x_table.table_name); 
          set update_sqlstmt = replace(update_sqlstmt,'<trigger_columns>',defs.trigger_columns); 


          set refresh_sqlstmt = refresh_searchproc;
          set refresh_sqlstmt = replace(refresh_sqlstmt,'<tablename>',x_table.table_name); 
          set refresh_sqlstmt = replace(refresh_sqlstmt,'<columns>',defs.columns); 
          set refresh_sqlstmt = replace(refresh_sqlstmt,'<trigger_columns>',replace(defs.trigger_columns,'NEW.','record.')); 



          PREPARE stmt FROM sqlstmt;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;

          PREPARE stmt FROM proc_sqlstmt;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;

          PREPARE stmt FROM insert_sqlstmt;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;

          PREPARE stmt FROM update_sqlstmt;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;

          PREPARE stmt FROM refresh_sqlstmt;
          EXECUTE stmt;
          DEALLOCATE PREPARE stmt;



      end for;
    end for;


END //
