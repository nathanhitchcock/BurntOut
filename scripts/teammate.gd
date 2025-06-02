class_name Teammate
extends Node2D

var morale = 1000
var max_morale = 100
var revive_cost = 2
var home_position: Vector2
var is_burned_out: bool = false
var original_scale: Vector2
@export var is_executive_mode: bool = false  # Start with real work!
@onready var toggle_button_default_scale = $Sprite2D/ToggleWorkButton.scale

func _ready():
	await get_tree().process_frame
	home_position = global_position
	# print("Teammate home position set to:", home_position)
	original_scale = scale
	if has_node("Sprite2D/ToggleWorkButton"):
		var btn = $Sprite2D/ToggleWorkButton
		btn.visible = false  # reinforce off-state
		btn.disabled = true
		
func get_target_position() -> Vector2:
	return $Sprite2D/TargetPoint.global_position

func lower_morale(amount):
	if morale <= 0:
		return # already burnt out
	
	shake()	
	morale -= amount
	morale = clamp(morale, 0, 100)
	$Sprite2D/MoraleBar.value = morale
	show_damage_popup("-" + str(amount))
	
	if morale <= 0:
		# print("Teammate has burned out!")
		modulate = Color(0.3, 0.3, 0.3, 1.0)  # darken to signal burnout
		$Sprite2D/MoraleBar.visible = false
		$Sprite2D/ReviveButton.visible = true
		is_burned_out = true
		cleanup_nearby_defenses(home_position)
		
func cleanup_nearby_defenses(center_position: Vector2):
	# print("Cleaning defenses near ", center_position)
	var radius = 200
	for defense in get_tree().get_nodes_in_group("defenses"):
		var distance = defense.global_position.distance_to(center_position)
		if distance <= radius:
			# print("Removing defense at ", defense.global_position)
			defense.queue_free()

func revive():
	if  not is_burned_out:
		return
	morale = 50
	$Sprite2D/MoraleBar.value = morale
	modulate = Color(1, 1, 1, 1)  # restore full brightness
	$Sprite2D/MoraleBar.visible = true
	$Sprite2D/ReviveButton.visible = false
	is_burned_out = false 
	
		# Add bounce squish on revive
	var tween = create_tween()
	# Reset to normal scale before bounce
	scale = original_scale
	tween.tween_property(self, "scale", original_scale * Vector2(1.2, 0.8), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", original_scale * Vector2(0.9, 1.1), 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", original_scale, 0.08).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	get_node("/root/Main/Audio/ReviveSound").play()
	
	# print("Teammate revived!")

func restore_morale(amount):
	morale += amount
	morale = clamp(morale, 0, max_morale)
	update_morale_bar()
	# print(name, "restored", amount, "morale")

func update_morale_bar():
	if has_node("MoraleBar"):
		$MoraleBar.value = morale

func shake():
	var original_pos = position
	var offset = 6
	var duration = 0.05

	var tween = create_tween()
	tween.tween_property(self, "position", original_pos + Vector2(offset, 0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", original_pos - Vector2(offset, 0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", original_pos, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	
# func update_toggle_label():
	# if has_node("ToggleWorkButton"):
		# $ToggleWorkButton.text = "Executive" if is_executive_mode else "Customer"

func show_damage_popup(text: String):
	var label = Label.new()
	label.text = text
	label.modulate = Color("f24646")  # 🔴 red for damage
	label.global_position = global_position + Vector2(65, -70)  # shift right + up
	label.z_index = 100

	# 💥 Make it bigger for impact
	label.add_theme_font_size_override("font_size", 24)  # default is usually ~14-16

	get_tree().current_scene.add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0, 1.0)
	tween.tween_property(label, "position:y", label.position.y - 20, 1.0)
	await tween.finished
	label.queue_free()

func _on_ToggleWorkButton_toggled(pressed: bool) -> void:
	is_executive_mode = pressed
	print(name, "now working on", "EXEC" if pressed else "CSTM")

func lock_toggle():
	if has_node("Sprite2D/ToggleWorkButton"):
		var btn = get_node("Sprite2D/ToggleWorkButton")
		btn.disabled = true
		btn.visible = false
		btn.modulate = Color(0.5, 0.5, 0.5)

func unlock_toggle():
	if has_node("Sprite2D/ToggleWorkButton"):
		var btn = $Sprite2D/ToggleWorkButton
		btn.visible = true
		btn.disabled = false
		btn.button_pressed = is_executive_mode
		btn.modulate = Color(1, 1, 1)  # ✅ Reset color here
		btn.modulate.a = 0.0
		btn.scale = toggle_button_default_scale * 0.7

		var tween = create_tween()
		tween.tween_property(btn, "modulate:a", 1.0, 0.3)
		tween.tween_property(btn, "scale", toggle_button_default_scale, 0.3).set_ease(Tween.EASE_OUT) 

func sync_toggle_state():
	if has_node("Sprite2D/ToggleWorkButton"):
		var btn = get_node("Sprite2D/ToggleWorkButton")
		btn.button_pressed = is_executive_mode
