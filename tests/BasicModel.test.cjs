const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

let model;
vm.runInNewContext(readFileSync(path.join(__dirname, '../src/js/both/model/Basic.js'), 'utf8'), {
    Ext: {
        define: (_, definition) => { model = definition; },
        isEmpty: value => value == null || value === ''
    }
});

test('model resolves mixed-case field references against lowercase read data', () => {
    assert.equal(model.get.call({ data: { allowform: true } }, 'allowForm'), true);
    assert.equal(model.get.call({ data: { __table_name: 'ds', ds__allowform: true } }, 'allowForm'), true);
    assert.equal(model.get.call({ data: { __table_name: 'ds', allowform: true } }, 'ds__allowForm'), true);
});
