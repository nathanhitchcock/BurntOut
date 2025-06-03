# Code Overview

## Main Script (`main.gd`)
The main script handles:
- Game initialization.
- Wave progression.
- Leadership point management.
- Defense and teammate logic.

### Key Variables
- `leadership_points`: Tracks the player's available leadership points.
- `current_wave`: Tracks the current wave number.
- `defense_types`: Stores data for available defenses.

### Key Functions
- `spawn_teammate()`: Spawns a new teammate.
- `get_defense_data(defense_name)`: Retrieves data for a specific defense type.
