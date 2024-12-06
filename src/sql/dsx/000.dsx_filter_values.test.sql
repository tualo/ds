


set @request = '
{
    "replaced": 1,
    "count": 1,
    "page": 1,
    "limit": 50,
    "rownumber": 1,
    "returnfields": ["kundennummer","plz"],
    "sort": [
        {
            "property":"adressen__plz",
            "direction":"desc"
        }
    ],
    "tablename": "adressen",
    "filter":[
        {
                "operator":"eq",
                "value":"07545",
                "property":"adressen__plz"
        },
        {       "operator":"like",
                "value":"%12%",
                "property":"__id"
        },
        {
            "operator": "or term",
            "value": [
                {
                    "operator":"like",
                    "value":"%Test%",
                    "property":"adressen__name"
                },
                {   
                    "operator":"eq",
                    "value":"Muster",
                    "property":"adressen__firma"
                }
            ] 
        }
        
    ]
}
' //


 select dsx_filter_values(@request,'filter') //

/*
    select
        '' `property`,
        '' `operator`,
        concat( 
            '(',
            dsx_filter_values( 
                JSON_OBJECT(
                    "tablename",json_extract(@request,'$.tablename'),
                    "concat_by", ifnull(jtx.concat_by,'and'),
                    "filter", JSON_MERGE(JSON_ARRAY(),`filter`)
                ) 
            ),
            ')'
        ) `value`
    from
        JSON_TABLE(json_extract(@request,'$.filter'), '$[*]'  COLUMNS (
            `concat_by` longtext path '$.concat_by',
            `filter`    JSON path '$.filter'
        ) 
    ) as jtx
    where jtx.filter!='NULL' -- keep in mind, JSON TYPE NULL

//

*/

-- select dsx_filter_term('adressen',JSON_EXTRACT(@request,'$.filter[0]')) //

