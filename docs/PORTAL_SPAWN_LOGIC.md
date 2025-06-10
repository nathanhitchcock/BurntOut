# Portal and Player Spawn Logic Refactor

## Summary
- Player position is now saved to `player_data.position` when using a portal.
- On scene load, the player checks `player_data.position` and spawns at that location if set (and not coming from StartScreen).
- This enables flexible, robust portal and spawn logic for all scene transitions.

## Implementation
- Updated `portal_to_corp_office.gd` to save the player's global position to `player_data.position` before changing scenes.
- Updated `overworld_player.gd` to check and use `player_data.position` on `_ready()`, only if not loading from StartScreen.
- Resets `player_data.position` to `Vector2.ZERO` after use to avoid unintended reuse.

## Usage
- Works for any portal/scene transition.
- First load from StartScreen uses the default position in the scene.
- No hardcoded flags or positions required for future portals.

## Commit Message
```
refactor: robust portal/player spawn logic using player_data.position

- Player position is saved on portal use and loaded on scene entry
- Only applies if not coming from StartScreen
- Enables flexible, future-proof portal/scene transitions
- Updated documentation
```
