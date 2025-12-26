# 🔥 Burnt Out

**A corporate survival game where burnout is your biggest enemy**

[![Godot](https://img.shields.io/badge/Godot-4.0+-blue.svg)](https://godotengine.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/docs-online-brightgreen.svg)](https://nathanhitchcock.github.io/BurntOut/)

> Navigate the treacherous waters of corporate life while managing your stress levels and fighting off literal bugs in the system!
  
## 🎮 About

**Burnt Out** is a unique blend of puzzle-solving, tower defense, and stress management. Play as an overworked employee navigating office politics, debugging systems, and trying to maintain your sanity in a corporate environment where burnout can literally kill you.

### ✨ Key Features

- **Dynamic Burnout System** - Your stress level affects gameplay mechanics
- **Progressive Puzzle Rooms** - Toggle puzzles that scale with difficulty  
- **Bug Smashing Mini-Game** - Literally debug the system with satisfying feedback
- **Corporate Office Exploration** - Navigate realistic office environments
- **Audio-Visual Polish** - Immersive sound design and visual effects

## 🚀 Quick Start

### Prerequisites
- [Godot 4.0+](https://godotengine.org/download)
- Git

### Installation
```bash
git clone https://github.com/nathanhitchcock/BurntOut.git
cd BurntOut
# Open project.godot in Godot Engine
```

### Controls
- **WASD / Arrow Keys** - Move player
- **E** - Interact with objects
- **ESC** - Pause menu
- **Mouse** - UI interaction and puzzle solving

## 📚 Documentation

Visit our **[comprehensive documentation](https://nathanhitchcock.github.io/BurntOut/)** for:

- 📖 **[Game Design](https://nathanhitchcock.github.io/BurntOut/game_design/)** - Core mechanics and systems
- 🔧 **[Autoloads API](https://nathanhitchcock.github.io/BurntOut/autoloads/)** - Global systems reference  
- 🎨 **[Style Guide](https://nathanhitchcock.github.io/BurntOut/STYLE_GUIDE/)** - Code and asset conventions
- 🤝 **[Contributing](https://nathanhitchcock.github.io/BurntOut/CONTRIBUTING/)** - How to contribute
- ❓ **[FAQ](https://nathanhitchcock.github.io/BurntOut/faq/)** - Common questions

## 🔧 Technical Architecture

### **Core Autoloads (Global Systems)**
- **`GlobalUI`** - Master UI controller for pause menu, health bars, and interaction prompts
- **`GlobalAudio`** - Centralized audio management with volume controls and SFX coordination  
- **`player_data`** - Persistent data singleton for health, position, sprint points, and progress

### **Key Function Highlights**
- **`progressive_toggle_manager._spawn_toggles()`** - Dynamic puzzle generation with grid positioning
- **`bug_movement.show_squish_effect()`** - Physics-based visual feedback with proper scaling
- **`global_ui._on_volume_slider_changed()`** - Real-time audio control via AudioServer Master bus
- **`overworld_player.setup_room_specific_zoom()`** - Adaptive camera system for different areas
- **`bug_smash_manager.register_bug()`** - Dynamic bug tracking with reward calculations

> **📋 For detailed API documentation, function signatures, and implementation details, see our [complete documentation site](https://nathanhitchcock.github.io/BurntOut/autoloads/).**

## 🎯 Current Features

### ✅ Completed Systems

#### 🧩 **Progressive Toggle Puzzle System** 
Dynamic difficulty scaling (1-10 toggles) with sophisticated gameplay mechanics:
- **Progressive Difficulty**: `progressive_toggle_manager.gd` - Starts with 1 toggle, scales to 10
- **Dual Interaction**: Mouse clicks + `[E]` key proximity interaction via Area2D
- **Smart Spawning**: Grid-based positioning with collision detection
- **Reward Scaling**: Points awarded equal to level (Level 5 = 5 points)
- **Audio Feedback**: Success/fail sounds with visual effects

#### 🐛 **Bug Smash Physics Mini-Game**
Interactive debugging simulation with satisfying feedback:
- **Dynamic Bug System**: `bug_movement.gd` - AI movement with burst patterns and collision
- **Squish Effects**: Visual feedback with properly scaled sprites for small/large bugs  
- **Split Mechanics**: Large bugs spawn 0-3 smaller bugs when smashed
- **Damage System**: Bugs deal damage to player with immunity frames
- **Reward System**: `bug_smash_manager.gd` - Sprint points scaled to difficulty

#### 🎮 **Global UI Management System**
Comprehensive interface system managing all game UI:
- **Pause System**: `global_ui.gd` - ESC menu with volume control and game state
- **Health/Status**: Dynamic health bar, burnout flames, shield indicators
- **Interaction Prompts**: Floating `[E]` prompts and proximity-based UI
- **Audio Control**: Master bus volume slider with real-time dB mapping
- **Cross-Scene UI**: Bug counters, level info, persistent status displays

#### 🔊 **Audio System Architecture**
Centralized audio management with global controls:
- **Global Volume**: `AudioServer` integration with Master bus control
- **Dynamic SFX**: Context-aware sound effects (success, fail, interaction)
- **Background Music**: `GlobalAudio` autoload with pause/resume functionality
- **Audio Feedback**: Hammer swings, bug squishing, button clicks, UI interactions

#### 🎯 **Player Movement & Camera System**
Smooth character controller with adaptive behavior:
- **Movement**: `overworld_player.gd` - WASD/Arrow key input with normalized velocity
- **Animation System**: Walking animations with fire trail particle effects
- **Room-Specific Camera**: Adaptive zoom levels (tutorial: 5x, bug smash: 1x, default: 2.5x)
- **Camera Controls**: Optional dynamic zoom disabled for tutorial sections
- **State Persistence**: `player_data.gd` autoload for cross-scene data

#### ⚙️ **Defense & Tower Systems**
Strategic placement and management mechanics:
- **Coffee Machines**: `productivity_machine.gd` - Upgrade system with sprint point economy
- **Defense Placement**: Click-to-place tower defense mechanics
- **Resource Management**: Leadership points and strategic decision making
- **Visual Effects**: Screen flicker effects, floating feedback labels

### 🚧 In Development

#### 📚 **Tutorial System** *(Current Branch)*
Interactive intro section with custom camera settings:
- **Tutorial Assets**: Custom backgrounds, tilemap, and coffee machine sprites
- **Fixed Camera**: 5x zoom lock for consistent tutorial experience  
- **Progressive Learning**: Step-by-step introduction to game mechanics

#### 🏢 **Expanded Office Areas**
Additional rooms and interactive corporate environments:
- **New Environments**: Meeting rooms, break areas, executive floors
- **Interactive Elements**: More puzzle types and environmental storytelling

## 🏗️ Project Structure

```
BurntOut/
├── assets/          # Game assets (audio, images, sprites)
├── docs/           # MkDocs documentation
├── scenes/         # Godot scenes organized by area
├── scripts/        # GDScript files organized by feature
├── archive/        # Legacy/unused assets (preserved)
└── .github/        # GitHub Actions and project automation
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](https://nathanhitchcock.github.io/BurntOut/CONTRIBUTING/) for:
- Code style guidelines
- Branching strategy
- Issue reporting process
- Pull request workflow

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes following our [Style Guide](https://nathanhitchcock.github.io/BurntOut/STYLE_GUIDE/)
4. Test your changes thoroughly
5. Commit with descriptive messages
6. Push to your fork and submit a Pull Request

## 🎨 Built With

- **[Godot Engine 4.0+](https://godotengine.org/)** - Game engine
- **[MkDocs Material](https://squidfunk.github.io/mkdocs-material/)** - Documentation
- **[GitHub Actions](https://github.com/features/actions)** - CI/CD and project automation

## 🧭 Code of Conduct

Please read our [Code of Conduct](CODE_OF_CONDUCT.md) to understand expected behavior in all project spaces.

## 📜 Asset Credits

See [docs/assets.md](docs/assets.md) for third-party asset sources and licenses. Ensure any new assets include clear attribution.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏢 Burnt Potato Games

Made with ❤️ and ☕ by the Burnt Potato Games team.

---

> "In a world of corporate chaos, will you survive the burnout... or become part of the system?"
