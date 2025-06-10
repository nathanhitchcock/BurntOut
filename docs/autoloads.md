# Autoloads / Globals API Reference

This document describes the global singletons (autoloads) available throughout the Burnt Out project.

---

## GlobalUI
- **Path:** `res://scenes/autoload/GlobalUI.tscn`
- **Script:** `res://scripts/ui/global_ui.gd`
- **Type:** CanvasLayer (UI root)
- **Purpose:**
  - Manages global UI elements such as the pause menu, interact prompts, and floating labels.
  - Handles pausing/unpausing gameplay, input routing, and music pausing.
- **Key Methods:**
  - `show_interact_prompt(visible: bool)` — Show/hide the floating [E] interact prompt.
  - `show_interact_popup_near_player(player)` — Show an in-world interact popup near the player.
  - `set_pause_menu_visible(visible: bool)` — Show/hide the pause menu.
  - `set_gameplay_enabled(enabled: bool)` — Enable/disable gameplay input.

---

## GlobalAudio
- **Path:** `res://scenes/autoload/global_audio.tscn`
- **Type:** Node (Audio root)
- **Purpose:**
  - Manages global audio playback, including background music and sound effects.
  - Provides access to music and SFX nodes for pausing, resuming, and volume control.
- **Key Nodes:**
  - `AmbientHum` — Background music player.
  - `Player/PlayerDamageSound` — SFX for player damage.

---

## player_data
- **Path:** `res://scripts/autoload/player_data.gd`
- **Type:** Script (Resource/Node)
- **Purpose:**
  - Stores persistent player data (health, position, sprint points, etc.) across scenes.
  - Used for saving/loading player state.
- **Key Properties:**
  - `health` — Player's current health.
  - `position` — Player's last known position.
  - `sprint_points` — Player's sprint points.

---

> Update this file if you add, remove, or change autoloads in the project.
