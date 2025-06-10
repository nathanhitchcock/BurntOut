extends Node

var position: Vector2 = Vector2.ZERO
var health: int = 100 # Add this line for persistent health
var inventory: Array = []
var gold: int = 0
var loop_progression: int = 0
var sprint_points: int = 0 # Sprint points persist across all scenes
var portal_to_corp_used: bool = false # Set true when using portal, checked on load
# Add any other persistent fields you need
