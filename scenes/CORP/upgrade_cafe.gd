extends Node2D

@onready var shop_ui = get_node("../UpgradeShopUI")

var player_in_range := false
var interact_prompt_shown := false

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	if shop_ui:
		shop_ui.visible = false
		shop_ui.hide()
		# Hide all children as well
		for child in shop_ui.get_children():
			if child is CanvasLayer or child is VBoxContainer:
				child.visible = false
				child.hide()

func _on_body_entered(body):
	if body.name == "Player" and shop_ui:
		print("[UpgradeCafe] Player has entered the cafe area.")
		shop_ui.show()
		shop_ui.visible = true
		# Show all children as well
		for child in shop_ui.get_children():
			if child is CanvasLayer or child is VBoxContainer:
				child.visible = true
				child.show()
		player_in_range = true
		if has_node("/root/GlobalUI"):
			get_node("/root/GlobalUI").show_interact_prompt(true)

func _on_body_exited(body):
	if body.name == "Player" and shop_ui:
		print("[UpgradeCafe] Player has exited the cafe area.")
		shop_ui.hide()
		shop_ui.visible = false
		for child in shop_ui.get_children():
			if child is CanvasLayer or child is VBoxContainer:
				child.visible = false
				child.hide()
		player_in_range = false
		if has_node("/root/GlobalUI"):
			get_node("/root/GlobalUI").show_interact_prompt(false)
