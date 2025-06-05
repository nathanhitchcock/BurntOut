extends Node2D

# Handles area selection and scene switching for the overworld

func _ready():
	$MainGameArea.connect("input_event", Callable(self, "_on_main_game_area_input"))
	$TestingGroundArea.connect("input_event", Callable(self, "_on_testing_ground_area_input"))
	
	# Optional: Print to confirm script is running
	print("[Overworld] Ready. Clickable areas connected.")

func _on_main_game_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_testing_ground_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		get_tree().change_scene_to_file("res://scenes/TestingGround.tscn")
