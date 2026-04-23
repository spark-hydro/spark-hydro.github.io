# Research Report: Current Architecture and Behavior of `spark-hydro.github.io`

## 1. Executive summary

This repository is a **Hugo** static site that uses a **Git submodule theme** (`themes/careercanvas`) and a **Tailwind/PostCSS asset pipeline**. The homepage is assembled by a small number of theme templates, and most front-page sections are driven by markdown files in `content/en/`.

The codebase is already partially transformed from a personal portfolio into an iHydro-branded research-group site, but it is still in a **hybrid state**:

- the site title and some core English hero text have been changed to **iHydro M&D**,
- the homepage still renders the old **personal portfolio sections** (`about`, `skills`, `experience`, `technical`, `contact`) in a hard-coded order,
- multiple configuration values, multilingual strings, and content files still contain **template/personal-site leftovers**,
- the theme behavior currently includes **random color palette selection on every refresh**,
- and the deployed site visible at `https://spark-hydro.github.io/` appears to be a **different site stack/content set** than the repository currently under review.

So the repo is not a clean research-lab website yet. It is a Hugo/Tailwind portfolio codebase being adapted into one.

---

## 2. Evidence reviewed

I reviewed the repository structure, key configuration, theme templates, content files, build scripts, and selected live-site output.

### Core repository structure observed

- Root repo contains Hugo config, content, Tailwind/PostCSS config, build scripts, and deployment config.
- The theme lives in `themes/careercanvas` and is referenced as a **submodule**, not fully owned inline in the main repo.
- English homepage content lives mainly in:
  - `content/en/about.md`
  - `content/en/contact.md`
  - `content/en/experience.md`
  - `content/en/skills.md`
  - `content/en/technical.md`
- Section pages for the research-group conversion are already present:
  - `content/en/research/_index.md`
  - `content/en/team/_index.md`
  - `content/en/research/*.md`

---

## 3. High-level architecture

## 3.1 Stack

The current codebase is built from these main pieces:

1. **Hugo** for site generation.
2. **Tailwind CSS** and **PostCSS** for styling.
3. **A custom theme** named `careercanvas`.
4. **JavaScript enhancement scripts** for:
   - random theme colors,
   - optional Pexels hero backgrounds,
   - section fade-in,
   - mobile menu behavior.
5. **Vercel build config** in the repo, even though the public site URL is GitHub Pages based.

## 3.2 Theme ownership model

The theme is referenced through `.gitmodules` and points to an external repository:

- `themes/careercanvas` → `https://github.com/felipecordero/careercanvas.git`

This is one of the most important implementation details in the whole repo because it changes how maintenance works:

- editing theme files locally is possible,
- but long-term theme changes are safest when tracked intentionally,
- and submodule sync/update issues can easily create deployment drift,
- especially if local changes are not committed in the theme repo or if the submodule pointer is not updated correctly.

This also means your website is not fully self-contained from a repository-maintenance perspective.

---

## 4. Rendering flow: how the site actually works

## 4.1 Root config bootstraps Hugo

`config.toml` defines:

- `baseURL = "https://spark-hydro.github.io/"`
- `theme = "careercanvas"`
- default content language = English
- multilingual language blocks for English, Spanish, and French
- site-wide params such as site name, author, social links, Pexels key, and dynamic color palettes

This file is doing much more than basic Hugo setup. It is currently the control center for:

- site identity,
- hero text,
- lab branding,
- social links,
- random palette configuration,
- Pexels image query configuration,
- language-specific hero text,
- and contact/Calendly information.

## 4.2 Base template composition

The base layout is in:

- `themes/careercanvas/layouts/_default/baseof.html`

Its job is to assemble the site frame.

It includes, in this order:

1. `head.html`
2. `color-variables.html`
3. CSS pipeline using Hugo resources + PostCSS
4. `nav.html`
5. the page content block
6. `footer.html`
7. JavaScript resources:
   - `scripts.js`
   - `gsap-animations.js`
   - `pexels-background.js`
   - `dynamic-colors.js`
8. `pexels-config.html`
9. `color-config.html`

### Important consequence

Even if a page does not obviously need background randomization or dynamic accent colors, those scripts are still loaded globally from the base template. So the random color behavior is not local to the hero section. It is injected site-wide.

## 4.3 Homepage assembly

The homepage layout is:

- `themes/careercanvas/layouts/_default/index.html`

This file is extremely important because the homepage sections are **hard-coded** in sequence:

1. hero
2. about
3. skills
4. experience
5. technical
6. testimonials
7. contact

There is **no toggle system** here yet.

That means:

