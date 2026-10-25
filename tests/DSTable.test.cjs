const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const { test } = require('node:test');
const vm = require('node:vm');

function setup(responses = []) {
    const calls = [];
    const context = vm.createContext({
        File,
        window: {},
        XMLHttpRequest: class {
            constructor() {
                this.headers = {};
            }
            open(method, url, async) {
                assert.equal(async, false, 'Requests must block until the response arrives');
                this.method = method;
                this.url = url;
            }
            setRequestHeader(name, value) {
                this.headers[name] = value;
            }
            send(body) {
                calls.push({
                    url: this.url, method: this.method,
                    headers: this.headers, body: JSON.parse(body)
                });
                const result = responses.shift();
                if (result instanceof Error) throw result;
                if (result && Object.hasOwn(result, 'responseText')) {
                    Object.assign(this, result);
                } else {
                    this.status = 200;
                    this.statusText = 'OK';
                    this.responseText = JSON.stringify(result);
                }
            }
        },
        Ext: {
            define(name, definition) {
                function DSTable(...args) {
                    definition.constructor.apply(this, args);
                }
                Object.assign(DSTable.prototype, definition);
                Object.assign(DSTable, definition.statics);
                context.Tualo = { DSTable };
            }
        }
    });
    vm.runInContext(readFileSync(
        require('node:path').join(__dirname, '../src/js/both/DSTable.js'), 'utf8'
    ), context);
    return { context, calls, Table: context.Tualo.DSTable };
}

// Normalize objects created in the separate browser-like VM realm.
function plain(value) {
    return JSON.parse(JSON.stringify(value));
}

test('fluent API sends synchronous PHP read parameters and isolates instances', () => {
    const { Table, context, calls } = setup([{ success: true, data: [{ id: 1 }] }]);
    const table = new Table('kunden');
    assert.equal(context.window.dstable, Table);
    assert.equal(table.queried(), false);
    assert.equal(table.empty(), true);
    assert.equal(table.f('aktiv', 'eq', true).s('name', 'ASC').start(5).limit(10), table);
    assert.deepEqual(plain(table.g()), [{ id: 1 }]);
    assert.equal(table.queried(), true);
    assert.equal(table.empty(), false);
    assert.deepEqual(plain(calls[0]), {
        url: './ds/kunden/read',
        method: 'POST',
        headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
        body: {
            start: 5, shortfieldnames: 1, limit: 10,
            filter: [{ property: 'aktiv', operator: 'eq', value: true }],
            sort: [{ property: 'name', direction: 'ASC' }]
        }
    });
    const other = new Table('andere');
    assert.equal(other.queried(), false);
    assert.equal(other._filter.length, 0);
    assert.equal(other._sorter.length, 0);
    assert.equal(other._limit, 100000);
});

test('get always requests and supports keyed records, values, nulls and duplicate keys', () => {
    const rows = [{ id: 'a', name: 'first' }, { id: 'a', name: 'last' }, { id: 'b', name: null }];
    const { Table, calls } = setup(Array.from({ length: 3 }, () => ({ success: true, data: rows })));
    const table = new Table();
    assert.deepEqual(plain(table.get('id')), { a: rows[1], b: rows[2] });
    assert.deepEqual(plain(table.get('id', 'name')), { a: 'last', b: rows[2] });
    assert.ok(Array.isArray(table.get()));
    assert.equal(calls.length, 3);
});

test('hash keys cannot modify the result prototype', () => {
    const row = { id: '__proto__', value: 'safe' };
    const { Table } = setup([{ success: true, data: [row] }]);
    const result = new Table().get('id', 'value');
    assert.equal(Object.prototype.hasOwnProperty.call(result, '__proto__'), true);
    assert.equal(result.__proto__, 'safe');
});

test('single accessors cache data and preserve falsy values', () => {
    const row = { id: 1, zero: 0, bool: false, text: '', nil: null };
    const { Table, calls } = setup([{ success: true, data: [row] }]);
    const table = new Table();
    assert.deepEqual(plain(table.getSingle()), row);
    for (const [column, expected] of Object.entries({ zero: 0, bool: false, text: '', nil: false, absent: false })) {
        assert.equal(table.getSingleValue(column), expected);
    }
    assert.equal(calls.length, 1);
});

test('query changes invalidate cached rows and read aliases return the instance', () => {
    const { Table, calls } = setup(Array.from({ length: 6 }, () => ({ success: true, data: [] })));
    const table = new Table('kunden');
    assert.equal(table.r(), table);
    for (const change of [
        () => table.filter('id', 'eq', 1),
        () => table.sort('id', 'DESC'),
        () => table.start(1),
        () => table.limit(1),
        () => table.t('neu')
    ]) {
        change();
        assert.equal(table.queried(), false);
        assert.deepEqual(plain(table.getSingle()), []);
        assert.equal(table.getSingleValue('id'), false);
        assert.equal(table.empty(), true);
    }
    assert.equal(calls.length, 6);
    assert.equal(calls[0].url, './ds/kunden/read');
    assert.equal(calls[5].url, './ds/neu/read');
});

