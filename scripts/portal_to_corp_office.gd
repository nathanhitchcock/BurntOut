extends Area2D

@export var target_scene: String = "res://scenes/CORP/corp_office.tscn"

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file(target_scene)
