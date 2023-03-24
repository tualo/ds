Ext.define('Tualo.DS.Panel', {
    extend: "Ext.panel.Panel",
    controller: 'dspanelcontroller',
    viewModel: {
        data: {
            currentRecord: null
        }
    },
})