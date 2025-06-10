extends Area2D

@export var target_scene: String = "res://scenes/CORP/corp_office.tscn"

var player_in_range := false
var interact_prompt_shown := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		interact_prompt_shown = false

func _process(_delta):
	if player_in_range:
		if not interact_prompt_shown:
			var player = get_tree().current_scene.get_node_or_null("Player")
			if player:
				GlobalUI.show_interact_popup_near_player(player)
			interact_prompt_shown = true
		if Input.is_action_just_pressed("ui_accept"):
			if has_node("/root/player_data"):
				var player = get_tree().current_scene.get_node_or_null("Player")
				if player:
					get_node("/root/player_data").position = player.global_position
			get_tree().change_scene_to_file(target_scene)
	else:
		interact_prompt_shown = false
