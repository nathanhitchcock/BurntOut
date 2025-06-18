extends Control

func _ready():
	if has_node("/root/GlobalUI"):
		get_node("/root/GlobalUI").visible = false
	elif has_node("res://scripts/ui/global_ui.gd"):
		get_node("/root/GlobalUI").visible = false
	else:
		pass

func _on_begin_sprint_pressed() -> void:
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	if has_node("/root/GlobalUI"):
		get_node("/root/GlobalUI").visible = true
	else:
		pass
	get_tree().change_scene_to_file("res://scenes/CORP/corp_office.tscn")
