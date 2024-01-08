Ext.define('Tualo.ds.lazy.dashboard.DSChart', {
    requires: [
        // 'Ext.chart.CartesianChart'
    ],
    extend: 'Ext.dashboard.Part',
    alias: 'part.tualodashboard_chart',
    createView: function(config) {
        let me=this, view = this.callParent([config]);
        
        
        if (view._partConfig && view._partConfig.addConfiguration){
            view.title = view._partConfig.addConfiguration.title;
            view.items = [ view._partConfig.addConfiguration.items ];

        }
    
        return view;
    },
    config:{
        addConfiguration: true,
    },

    viewTemplate: {
        layout: 'fit',
        title: 'Dashboard-Chart',
        
    }
})