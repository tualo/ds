Ext.define('Tualo.routes.ds.PUGExport', {
    statics: {
        load: async function () {
            return [
                {
                    name: 'PUGExport item',
                    path: '#pugexport/:{id}'
                }
            ]
        }
    },
    url: 'pugexport/:{id}',
    handler: {
        action: function (values) {

            let fn = async function () {


                let res = await fetch('./pugtemplates/export/' + values.id, {
                    method: "get",
                })
                let json = await res.json();

                window.open('./tualo/download/' + json.file, '_blank')
                // Tualo.Ajax.download(json);
                Ext.util.History.back();
            }

            fn();

            Ext.toast({
                html: 'Die Datei wird abgerufen',
                title: values.id,
                align: 't',
                iconCls: 'fa fa-check'
            });

        },
        before: function (values, action) {
            action.resume();
        }

    }
});