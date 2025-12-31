# Burnt Out Project Documentation

Welcome to the Burnt Out codebase! This documentation provides an overview of the project structure, key systems, and best practices for contributors.

---

## Project Structure

- `assets/` — Game assets (audio, images, music, sfx, sprites, backgrounds, vfx, ui, etc.)
- `archive/` — Curated future-intent or legacy assets. Only keep items referenced by active scenes or explicitly documented for future use.
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
- **Curate `archive/`**: Keep only assets referenced by active scenes or documented for future usage. Remove prototypes and files that never shipped.
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

## Global Volume Control

The pause menu features a volume slider that controls the volume for all game audio. This is implemented using Godot's AudioServer and the Master audio bus, ensuring that all sounds (music, SFX, UI, etc.) are affected globally.

**Implementation:**

```gdscript
func _on_volume_slider_changed(value):
    # Set global audio volume using the Master bus
    var db = lerp(-40, 0, value)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
    _update_volume_label()
```

- The slider value (0.0 to 1.0) is mapped to decibels (-40 dB to 0 dB).
- All AudioStreamPlayers routed to the Master bus are affected.

**Usage:**
- Open the pause menu in-game.
- Adjust the volume slider to set the global game volume.
- All audio will respond instantly, regardless of which scene or node is playing the sound.

_Tip: For best results, ensure all your AudioStreamPlayers are routed to the Master bus (or a child bus you control similarly)._

_Last updated: December 31, 2025_
