#!/usr/bin/env node
// Lightweight unit tests for the pure logic inside index.html.
// The app is a single HTML file, so we extract the inline <script>, evaluate it
// in a sandbox with browser stubs, and test the pure functions directly.
// Run with: node test/run-tests.js

const fs = require('fs');
const path = require('path');
const vm = require('vm');

const html = fs.readFileSync(path.join(__dirname, '..', 'index.html'), 'utf8');
const match = html.match(/<script>\n([\s\S]*)\n\s*<\/script>\s*<\/body>/);
if (!match) {
    console.error('FATAL: could not extract inline script from index.html');
    process.exit(1);
}

// Minimal browser stubs so top-level statements run without a DOM
const storage = {};
const sandbox = {
    console,
    setTimeout: () => 0,
    clearTimeout: () => {},
    alert: () => {},
    confirm: () => true,
    prompt: () => null,
    fetch: () => Promise.reject(new Error('no network in tests')),
    localStorage: {
        getItem: (k) => (k in storage ? storage[k] : null),
        setItem: (k, v) => { storage[k] = String(v); },
        removeItem: (k) => { delete storage[k]; },
    },
    document: {
        addEventListener: () => {},
        getElementById: () => null,
        querySelectorAll: () => [],
        createElement: () => ({ style: {}, appendChild: () => {} }),
    },
    window: { addEventListener: () => {} },
    CanvasRenderingContext2D: function () {},
    supabase: { createClient: () => ({ auth: {}, from: () => ({}) }) },
};
sandbox.window.localStorage = sandbox.localStorage;
vm.createContext(sandbox);
vm.runInContext(match[1], sandbox, { filename: 'index.html<script>' });

let passed = 0;
let failed = 0;
function test(name, fn) {
    try {
        fn();
        passed++;
        console.log(`  ok - ${name}`);
    } catch (err) {
        failed++;
        console.error(`  FAIL - ${name}: ${err.message}`);
    }
}
function eq(actual, expected) {
    const a = JSON.stringify(actual);
    const e = JSON.stringify(expected);
    if (a !== e) throw new Error(`expected ${e}, got ${a}`);
}

const s = sandbox;

console.log('escapeHtml / escapeJsString');
test('escapes HTML metacharacters', () =>
    eq(s.escapeHtml('<img src=x onerror="alert(1)">'), '&lt;img src=x onerror=&quot;alert(1)&quot;&gt;'));
test('escapes ampersand and quotes', () =>
    eq(s.escapeHtml(`Tom & Jerry's "show"`), 'Tom &amp; Jerry&#39;s &quot;show&quot;'));
test('handles null/undefined', () => { eq(s.escapeHtml(null), ''); eq(s.escapeHtml(undefined), ''); });
test('escapeJsString neutralizes quote breakout', () =>
    eq(s.escapeJsString("x'); steal(); ('"), "x\\&#39;); steal(); (\\&#39;"));

console.log('highlightMatch');
test('escapes text with no match', () =>
    eq(s.highlightMatch('<b>bold</b>', 'zzz'), '&lt;b&gt;bold&lt;/b&gt;'));
test('wraps match in highlight span, escaped', () =>
    eq(s.highlightMatch('<x>Costco run', 'costco'), '&lt;x&gt;<span class="search-highlight">Costco</span> run'));

console.log('date helpers');
test('parseLocalDate parses as local date', () => {
    const d = s.parseLocalDate('2025-11-01');
    eq([d.getFullYear(), d.getMonth(), d.getDate()], [2025, 10, 1]);
});
test('formatDateForInput handles MM/DD/YYYY', () => eq(s.formatDateForInput('3/7/2025'), '2025-03-07'));
test('formatDateForInput handles 2-digit years', () => eq(s.formatDateForInput('12/31/24'), '2024-12-31'));
test('formatDateForInput passes through ISO dates', () => eq(s.formatDateForInput('2025-01-15'), '2025-01-15'));

console.log('categorization');
test('mapCategoryFromCSV maps known categories', () => {
    eq(s.mapCategoryFromCSV('Restaurants'), 'Dining Out');
    eq(s.mapCategoryFromCSV('Gas Station'), 'Transportation');
    eq(s.mapCategoryFromCSV(''), 'Other');
    eq(s.mapCategoryFromCSV('Cryptid Sightings'), 'Other');
});
test('suggestCategoryLocal keyword fallback', () =>
    eq(s.suggestCategoryLocal('Starbucks coffee', ''), 'Dining Out'));
test('suggestCategoryLocal Fidelity heuristic', () => {
    eq(s.suggestCategoryLocal('FID BKG SVC LLC MONEYLINE PPD ID: 123', ''), 'Investment Subscription');
    eq(s.suggestCategoryLocal('FIDELITY TRANSFER', ''), 'Investments');
});

console.log('fuzzy search');
test('levenshtein distance', () => { eq(s.levenshtein('kitten', 'sitting'), 3); eq(s.levenshtein('abc', 'abc'), 0); });
test('fuzzyMatch exact substring', () => eq(s.fuzzyMatch('cost', 'Costco Wholesale'), { match: true, exact: true }));
test('fuzzyMatch tolerates typo', () => eq(s.fuzzyMatch('costko', 'Costco Wholesale').match, true));
test('fuzzyMatch rejects unrelated', () => eq(s.fuzzyMatch('netflix', 'Costco Wholesale').match, false));

console.log('duplicates');
test('generateExpenseHash is stable and truncates description', () => {
    eq(s.generateExpenseHash('2025-01-01', 'a'.repeat(60), 12.5),
       `2025-01-01|${'a'.repeat(30)}|12.5`);
});
test('isDuplicateExpense detects same hash', () => {
    // `expenses` is a top-level `let`, reachable only from code run in the same context
    const run = (code) => vm.runInContext(code, sandbox);
    run(`expenses = [{ date: '2025-01-01', description: 'Coffee', amount: 4.5 }]`);
    eq(s.isDuplicateExpense({ date: '2025-01-01', description: 'Coffee', amount: 4.5 }), true);
    eq(s.isDuplicateExpense({ date: '2025-01-02', description: 'Coffee', amount: 4.5 }), false);
    run('expenses = []');
});

console.log(`\n${passed} passed, ${failed} failed`);
process.exit(failed > 0 ? 1 : 0);