test('writes return directly, use bare record arrays and invalidate the cache', () => {
    const response = { success: true, warnings: ['notice'], moreResults: [[{ id: 1 }]], data: [{ id: 1 }] };
    const { Table, calls } = setup([
        { success: true, data: [{ id: 0 }] }, response, response, { success: true }
    ]);
    const table = new Table('kunden');
    assert.equal(table.read(), table);
    assert.deepEqual(plain(table.insert({ id: 1 })), response);
    assert.equal(table.queried(), false);
    assert.equal(table.empty(), true);
    assert.deepEqual(plain(table.update([{ id: 2 }, { id: 3 }])), response);
    assert.deepEqual(plain(table.delete({ id: 4 })), { success: true });
    assert.deepEqual(calls.slice(1).map(call => [call.url, call.body]), [
        ['./ds/kunden/create', [{ id: 1 }]],
        ['./ds/kunden/update', [{ id: 2 }, { id: 3 }]],
        ['./ds/kunden/delete', [{ id: 4 }]]
    ]);
    assert.deepEqual(plain(table.readWarnings()), ['notice', 'notice']);
    assert.deepEqual(plain(table.readMoreResults()), [[{ id: 1 }], [{ id: 1 }]]);
});

test('backend failures throw, expose diagnostics and recover on the next request', () => {
    const { Table } = setup([
        { success: false, msg: 'Denied', warnings: ['detail'] },
        { success: true, data: [] }
    ]);
    const table = new Table();
    assert.throws(() => table.get(), /Denied/);
    assert.equal(table.error(), true);
    assert.equal(table.errorMessage(), 'Denied');
    assert.equal(table.queried(), false);
    assert.deepEqual(plain(table.warnings()), ['detail']);
    table.read();
    assert.equal(table.error(), false);
    assert.equal(table.errorMessage(), '');
});

test('HTTP, network, malformed JSON and malformed data throw synchronously', () => {
    const responses = [
        { status: 403, responseText: '{"msg":"Forbidden"}' },
        { status: 503, responseText: '<html>Unavailable</html>' },
        { status: 200, responseText: 'not json' },
        { status: 200, responseText: 'null' },
        { msg: 'Missing success' },
        { success: true, data: {} }
    ];
    const { Table } = setup([
        ...responses,
        { status: 403, responseText: '{"msg":"Forbidden"}' },
        { status: 500, responseText: 'null' },
        new Error('Offline'),
        new Error('Synchronous XHR disabled')
    ]);
    const table = new Table();
    for (let index = 0; index < responses.length; index++) {
        assert.throws(() => table.read());
        assert.equal(table.error(), true);
        assert.notEqual(table.errorMessage(), '');
        assert.equal(table.queried(), false);
    }
    assert.throws(() => table.read(), error => error.status === 403 && error.message === 'Forbidden');
    assert.throws(() => table.read(), error => error.status === 500 && /HTTP 500/.test(error.message));
    assert.throws(() => table.read(), /Offline/);
    assert.equal(table.errorMessage(), 'Offline');
    assert.throws(() => table.read(), /Synchronous XHR disabled/);
    assert.equal(table.errorMessage(), 'Synchronous XHR disabled');
});

test('a failed refresh does not retain previously cached records', () => {
    const { Table, calls } = setup([
        { success: true, data: [{ id: 1 }] },
        new Error('Offline'),
        { success: true, data: [{ id: 2 }] }
    ]);
    const table = new Table();
    table.read();
    assert.throws(() => table.get(), /Offline/);
    assert.equal(table.empty(), true);
    assert.equal(table.queried(), false);
    assert.deepEqual(plain(table.getSingle()), { id: 2 });
    assert.equal(calls.length, 3);
});

test('record helpers and unsupported options never silently drop input', () => {
    const { Table, calls } = setup();
    const table = new Table();
    assert.deepEqual(plain(table.prepareRecords({ id: 1 })), [{ id: 1 }]);
    assert.equal(table.differentRows([]), false);
    assert.equal(table.differentRows([{ a: 1 }, { a: 2 }]), false);
    assert.equal(table.differentRows([{ a: 1 }, { b: 2 }]), true);
    assert.equal(table.differentRows([{ a: null }]), true);
    for (const value of [null, 'record', 1, [null], [[1]]]) {
        assert.throws(() => table.insert(value), /Records must/);
    }
    assert.throws(() => table.insert({ id: 1 }, { update: false }), /do not support write options/);
    assert.equal(table.error(), true);
    assert.equal(calls.length, 0);
    assert.throws(() => table.t('../invalid'), /Invalid DS table/);
    assert.throws(() => table.start(-1), /Start/);
    assert.throws(() => table.limit(0), /Limit/);
});

test('upload helper reads File objects or named file inputs and preserves the record', async () => {
    const { Table, context } = setup();
    const file = new File(['abc'], 'test.txt', { type: 'text/plain' });
    context.FileReader = class {
        readAsDataURL(file) {
            file.arrayBuffer().then(buffer => {
                this.result = 'data:' + file.type + ';base64,' + Buffer.from(buffer).toString('base64');
                this.onload();
            });
        }
    };
    context.document = { getElementsByName: name => name === 'upload' ? [{ files: [file] }] : [] };
    const table = new Table();
    const record = { id: 42 };
    for (const input of [file, 'upload']) {
        assert.deepEqual(plain(await table.appendFileFromUploadForm(record, input)), {
            id: 42, __file_data: 'data:text/plain;base64,YWJj', __file_id: '',
            __file_name: 'test.txt', __file_size: 3, __file_type: 'text/plain', error: 0
        });
    }
    assert.deepEqual(record, { id: 42 });
    await assert.rejects(table.appendFileFromUploadForm(record, 'missing'), /No upload file/);
    context.FileReader = class {
        readAsDataURL() {
            this.error = new Error('Read failed');
            this.onerror();
        }
    };
    await assert.rejects(table.appendFileFromUploadForm(record, file), /Read failed/);
});
