Ext.define('Tualo.ds.lazy.test.Navigation', {
    extend: 'Ext.panel.Panel',
    layout: 'card',
    alias: 'widget.dstestnavigation',
    requires: [
        'Tualo.ds.lazy.test.BreadCrumbs'
    ],
    /*
    tbar: [{
        xtype: 'tualo_navigation_breadcrumbs',
        items: [{
            xtype: 'component',
            html: 'Navigation:',
            style: {
                'margin-left': '10px',
                'margin-right': '10px'
            }
        }]
    }],
    */
    items:[
        {
            xtype: 'panel',
            html: 'Test'
        }
    ]
});