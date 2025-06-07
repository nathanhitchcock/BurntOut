extends Node2D

var player_in_range := false

func _ready():
	$ScrumDSUBoardArea.body_entered.connect(_on_area_body_entered)
	$ScrumDSUBoardArea.body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		print("Player entered DSU area!")

func _on_area_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		print("Player is in range of the DSU Board!")
func _process(_delta):
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		print("Interacted with the DSU Board!")
		get_tree().change_scene_to_file("res://scenes/CORP/toggle_room/toggle_room.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
