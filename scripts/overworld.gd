extends Node2D

# Handles area selection and scene switching for the overworld

func _ready():
	$MainGameArea.connect("input_event", Callable(self, "_on_main_game_area_input"))
	$TestingGroundArea.connect("input_event", Callable(self, "_on_testing_ground_area_input"))
	
	# Optional: Print to confirm script is running
	print("[Overworld] Ready. Clickable areas connected.")

func save_player_state_before_scene_change():
	var player = get_node_or_null("Player")
	if player and player.has_method("save_to_player_data"):
		player.save_to_player_data()

func _on_main_game_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		save_player_state_before_scene_change()
		get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_testing_ground_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		save_player_state_before_scene_change()
		get_tree().change_scene_to_file("res://scenes/TestingGround.tscn")
