delimiter ;

create or replace view view_ds_colorformula as

    with tn as (
        select table_name from ds_coloring_formulas
    ),
    emptyData as (
        select 
            'ednjhwebhdwe' as table_name,
            JSON_ARRAY() as f
    ),
    fm as (
        select table_name,
            JSON_ARRAYAGG(JSON_OBJECT('formula', formula, 'css_class', css_class)) as f
        from ds_coloring_formulas
        group by table_name
    ),
    fmx as (
        select table_name,f
        from fm
        union 
        select table_name,f
        from emptyData
    ),
    d as (
        select
            ifnull(JSON_OBJECTAGG(fmx.table_name, fmx.f) ,JSON_MERGE('{}','{}')) as obj
        from
            tn
            join fmx on tn.table_name = fmx.table_name
    )


select 
    concat(  'Tualo/DataSets/color/Formulas.js') filename,
    'ds' table_name,
    concat(
        'Ext.define(',doublequote('Tualo.ds_colors.Formulas'),',',
            JSON_OBJECT(
                'singleton', 1=1,
                'formulas', d.obj
            )
    ) as js
from 
    (select * from d)
    d;
    