- removing a menu item does **not** remove the homepage section,
- changing site copy in config does **not** disable a section,
- and future “About Us / Our Skills / Projects / Let’s Connect” customization is currently constrained by these hard-coded partial calls.

## 4.4 Partial-driven section rendering

Each homepage section is rendered by a theme partial that pulls one specific content page.

### About section

- Partial: `themes/careercanvas/layouts/partials/about.html`
- Content source: `.Site.GetPage "about"`
- Current source file: `content/en/about.md`

### Skills section

- Partial: `themes/careercanvas/layouts/partials/skills.html`
- Content source: `.Site.GetPage "skills"`
- Current source file: `content/en/skills.md`

### Experience section

- Partial: `themes/careercanvas/layouts/partials/experience.html`
- Content source: `.Site.GetPage "experience"`
- Current source file: `content/en/experience.md`

### Technical / Tech Stack section

- Partial: `themes/careercanvas/layouts/partials/technical.html`
- Content source: `.Site.GetPage "technical"`
- Current source file: `content/en/technical.md`

### Contact section

- Partial: `themes/careercanvas/layouts/partials/contact.html`
- Content source: `.Site.GetPage "contact"`
- Current source file: `content/en/contact.md`

### Testimonials section

- Partial: `themes/careercanvas/layouts/partials/testimonials.html`
- Content source: `.Site.GetPage "testimonials"`
- There is no clear evidence in the reviewed root content listing that `content/en/testimonials.md` currently exists.

### Important consequence

These section partials are coupled to **specific page lookup names** such as `about`, `skills`, `experience`, `technical`, and `contact`.

So if later you rename files to:

- `about-us.md`
- `our-skills.md`
- `projects.md`
- `connect.md`

without also changing the partial lookup logic, the homepage will silently stop finding the intended content.

That is one of the biggest edge cases in the current architecture.

---

## 5. Homepage content model

## 5.1 Hero content

The hero section is driven mostly from `config.toml`, not from a content page.

English values currently include:

- iHydro M&D branding
- lab-style hero description
- Texas Tech location
- collaboration tags

This is already partially aligned with a research-group site.

However, the hero still depends on generic theme copy such as:

- `helloIm`
- `whatWeDo`
- `getInTouch`
- `viewCV`

so the final rendered wording still depends on the theme’s i18n dictionaries.

## 5.2 About content

`content/en/about.md` is still heavily from the old personal template and includes unrelated identity details such as:

- structural engineering
- AEC/software background
- Montréal
- Fireraven
- ObraLink
- personal hobbies and personal quick facts

So although the site branding says iHydro M&D Lab, the about-section content source is still a personal-profile markdown file with stale content.

## 5.3 Skills / experience / technical content

These files are also clearly inherited from a personal software-engineering portfolio.

### `content/en/skills.md`
Current domains include items such as:

- Full Stack Development
- AI Security & Compliance
- Database & Data Management
- Agile Collaboration & Leadership
- International Experience

### `content/en/experience.md`
Still describes positions like:

- Fireraven
- ObraLink
- Tensacon
- Sirve Engineering
- Various Engineering Firms

### `content/en/technical.md`
Still includes a software-engineering stack centered on:

- FastAPI / NestJS
- React / Next.js
- PostgreSQL / MongoDB / Supabase
- Tailwind / Vite / Vue
- PyTorch / TensorFlow / Hugging Face
- engineering software from a previous context

This means the homepage currently mixes **research-lab branding** with **personal software portfolio data**.

## 5.4 Research and team sections

The research-group structure is already started.

### Research section

`content/en/research/_index.md` currently introduces “Research Directions,” but its body still contains obviously stale placeholder/project-template text such as:

- “Scheduler Student Services”
- “CareerCanvas Hugo Theme”

So this section exists structurally, but the content is not cleaned yet.

### Team section

`content/en/team/_index.md` is already using a custom `layout: "team"` and has a proper group-oriented data structure:

- principal investigator block
- current members array
- alumni array

This is the most mature “lab site” content model in the repo.

However, even this file still contains stale/incorrect inherited values and likely sample data issues:

- `github` points to an unrelated username in the PI block,
- duplicated member entries appear present,
- some email domains and member bios look inherited from another lab template,
- “environmental health research” appears in the Join Our Team text even though the site is hydrology-focused.

So the team architecture is promising, but the dataset still needs cleanup.

---

## 6. Navigation system

Main menu items are controlled by:

- `config/_default/menus.en.toml`

The current English menu is already mostly converted away from personal homepage anchors. It only exposes:

- Research
n- Team

while legacy menu entries for About, Skills, Experience, Contact, Tech Stack, Blog, Engineering, Contributions are commented out.

### Important consequence

The menu is **not** the source of truth for homepage sections.

