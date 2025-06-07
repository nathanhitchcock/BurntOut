extends Node2D

func _on_begin_sprint_pressed() -> void:
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/CORP/corp_office.tscn")
