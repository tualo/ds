Ext.define('Tualo.routes.ds.DSFill',{
    statics: {
        load: async function() {
            return [
                {
                    name: 'DSFill item',
                    path: '#dsfill/:{table_name}'
                }
            ]
        }
    }, 
    url: 'dsfill/:{table_name}',
    handler: {
        action: function( values ){

            let fn = async function(){
                const formData = new FormData();
                formData.append("table_name",values.table_name);

                let res = await fetch('./dssetup/ds-update',{
                    method: "POST",
                    body: formData,
                    }).then((res)=>{ return res.json() });
                Ext.util.History.back();
            }

            fn();

            Ext.toast({
                html: 'Die Metainformationen werden aufgefrischt',
                title: values.table_name,
                align: 't',
                iconCls: 'fa fa-check'
            });

        },
        before: function ( values, action) {
            action.resume();
        }

    }
});