So even though About / Skills / Experience / Contact are removed from the menu, those sections still render on the homepage because `index.html` hard-codes them.

This directly explains the behavior behind your first requested change.

---

## 7. Styling and asset pipeline

## 7.1 Tailwind/PostCSS

The root contains:

- `tailwind.config.js`
- `postcss.config.js`
- `package.json`

The Tailwind config uses:

- `darkMode: 'class'`
- content scanning for root layouts/content and theme layouts/assets
- typography and aspect-ratio plugins

This means dark mode is based on a CSS class strategy, not media-query-only styling.

That is good news for your second requested change because it means **dark mode can stay** while dynamic palette randomization is removed.

## 7.2 CSS processing path

There are two overlapping CSS stories in the repo:

1. `package.json` contains a script that writes built CSS into:
   - `themes/careercanvas/static/css/main.css`
2. `baseof.html` uses Hugo resources and PostCSS on:
   - `resources.Get "css/main.css" | postCSS ...`

This overlap is a maintenance risk because it suggests two possible mental models:

- prebuild CSS into the theme’s `static/` directory,
- or let Hugo Pipes/PostCSS handle CSS dynamically during build.

The code path in `baseof.html` suggests Hugo Pipes is active, which makes the separate `build:css` workflow potentially redundant or at least confusing.

That should be simplified in the conversion.

---

## 8. JavaScript behavior

## 8.1 `scripts.js`

This file currently handles:

- mobile menu toggle (`menu-btn` / `mobile-menu`)
- fade-in on sections with `data-animate`

This is lightweight and not a major architectural problem.

## 8.2 `dynamic-colors.js`

This file is the direct cause of the random accent/background color behavior.

### What it does

- defines multiple color palettes,
- selects one at random unless a `?palette=` URL parameter is present,
- writes CSS custom properties to `document.documentElement`,
- runs on `DOMContentLoaded`,
- has a load-event backup initializer,
- stores the selected palette in `window.currentColorPalette`.

### Why colors change on refresh

Because when no `palette` query parameter is set, the script explicitly chooses a random palette on each page load.

### Important nuance

This is separate from dark mode.

- **Dark mode** is controlled by Tailwind’s `darkMode: 'class'` model.
- **Random color changes** are controlled by `dynamic-colors.js` plus config palettes.

So you can remove refresh-based random palette behavior **without losing dark/light themes**.

## 8.3 `pexels-background.js`

This file handles optional hero background images from the Pexels API.

Key behavior:

- reads `window.PEXELS_API_KEY` and configured queries,
- chooses random query / page / per_page values,
- fetches a random landscape image,
- falls back to a gradient if there is no API key or the fetch fails.

### Important consequence

There are **two different kinds of visual randomness** in the theme:

1. random **color palette** selection,
2. random **hero background image** selection.

Your request only mentioned background color changes. Based on the code, that is mainly the dynamic-color system, but if a Pexels API key is active then the hero image can also vary across refreshes.

---

## 9. Deployment and environment model

## 9.1 Local development

Local dev is supported by:

- `npm run dev` → `hugo server -D`
- `dev.sh` → runs Hugo with `config.toml,config.local.toml`

The README explains that `config.local.toml` is intended for:

- `pexelsapikey`
- `formspreeendpoint`

This is a reasonable pattern for local secrets.

## 9.2 Production build

The repo also includes:

- `build.sh` → `git submodule update --init --recursive` then `hugo --minify`
- `vercel.json` → build command `./build.sh`, output `public`

### Important consequence

Production builds depend on the theme submodule being initialized correctly.

If the submodule pointer is wrong, missing, or locally modified without being committed properly, production output can drift from what you expect.

---

## 10. Major mismatches and stale-template findings

This repo contains a large number of mixed states. These are not small cosmetic issues; they affect correctness and maintainability.

## 10.1 Repo identity vs content identity mismatch

The root `config.toml` says the site is:

- `title = "iHydro M&D"`
- `name = "iHydro M&D Lab"`

but several content files still describe a completely different person/profile.

## 10.2 English menu vs homepage mismatch

The English menu only exposes Research and Team, but the homepage still renders old sections because section rendering is hard-coded in `index.html`.

## 10.3 Language configuration mismatch

English has partially updated lab text, but Spanish and French still contain old portfolio descriptions.

That creates a multilingual edge case:

- the language switcher can expose stale identity content if those languages are active.

## 10.4 Live site mismatch

The public site at `https://spark-hydro.github.io/` appears to be serving a different site/content model than the repository currently reviewed.

The live site includes top-level navigation such as:

- Home
- Research
- Publications
- Talks
- Posts
- CV
- Contact

and appears to be based on a different content/layout system than the current `careercanvas` repo structure.

