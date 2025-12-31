# Archive (Curated)

This folder is intentionally kept small and focused. It holds only assets that are either:

- Referenced by active scenes in the game today, or
- Explicitly documented here for near-term, future-intent use.

Prototype scenes, unused experiments, and one-off concept assets are removed from the repository to keep the project lean.

## Retained Assets

These files are retained because they are referenced by current scenes or are needed for in-game visuals.

- coffee_icon.png
  - Where used:
    - scenes/defenses/CoffeeMachine.tscn
    - scenes/defenses/Coffee_machine.tscn
- ChatGPT Image Jun 4, 2025 at 10_58_19 PM.png
  - Where used:
    - scenes/CORP/corp_office.tscn
    - scenes/CORP/skyline/SkylineWatch.tscn
    - scenes/CORP/toggle_room/toggle_room.tscn
    - scenes/CORP/bug_smash/bug_smash.tscn
- game_over_burnout.png
  - Where used:
    - archive/legacy/game_over/GameOver-Burnout.tscn (legacy)
    - archive/legacy/game_over/GameOver-Victory.tscn (legacy)
- ChatGPT Image May 25, 2025, 10_03_18 PM.png
  - Where used:
    - archive/legacy/game_over/GameOver-CEOVictoryScreen.tscn (legacy)

Note: The corresponding `.import` files for the above assets are kept to preserve Godot import settings and ensure stable asset hashing.

## Policy

- Keep only assets that are referenced by scenes/scripts or explicitly listed here.
- Remove assets that never shipped or are not in use.
- If you plan to use a new archived asset soon, add it to this README with a short rationale and the intended scene(s).

## Maintenance

- When removing assets, search for references before deleting:
  - In scenes: look for `res://archive/` paths.
  - In scripts: scan for `res://archive/` strings.
- After deletions, run the game and confirm no resource load errors appear.

Example reference check commands (run from repo root):

```
# Find archive references in scenes and scripts
rg -n "res://archive/" scenes/ scripts/

# List current archive files
ls -la archive/
```

_Last updated: 2025-12-31_

## Legacy Scenes (Archived)

The following scenes were used in an early design and are no longer part of the active flow. They were moved from `scenes/Game Over/` to `archive/legacy/game_over/` on 2025-12-31.

- archive/legacy/game_over/GameOver-Burnout.tscn
- archive/legacy/game_over/GameOver-Victory.tscn
- archive/legacy/game_over/GameOver-CEOVictoryScreen.tscn

Rationale: replaced by `SkylineWatch` + `GlobalUI` burnout and end overlays.
