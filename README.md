# Hafiz — NOVU

Hafiz is an offline, fully-encrypted password vault for Android.
**Zero internet permission.** AES-256-GCM at rest, PBKDF2-HMAC-SHA256 (100,000 rounds),
and your key only ever lives in memory.

## Live landing page

The Hafiz product page is published with GitHub Pages:

**https://zeyad-muhammed.github.io/hafiz/**

Source for that page lives in [`hafiz-brand/`](hafiz-brand/) on `master`.
GitHub Pages serves the **`gh-pages`** branch, whose root contains only the
published site (a `git subtree split` of `hafiz-brand/`).

To publish updates after editing `hafiz-brand/` on `master`:

```bash
git subtree split --prefix=hafiz-brand -b gh-pages --force
git push origin gh-pages --force
```

## Repository layout

| Path | What it is |
| --- | --- |
| `hafiz-brand/` | Hafiz landing page (`index.html`, `css/`, `js/`, `assets/`) — self-contained, no third-party requests |
| `itisam/` | Itisam Flutter app source (`lib/`, `android/`, `test/`, `web/`) |
| `itisam-assets/` | Brand asset generation scripts and outputs |
| `conversational-ai/` | Conversational AI service source (`server/`, `scripts/`, `webui/`, requirements) |
| `uploads/` | Shared fonts and logo sources |
| `NOVU_SIGNAL_INTRO.jsx` | NOVU signal intro component |

## Not in the repository

These are large, generated, or environment-specific and are git-ignored
(see [`.gitignore`](.gitignore)):

- `conversational-ai/venv/` — Python virtual environment
- `conversational-ai/models/` — downloaded LLM weights (`*.gguf`, zips)
- `conversational-ai/tools/` — downloaded `llama.cpp` / CUDA binaries
- `conversational-ai/logs/`, `*.log`, `*.pid`
- `itisam/build/`, `itisam/.dart_tool/`, `itisam/.idea/`

To run `conversational-ai` after cloning, recreate the environment
(`requirements.txt`) and re-download the model/tooling assets.

## Privacy note

Screenshots that encode recoverable secrets (emergency-setup QR, QR export code)
are intentionally **not** published on the public page. Only the non-sensitive
screens are shipped under `hafiz-brand/assets/screens/`.

---

© NOVU
