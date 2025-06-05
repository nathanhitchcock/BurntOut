extends Node2D

func _ready():
	$ContinueButton.pressed.connect(_on_continue_pressed)

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")
