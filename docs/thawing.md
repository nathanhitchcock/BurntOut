# Thawing Checklist (Stabilization Pass)

Goal: safely bring the project back to a runnable state after a hiatus.

## Environment
- Godot: confirm 4.x installed (same minor as last run if possible)
- Project: open project.godot and let Godot re-import assets
- Run: try play from the start screen and the overworld

## Quick Triage
- Autoloads: check Project Settings → Autoload (missing scripts or renamed paths)
- Audio buses: verify Master/SFX/Music bus names match code
- Input map: confirm required actions (ui_accept, ui_cancel, custom actions)
- Scenes: open StartScreen.tscn, overworld.tscn, UpgradeShopUI.tscn
- Scripts: look for compile errors in scripts/ and scenes/

## Common Breakages
- Renamed or moved assets under assets/ (fix paths in .tscn and scripts)
- Deleted UID files causing resource reference warnings (relink scenes/resources)
- API drift in Godot 4 minor versions (tweens, signals, Input events)

## Recording Issues
- Create issues titled [Thaw] ... with: steps, scene/script paths, and screenshots
- Group trivial fix-ups into one task; keep crashes or blockers as separate issues

## After Fixes
- Smoke test: Start → Overworld → Puzzle → Bug Smash → Shop → Game Over
- Export: test export preset builds locally (no signing/secrets required)
- Docs: update any changed controls or flows in docs/

---

Tip: keep changes small and focused; open PRs from thawing for each fix set.
