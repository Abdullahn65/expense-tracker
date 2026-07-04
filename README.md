# Expense Tracker

A single-file personal expense tracker. The entire app — markup, styles, and JavaScript — lives in `index.html`. No build step, no bundler, no server of its own.

## Stack

- **Frontend**: vanilla JS + [Chart.js 4.4.0](https://www.chartjs.org/) (CDN)
- **Backend**: [Supabase](https://supabase.com/) — email/password auth and Postgres tables (`expenses`, `income`, `budgets`, `expense_templates`, `income_templates`)
- **AI categorization (optional)**: OpenAI Chat Completions, called directly from the browser with a key you supply

## Running

Open `index.html` in a browser (or serve it: `python3 -m http.server`). Sign in or create an account on the login screen.

Per-user settings (payment methods, enabled CSV templates, the OpenAI key, category-learning data) are stored in the browser's `localStorage`; transactional data lives in Supabase.

## Testing

```
node test/run-tests.js
```

Unit tests cover the pure logic (HTML escaping, date parsing, CSV category mapping, fuzzy search, duplicate detection) by extracting the inline script and running it in a sandbox.

## Security notes

- **Row Level Security is load-bearing.** The Supabase anon key in `index.html` is public by design; every table **must** have RLS enabled with policies scoping rows to `auth.uid()`. Without RLS, any visitor can read/write all users' data. Verify in the Supabase dashboard: Authentication → Policies. Note that `saveBudgets()` deletes budgets with a broad filter and relies entirely on RLS to scope the deletion to the current user.
- **User data is HTML-escaped before rendering.** All `innerHTML` sinks pass user/CSV-derived strings through `escapeHtml()` / `escapeJsString()` (defined near the top of the script). If you add a new render function, do the same — imported bank CSVs are untrusted input.
- **The OpenAI key lives in `localStorage`** and is sent from the browser. Use a low-limit, revocable key. For anything beyond personal use, proxy OpenAI calls through a backend instead.
- CSV export quotes all text fields and prefixes `= + - @` to prevent spreadsheet formula injection.
