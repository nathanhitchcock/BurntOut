# Code Overview

This document outlines the current systems and scripts in Burnt Out.

## Autoloads (Globals)
- `GlobalUI` — Pause menu, interact prompts, floating labels, and end overlay.
- `GlobalAudio` — Background music and SFX control; persists volume.
- `player_data` — Persistent player state (health, position, sprint).

## UI and Overlays
- `scripts/ui/global_ui.gd` — Manages pause, victory overlay, and HUD prompts.
	- `show_end_screen()` displays a top-centered victory banner when productivity reaches 100%.
	- Volume slider updates Master bus and saves to `user://settings.cfg`.

## Player
- `scripts/player/overworld_player.gd` — Movement, damage, and floating feedback.
	- Damage popups and shield messages are offset to avoid overlap.

## Productivity Machine
- `scripts/objects/productivity_machine.gd` — Tracks `machine_points` and completion.
	- On completion, calls `GlobalUI.show_end_screen()`.

## Puzzles
- `scripts/puzzles/progressive_toggle_manager.gd` — Progressive toggle puzzle.
	- Guards input post-solve and respects disabled toggles.
	- Provides success/failure SFX and feedback.

## Audio
- Global volume controlled via Master bus; persisted to `user://settings.cfg`.

## Scene Organization
- `scenes/` — Organized by area (overworld, ui, puzzles, corp office).

Last updated: December 31, 2025
