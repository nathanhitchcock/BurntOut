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
	# Connect MachineButton if present
	var machine_button = get_node_or_null("MachineButton")
	if machine_button:
		machine_button.pressed.connect(_on_machine_button_pressed)

func _on_machine_button_pressed():
	# Find the ProductivityMachine node in the scene
	var machine = get_tree().current_scene.get_node_or_null("ProductivityMachine")
	if machine and machine.has_method("_spend_sprint_point"):
		machine._spend_sprint_point()
	else:
		print("[UpgradeCafe] ProductivityMachine not found or missing _spend_sprint_point method.")

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
		_show_sprint_points_label()

func _show_sprint_points_label():
	var label = Label.new()
	label.text = "Sprint Points allocated to self are withheld from the machine."
	label.modulate = Color(1, 1, 0.8, 0.92) # Slightly yellow for distinction
	label.add_theme_font_size_override("font_size", 40)
	label.position = Vector2(-150, 300) # Above the shop UI, adjust as needed
	label.z_index = 100
	add_child(label)
	# Fade in, then fade out after a delay
	label.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.92, 0.7)
	tween.tween_property(label, "modulate:a", 0, 2.5).set_delay(3.5)
	tween.finished.connect(label.queue_free)

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
