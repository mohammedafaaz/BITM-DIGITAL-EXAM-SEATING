# Deploying the BITM Seating System — free, production

This package has two parts:
- `seating.html` — the whole app (one file, no build step)
- `schema.sql` — the database schema for Supabase

Total cost: **$0**. Supabase's free tier and any of the static hosts below are
free for a tool at this scale (a few hundred students, a handful of admins).

---

## 1. Create a free Supabase project (~3 min)

1. Go to https://supabase.com → sign up (GitHub login is fastest) → **New project**.
2. Pick any name (e.g. `bitm-seating`), set a database password (you won't need
   it again — save it somewhere anyway), pick the region closest to you, and
   create the project. It takes a minute or two to provision.
3. Once it's ready, open **SQL Editor** in the left sidebar → **New query**.
4. Paste the entire contents of `schema.sql` (included in this zip) and click
   **Run**. You should see "Success. No rows returned."
5. Go to **Project Settings → API**. You'll need two values from this page:
   - **Project URL** (looks like `https://xxxxxxxxxxxx.supabase.co`)
   - **anon public** key (a long string under "Project API keys")

Keep this tab open — you'll paste both into the HTML file next.

---

## 2. Configure the app

1. Open `seating.html` in any text editor.
2. Near the top of the `<script>` block, find:
   ```js
   var SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
   var SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
   ```
3. Replace both placeholder strings with the **Project URL** and **anon
   public** key from step 1. Save the file.

That's it for configuration — there's no build step, no `npm install`, no
environment variable system. It's a static file that talks to Supabase
directly from the browser.

---

## 3. Host it for free

Pick any one of these. They all work the same way for a single static HTML
file — drag-and-drop or connect a repo, no build command needed.

### Option A — Netlify (easiest, no account setup beyond signup)
1. Go to https://app.netlify.com/drop
2. Drag `seating.html` onto the page (rename it to `index.html` first, or
   Netlify will serve it at `/seating.html` instead of `/`).
3. You get a live URL immediately (e.g. `random-name.netlify.app`). You can
   rename the site or add a custom domain for free in **Site settings**.

### Option B — Vercel
1. Go to https://vercel.com → sign up → **Add New → Project**.
2. If you don't want to use GitHub, use `vercel` CLI instead:
   ```
   npm i -g vercel
   cd path/to/folder-with-index.html
   vercel --prod
   ```
3. Same note: name the file `index.html` so it's served at the root URL.

### Option C — GitHub Pages (good if you want it in a repo anyway)
1. Create a new GitHub repo, add `seating.html` renamed to `index.html`.
2. Repo → **Settings → Pages** → Source: "Deploy from a branch" → branch
   `main`, folder `/ (root)` → Save.
3. Your site goes live at `https://<username>.github.io/<repo-name>/`.

### Option D — Cloudflare Pages
1. https://pages.cloudflare.com → **Create a project → Upload assets**.
2. Upload the folder, deploy. Free custom domain support too.

Any of these is genuinely production-grade for this use case — global CDN,
HTTPS by default, no server to maintain.

---

## 4. Test before sharing the link

Open your deployed URL and check, in order:
1. Home page loads (no "Backend not configured" message — if you see that,
   double check step 2).
2. Log in as admin with `Adminofbitm@2026`.
3. Add a room, add a course, upload a sample CSV, generate seating.
4. Refresh the page — your room/course should still be there (confirms
   Supabase is actually persisting data, not just working in-memory).
5. Open the site on your phone and repeat steps 2–4, since that's the
   environment that was flaky before.
6. Log out, then use the student "Find my seat" flow with a USN you just
   seated.

---

## Notes and honest caveats

- **Security model.** The admin password is checked in the browser, not on a
  server — this matches how the app worked before. Anyone with your Supabase
  anon key (which is visible in the page source, by design for this kind of
  key) could technically write to the database directly, bypassing the admin
  screen. For an internal exam-seating tool that's a reasonable trade-off,
  but it is not real access control. If you ever need that, it means adding
  server-side auth (e.g. Supabase Auth + RLS keyed to a logged-in admin
  user), which is a bigger change than this deployment.
- **Changing the admin password.** It's hardcoded in `seating.html` as
  `ADMIN_PASSWORD`. To change it, edit that line and redeploy.
- **Free tier limits.** Supabase's free plan includes 500MB database storage
  and a generous request allowance — this app's data (room/course/seating
  records) is tiny (kilobytes to low megabytes even at hundreds of students),
  so you won't come close. Static hosts (Netlify/Vercel/GitHub Pages/
  Cloudflare Pages) are free for bandwidth at this scale too.
- **Backups.** Supabase → **Database → Backups** has automatic daily backups
  even on the free tier (short retention). For anything you can't afford to
  lose, also periodically export via the app's own CSV download on the
  seating results tab.
