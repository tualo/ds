Ext.define('Tualo.routes.ds.RemoteQuery',{
    statics: {
        load: async function() {
            return [
                {
                    name: 'DS Remote Query',
                    path: '#ds/remotequery'
                }
            ]
        }
    }, 
    url: 'dsremotecommand/:{cmd}',
    handler: {
        action: function( values ){
            //console.log('action');
            //btoa('test')
            //atob('dGVzdA==')
            //Ext.getApplication().addView('Tualo.OnlineVote.Decryption');
            let cmd_json = JSON.parse(atob(values.cmd));
            console.log('cmd_json',cmd_json);
        },
        before: function ( values, action,cnt) {
            try{
                let cmd_json = JSON.parse(atob(values.cmd));
                console.log('before');
                action.resume();
    
            }catch(e){
                console.log(e);
                action.stop();
                Ext.Msg.alert('Fehler','Der Befehl konnte nicht ausgeführt werden.'); 
                return;       
            }
        }
    }
});