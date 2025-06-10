# Burnt Out Project Documentation

Welcome to the Burnt Out codebase! This documentation provides an overview of the project structure, key systems, and best practices for contributors.

---

## Project Structure

- `assets/` — Game assets (audio, images, music, sfx, sprites, backgrounds, vfx, ui, etc.)
- `archive/` — Unused or legacy assets and scenes, kept for reference or possible reuse.
- `docs/` — Project documentation, FAQ, and style guides.
- `scenes/` — All Godot scenes, organized by area (e.g., overworld, ui, puzzles, defenses).
- `scenes/autoload/` — Scenes used as autoloads (singletons) for global systems.
- `scripts/` — All GDScript files, organized by feature (ui, puzzles, player, autoload).
- `scripts/autoload/` — Scripts used as autoloads (singletons).

---

## Key Systems

### Autoloads/Globals
See `docs/autoloads.md` for a full API reference of all global singletons.

### UI System
- Managed by `GlobalUI` autoload.
- Handles pause menu, interact prompts, floating labels, and input routing.
- UI scenes are in `scenes/ui/` and scripts in `scripts/ui/`.

### Audio System
- Managed by `GlobalAudio` autoload.
- Handles background music and SFX.
- Audio assets are in `assets/audio/`.

### Player Data
- Managed by `player_data` autoload.
- Stores persistent player state (health, position, sprint points).

### Puzzles
- Toggle puzzle logic in `scripts/puzzles/toggle_puzzle_manager.gd`.
- Toggle buttons are instanced from `scenes/CORP/toggle_room/ToggleButton.tscn`.

---

## Best Practices

- **Organize assets and scripts** by feature and type.
- **Archive, don’t delete**: Move unused assets/scenes to `archive/`.
- **Use snake_case for scripts** and PascalCase for scenes.
- **Document all autoloads** and update `docs/autoloads.md` when globals change.
- **Keep `.DS_Store` and temp files out of git** (see `.gitignore`).
- **Test in the editor after moving or renaming files** to update resource paths.

---

## FAQ
See `docs/faq.md` for common gameplay and development questions.

---

## Contributing
- Please follow the project structure and naming conventions.
- Document new features and update relevant markdown files.
- When in doubt, ask or check the docs!

---

_Last updated: June 9, 2025_
