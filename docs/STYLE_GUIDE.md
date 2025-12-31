# Burnt Out Code & Asset Style Guide

## File & Folder Naming
- **Scripts:** `snake_case.gd` (e.g., `toggle_puzzle_manager.gd`)
- **Scenes:** `PascalCase.tscn` (e.g., `ToggleRoom.tscn`)
- **Folders:** `snake_case/` or lowercase (e.g., `scenes/ui/`)
- **Assets:** `snake_case` for images/audio (e.g., `start_screen.png`)

## Project Structure
- Organize by feature and type (see `docs/README.md` for structure).
- Keep a curated `archive/` for future-intent or legacy assets referenced by active scenes or explicitly documented; remove prototypes that never shipped.

## GDScript Conventions
- Use 4 spaces for indentation.
- Use `@onready` for node lookups.
- Use `snake_case` for variables and functions.
- Use `PascalCase` for class names.
- Add docstrings/comments for all public functions and classes.
- Use signals for decoupled communication.

## Scene & Node Best Practices
- Name nodes with `PascalCase`.
- Use instanced scenes for reusable UI/components.
- Attach scripts to root nodes of scenes.
- Use autoloads for global state/singletons.

## Asset Management
- Place images, audio, and other assets in the correct subfolder.
- Remove `.DS_Store` and temp files from git.
- Curate the `archive/` folder: retain only referenced or documented future assets; remove unreferenced items.

## Documentation
- Update `docs/autoloads.md` for any global/singleton changes.
- Add/expand markdown docs for new features or systems.
- Keep FAQ and README up to date.

---

_Last updated: December 31, 2025_