That means one of the following is true:

1. the repo has not yet been deployed,
2. deployment points to a different branch or source,
3. GitHub Pages is serving an older static build,
4. or another site generator/repo is currently the live publisher.

This is a critical operational detail because code changes in this repo may not affect the live site until deployment wiring is clarified.

## 10.5 Contact/social mismatches

Several root params still look inherited or inconsistent:

- `linkedin_text` still references Felipe text,
- `calendly_url` still references a previous owner,
- `og_image` still points to a previous branding asset,
- `email` currently appears to be `seonggyu.park@ttu.com`, which looks suspicious relative to expected TTU convention.

These may create correctness, trust, and branding issues.

## 10.6 Team data quality issues

The team page currently appears to include:

- duplicated member entries,
- non-hydrology placeholder language,
- potentially inherited sample metadata.

## 10.7 Research section placeholder issues

The research landing page still references stale items that do not match an iHydro research site.

---

## 11. Edge cases and hidden failure modes

Here are the most important edge cases I identified.

## 11.1 Renaming homepage content files can break partial lookup

Because the partials use `.Site.GetPage "about"`, `.Site.GetPage "skills"`, etc., changing filenames or slugs without updating the lookup will break those sections.

## 11.2 Menu edits do not control homepage section visibility

A common assumption would be “if I remove About from the menu, it will disappear from the homepage.”

That is false in this codebase because homepage rendering is independent from menu configuration.

## 11.3 Missing Pexels queries can trigger build errors

`pexels-config.html` contains an `errorf` if `params.pexels.queries` is absent. So if someone removes or empties that config carelessly, the site can fail at build time.

## 11.4 Theme submodule drift

Because the theme is externalized as a submodule, the main repo can point at one theme revision while local testing may use another. This is a classic reproducibility problem.

## 11.5 Dual randomness

Color palette randomness and hero-image randomness are separate. Fixing only one may still leave the site feeling visually inconsistent across refreshes.

## 11.6 Multilingual stale content exposure

Even if English is cleaned, language switching can still reveal old portfolio text unless Spanish and French are cleaned or disabled.

## 11.7 Section title inconsistency

Some partials use page titles, but others use i18n keys directly.

For example:

- `skills.html` uses `.Title`
- `technical.html` uses `.Title`
- `experience.html` uses `.Title`
- `about.html` uses `i18n "aboutMe"`
- `contact.html` uses `i18n "contactFormLabel"`

So changing the markdown title alone will not consistently rename all front-page section headings.

## 11.8 Testimonials section can silently no-op

If the `testimonials` page is missing, the partial likely renders nothing because it is wrapped in `with .Site.GetPage "testimonials"`.

That is harmless visually, but it adds dead coupling in `index.html`.

---

## 12. Direct answers to your two example modifications

## 12.1 “Hide about me, skills, experience, tech stack, let’s connect in the front page, but change them later for the lab”

### Current state

This cannot be done robustly just by changing menus.

### Why

Because homepage sections are hard-coded in `themes/careercanvas/layouts/_default/index.html`.

### Best interpretation

You need a **homepage section toggle system** and likely also **more generic section naming**.

At minimum, you will want:

- a config block controlling visibility,
- about/contact partials refactored to use content-driven titles instead of personal i18n labels,
- and content pages rewritten to lab-oriented text.

## 12.2 “Stop change background color with every refresh but still keep dark mode and light mode themes”

### Current state

This is fully feasible.

### Why

- Random palette behavior is coming from `dynamic-colors.js`.
- Dark mode support is a Tailwind class-based feature.

So these are separate concerns.

### Best interpretation

Remove or disable the random-palette script, keep the Tailwind dark-mode setup, and optionally introduce a fixed palette selected in config.

---

## 13. Recommended conversion direction

From the current architecture, the cleanest future state is:

1. keep Hugo,
2. keep Tailwind,
3. keep the theme only if you are willing to refactor it,
4. convert homepage sections from personal-portfolio assumptions to **configurable lab sections**,
5. eliminate random palette selection,
6. simplify multilingual state until all languages are truly maintained,
7. clean all stale content and social links,
8. verify deployment source before doing substantial branding work.

---

## 14. Bottom line

The codebase is workable and already partially pointed toward an iHydro research-group site, but it is not yet internally consistent.

The most important truths are:

- the homepage is still controlled like a personal portfolio,
- section rendering is hard-coded,
- random refresh color changes are explicitly scripted,
- dark mode is independent and can be preserved,
- the theme is a submodule, which complicates maintenance,
- and the live site appears out of sync with the repo.

That means the right migration is not a cosmetic text edit. It should be a **small structural refactor** so future lab-site changes become easy instead of fragile.
