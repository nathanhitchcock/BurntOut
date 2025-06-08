extends Control

@onready var player_data = get_node("/root/player_data")
@onready var player = null

func _ready():
	if not player:
		player = get_tree().current_scene.get_node_or_null("Player")
	$CanvasLayer/VBoxContainer/CoffeeButton.pressed.connect(func(): purchase_upgrade(0))
	$CanvasLayer/VBoxContainer/ShieldButton.pressed.connect(func(): purchase_upgrade(1))
	$CanvasLayer/VBoxContainer/CloseButton.pressed.connect(func(): self.visible = false) # If you have a close button
	update_shop_ui()

func purchase_upgrade(index):
	pass # TODO: Implement upgrade logic

func update_shop_ui():
	pass # TODO: Implement UI update logic
