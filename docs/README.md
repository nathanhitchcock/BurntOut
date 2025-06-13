# Global Volume Control in BurntOut

## How it works

The pause menu features a volume slider that controls the volume for all game audio. This is implemented using Godot's AudioServer and the Master audio bus, ensuring that all sounds (music, SFX, UI, etc.) are affected globally.

### Implementation

In `global_ui.gd`:

```gdscript
func _on_volume_slider_changed(value):
    # Set global audio volume using the Master bus
    var db = lerp(-40, 0, value)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
    _update_volume_label()
```

- The slider value (0.0 to 1.0) is mapped to decibels (-40 dB to 0 dB).
- All AudioStreamPlayers routed to the Master bus are affected.

### Usage

- Open the pause menu in-game.
- Adjust the volume slider to set the global game volume.
- All audio will respond instantly, regardless of which scene or node is playing the sound.

---

**Tip:** For best results, ensure all your AudioStreamPlayers are routed to the Master bus (or a child bus you control similarly).
