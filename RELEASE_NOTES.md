# Release v0.1.0 — Learning Project Complete (2025-12-31)

This release marks the successful completion of the original goal: to learn how to program a game. Mission accomplished — a lot was learned across Godot 4, GDScript, UI systems, puzzles, audio, and CI/docs.

Highlights
- Docs: MkDocs site set up and published; Material theme, favicon/apple-touch icon, nav, and `site_url` configured. Live at https://nathanhitchcock.github.io/BurntOut/
- CI: Added auto-deploy workflow to publish MkDocs on pushes to `main`. Kept secret scanning; removed the noisy auto-add workflow.
- Gameplay/UI polish: Victory end overlay positioned top-center; burnout flow pauses and resumes correctly; global volume persistence to `user://settings.cfg`.
- Puzzle robustness: Progressive toggle puzzle guards post-solve inputs; respects disabled toggles; clear success/fail feedback.
- Feedback clarity: Damage and shield popups offset to avoid overlap; puzzle failure feedback offset.
- Repo hygiene: Removed legacy defenses/tutorial assets and unused scenes/scripts; docs updated to reflect removal policy instead of long-lived archives.

Notes
- This was primarily a learning project to explore game programming. The initial goal is complete.
- Current branch `closed-loop` contains the gameplay fixes, docs, and CI updates and is proposed to merge into `main`.

Next
- Merge `closed-loop` → `main` to enable auto-publish on future commits.
- Optional smoke tests: toggle room interactions, burnout pause flow, end overlay + restart.
