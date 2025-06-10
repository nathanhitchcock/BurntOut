# Game Design

## Game Overview

**Title:** Burnt Out: Survive the Sprint  
**Genre:** Satirical Tech-Fantasy Management Sim  
**Engine:** Godot 4.4.1  
**Platform:** PC (Steam), future iOS & Android support  
**Target Playtime:** 15–25 minutes per run / ~3 hours full arc  
**Art Style:** Clean-line 2D digital, flat shading, vector look (Cult of the Lamb meets tech-dystopia)

## Core Themes & Tone
- Corporate absurdity as dark fantasy
- Burnout as both mechanic and metaphor
- Strategic play with humorous consequences
- Morale, chaos, and coffee are core resources
- Smart systems wrapped in self-aware satire

## Core Gameplay Loop
1. Wake up in Spark's pod
2. Get coffee (heal morale / buff)
3. Choose mission from the Scrum board
4. Enter task room (puzzle toggle, ritual, or stress event)
5. Survive or burnout
6. Return to office, recover, repeat

## Player Character
- **Name:** Spark
- **Type:** Anthropomorphic flame intern
- **States:** Peppy, Stressed, Burnt Out, Mettle Burst
- **Visual Progression:** Hoodie gets darker, eyes change, posture slouches with stress

## World Layout (Tilemap Hub)
- Home Pod - Spark's recovery space
- Coffee Shrine - Heals or shields
- Upgrade Shop - Exchange Sprint Points for powerups
- SCRUM Cult Room - Task selection via rituals
- Mission Zones - Procedural challenge rooms (toggles, chaos waves)
- The Fog Room - Team of unknowable senior wizards; provide bizarre quests

## Key Systems
### Morale
- Primary health bar
- Boosted by coffee, upgrades, completing tasks
- Damaged by failed tasks, stress waves, burnout events

### Burnout
- Triggers when morale hits 0%
- Sends Spark to the rooftop reflection scene
- Reduces morale cap temporarily
- Unlocks narrative progression

### Ritual Tasks
- Toggle puzzles, magical forms of busywork
- Multiple difficulties (1–5 toggles)
- Wrong moves = stress waves = morale damage

### Teammates
- Fog of senior engineers
- Deliver absurd fetch quests ("Where's the Midget Maximizer?")
- Unlock deeper understanding over loops
- Eventually influence upgrades, gameplay

## Progression Structure
- 7 loop arc (sprint-based progression)
- Each loop introduces new systems, visual changes, and narrative triggers
- Unlock Insight to reveal truth behind Corp

## Sample Dialogue
> "It's not about winning anymore... it's about surviving the sprint."
> 
> "Welcome, Intern. Your onboarding ritual begins now."
> 
> "Clarity is a myth. Coffee is real."

## Visual Identity
- Warm parchment & teal corporate tones
- Clean UI with hard outlines
- Layered ambient scenes with slight movement
- Title splash screen: "Burnt Out: Survive the Sprint"

## Prototype Features (v0.1 - v0.2)

*(To be expanded as features are implemented)*

## Narrative Structure
- Cinematic intro: rooftop → chaos → Corp title
- Each burnout reveals new truths
- Final sprint = confrontation with the Board
- Epilogue unlocks Spark’s escape or full assimilation

## Future Systems
- Deckbuilder variant of task system
- Office upgrades visible in tilemap
- Agent Eddie unlockable companion
- Procedural task room layouts
- Translations of Fog speech via Insight

---

## Interaction Prompt Standard

All interact prompts (such as the floating [E] icon) must appear near the player character's body (typically above the head), not near the object being interacted with. This ensures a consistent and intuitive user experience across all interactable elements in the game.

- Use the global UI function `GlobalUI.show_interact_popup_near_player(player)` to display the prompt.
- Do not position prompts near the interactable object itself.
- This standard applies to all in-world interactions, including puzzles, doors, NPCs, and special objects.

**Rationale:**
- Keeps player focus on their character.
- Prevents confusion about which object is interactable.
- Maintains a consistent look and feel throughout the game.

> See also: [Style Guide](STYLE_GUIDE.md) for additional UI/UX conventions.
