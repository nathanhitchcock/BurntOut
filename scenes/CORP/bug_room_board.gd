extends Node2D

var player_in_range := false
var interact_prompt_shown := false

func _ready():
	$BugRoomBoardArea.body_entered.connect(_on_area_body_entered)
	$BugRoomBoardArea.body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		print("Player entered Bug Room area!")

func _on_area_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		print("Player left Bug Room area!")

func _process(_delta):
	if player_in_range:
		if not interact_prompt_shown:
			var player = get_tree().current_scene.get_node_or_null("Player")
			if player:
				GlobalUI.show_interact_popup_near_player(player)
			interact_prompt_shown = true
	else:
		interact_prompt_shown = false
	
	if player_in_range and Input.is_action_just_pressed("ui_accept"):
		print("Interacted with the Bug Room Board!")
		get_tree().change_scene_to_file("res://scenes/CORP/bug_smash/bug_smash.tscn")
