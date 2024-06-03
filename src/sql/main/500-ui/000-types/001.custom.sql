
delimiter ;

create or replace view view_ds_custom as
select
    concat(
        'Ext.define(',doublequote( custom_types.id ),',',
            JSON_MERGE(
                JSON_OBJECT(
                    "extend",extendsxtype_modern,
                    "alias",xtype_long_modern
                ),
                ifnull(_str.c,'{}'),
                ifnull(_int.c,'{}'),
                ifnull(_bool.c,'{}')
            ),

        ')',char(59)
    )  js
from 
    custom_types 
    left join ( select JSON_OBJECTAGG(property,val) c,id from custom_types_attributes_string group by id) _str on custom_types.id = _str.id
    left join ( select JSON_OBJECTAGG(property,val) c,id from custom_types_attributes_integer group by id) _int on custom_types.id = _int.id
    left join ( select JSON_OBJECTAGG(property,if(val=1,true,false)) c,id from custom_types_attributes_boolean group by id) _bool on custom_types.id = _bool.id

where xtype_long_modern is not null
group by custom_types.id;
