const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const test = require('node:test');
const vm = require('node:vm');

function controller(toolkit, panelForm) {
    let definition;
    const app = { addView: () => panelForm };
    vm.runInNewContext(fs.readFileSync(path.join(__dirname, '../src/js', toolkit, 'ds/Controller.js'), 'utf8'), {
        Ext: {
            define: (_, value) => { definition = value; },
            isEmpty: value => value == null || value === '',
            ClassManager: { getByAlias: () => ({ $className: 'Form' }) },
            getApplication: () => app
        },
        console: { log() {} }
    });
    return definition;
}

function makeForm(toolkit, tabs) {
    let active = tabs[tabs.length - 1];
    const calls = [];
    const tabpanel = {
        items: { each: fn => { for (const tab of tabs) if (fn(tab) === false) break; } },
        getActiveTab: () => active,
        getActiveItem: () => active,
        setActiveTab: tab => { active = tab; calls.push('tab'); },
        setActiveItem: tab => { active = tab; calls.push('tab'); }
    };
    const form = {
        items: { getAt: () => tabpanel },
        loadRecord: () => calls.push('load')
    };
    return { form, calls, active: () => active };
}

for (const toolkit of ['classic', 'modern']) {
    test(toolkit + ' activates the first form tab only when configured', () => {
        for (const enabled of [0, 1, '1']) {
            const tabs = [{ referencedList: true }, { name: 'first' }, { name: 'last' }];
            const fixture = makeForm(toolkit, tabs);
            const definition = controller(toolkit);
            const values = { table_name: 'example', formOnDoubleClick: true, formOnDoubleClickFirstTab: enabled };
            const model = { get: key => values[key], set: (key, value) => { values[key] = value; } };
            const scope = {
                ...definition,
                getViewModel: () => model,
                getView: () => ({ getComponent: () => fixture.form }),
                getStore: () => ({}),
                setViewType: () => fixture.calls.push('open')
            };
            definition.onItemDblClick.call(scope, null, { id: 1 });
            assert.equal(fixture.active(), enabled == 1 ? tabs[1] : tabs[2]);
            assert.deepEqual(fixture.calls, enabled == 1 ? ['load', 'tab', 'open'] : ['load', 'open']);
        }
    });
}

test('classic preserves disabled form-on-double-click behavior', () => {
    const tabs = [{ name: 'first' }, { name: 'last' }];
    const fixture = makeForm('classic', tabs);
    const definition = controller('classic');
    const values = { table_name: 'example', formOnDoubleClick: false, formOnDoubleClickFirstTab: 1 };
    const scope = {
        ...definition,
        getViewModel: () => ({ get: key => values[key], set() {} }),
        getView: () => ({ getComponent: () => fixture.form }),
        getStore: () => ({}),
        setViewType: () => fixture.calls.push('open')
    };
    definition.onItemDblClick.call(scope, null, { id: 1 });
    assert.equal(fixture.active(), tabs[1]);
    assert.deepEqual(fixture.calls, ['load']);
});

test('classic selects the first tab in a separately opened form', () => {
    const tabs = [{ name: 'first' }, { name: 'last' }];
    const fixture = makeForm('classic', tabs);
    const definition = controller('classic', fixture.form);
    const values = { table_name: 'example', formToPanel: true, formXType: 'dsform_example', formOnDoubleClickFirstTab: 1 };
    const scope = {
        ...definition,
        getViewModel: () => ({ get: key => values[key] }),
        getView: () => ({ getComponent: () => null }),
        getStore: () => ({})
    };
    definition.onItemDblClick.call(scope, null, { id: 1 });
    assert.equal(fixture.active(), tabs[0]);
    assert.deepEqual(fixture.calls, ['load', 'tab']);
});

test('ordinary selection changes do not switch the modern form tab', () => {
    const tabs = [{ name: 'first' }, { name: 'last' }];
    const fixture = makeForm('modern', tabs);
    const definition = controller('modern');
    const scope = {
        ...definition,
        getViewModel: () => ({ get: () => 1, set() {} }),
        getView: () => ({ getComponent: () => fixture.form }),
        getStore: () => ({})
    };
    definition.onListSelectionChange.call(scope, { getSelection: () => [{ id: 1 }] });
    assert.equal(fixture.active(), tabs[1]);
    assert.deepEqual(fixture.calls, ['load']);
});

test('a custom form without a tab panel is left unchanged', () => {
    for (const toolkit of ['classic', 'modern']) {
        const definition = controller(toolkit);
        assert.doesNotThrow(() => definition.selectFirstFormTab({}));
        assert.doesNotThrow(() => definition.selectFirstFormTab({ items: { getAt: () => null } }));
    }
});
