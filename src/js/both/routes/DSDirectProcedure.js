Ext.define('Tualo.routes.ds.DSDirectProcedure', {
    statics: {
        load: async function () {
            return [
                {
                    name: 'DS Run Proc direct',
                    path: '#ds-direct-procedure/:{proc}/:{id}'
                }
            ]
        }
    },
    url: 'ds-direct-procedure/:{proc}/:{id}',
    handler: {
        action: function (values) {

            let fn = async function () {

                let res = await fetch('./dsrun/' + this.param, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        list: Ext.JSON.encode([{ id: values.id }])
                    })
                });
                let json = await res.json();

                if (!json.success) {
                    Ext.toast({
                        html: json.msg,
                        title: 'Fehler',
                        align: 't',
                        iconCls: 'fa fa-warning'
                    });
                } else {
                    Ext.toast({
                        title: 'Erfolg',
                        html: json.msg,
                        align: 't',
                        iconCls: 'fa fa-check'
                    });
                }
                Ext.util.History.back();
            }

            fn();



        },
        before: function (values, action) {
            action.resume();
        }

    }
});