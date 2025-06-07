extends Node2D

@onready var shop_ui = get_node("../UpgradeShopUI")

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

func _on_body_exited(body):
	if body.name == "Player" and shop_ui:
		print("[UpgradeCafe] Player has exited the cafe area.")
		shop_ui.hide()
		shop_ui.visible = false
		for child in shop_ui.get_children():
			if child is CanvasLayer or child is VBoxContainer:
				child.visible = false
				child.hide()
