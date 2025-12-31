extends Node

var position: Vector2 = Vector2.ZERO
var health: int = 100 # Add this line for persistent health
var inventory: Array = []
var gold: int = 0
var loop_progression: int = 0
var sprint_points: int = 0 # Sprint points persist across all scenes (set to 20 for testing)
var machine_points: int = 0 # Persistent machine points for ProductivityMachine
var portal_to_corp_used: bool = false # Set true when using portal, checked on load
var burnout_level: int = 0 # Persistent burnout tracker (0-5)
var productivity_progress: float = 0.0 # Persistent progress for ProductivityMachine
var has_shield: bool = false # Persistent shield state
var shield_hp: int = 0 # Persistent shield HP
# Add any other persistent fields you need

signal puzzle_solved(progress_amount)

# Reset all player state to initial defaults
func reset() -> void:
	position = Vector2.ZERO
	health = 100
	inventory = []
	gold = 0
	loop_progression = 0
	sprint_points = 0
	machine_points = 0
	portal_to_corp_used = false
	burnout_level = 0
	productivity_progress = 0.0
	has_shield = false
	shield_hp = 0
