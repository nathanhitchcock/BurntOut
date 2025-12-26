# Open-Source Readiness Checklist

Use this checklist on the `public-prep` branch to prepare BurntOut for a public release. Check off items as you complete them.

- [ ] Choose a license: MIT, Apache-2.0, or GPL-3.0. Add `LICENSE` at repo root.
- [ ] Review third-party assets under `assets/` (images, audio) for redistribution rights; add attributions and sources.
- [ ] Remove any secrets or private URLs from scripts and configs (`scripts/`, `scenes/`, `docs/`). Verify no API keys or tokens are committed.
- [ ] Update `README.md` for public audience: overview, setup, build/run instructions, credits, and license.
- [ ] Review `docs/` content for internal-only references; mark anything intentionally omitted.
- [ ] Confirm `CONTRIBUTING.md` is current and aligned with public contributions (PR flow, coding style, issues).
- [ ] Add a Code of Conduct (e.g., Contributor Covenant) if desired: `CODE_OF_CONDUCT.md`.
- [ ] Ensure Godot project loads cleanly without private dependencies; test scenes in `scenes/` and trim non-essential `archive/` content if needed.
- [ ] Add asset credits section in `README.md` or `docs/assets.md` with sources and licenses.
- [ ] Configure repository visibility steps in GitHub (owner action) once checklist is complete.

Optional:

- [ ] Add GitHub Issue and PR templates under `.github/`.
- [ ] Set up CI (e.g., simple lint/build checks) if desired.

Notes:
- Keep sensitive internal context out of commit messages.
- Prefer squash merges for cleanup when making history public.