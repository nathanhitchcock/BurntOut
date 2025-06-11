extends CharacterBody2D

var speed := 400.0
var burnout_level: int = 0 # 0 = no burnout, 1-5 = burnout stages
# Remove map_bounds variable entirely; use collision shapes for movement boundaries

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var fire_trail: GPUParticles2D = $FireTrail if has_node("FireTrail") else null
@onready var player_data = get_node_or_null("/root/player_data")
@onready var burnout_label = $BurnoutLabel if has_node("BurnoutLabel") else null

func _physics_process(delta):
	var input = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"):
		input.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_down"):
		input.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_up"):
		input.y -= 1
	if input.length() > 0:
		input = input.normalized()
		velocity = input * speed
		if animated_sprite:
			animated_sprite.play("walk")
		if fire_trail:
			fire_trail.emitting = true
	else:
		velocity = Vector2.ZERO
		if animated_sprite:
			animated_sprite.stop()
		if fire_trail:
			fire_trail.emitting = false
	move_and_slide()
	# No code-based clamping; rely on collision shapes for movement boundaries

func save_to_player_data():
	if player_data:
		player_data.position = position
		if has_node("HealthBar"):
			player_data.health = get_node("HealthBar").value
		print("[Player] [SAVE] HealthBar value:", get_node("HealthBar").value)
		print("[Player] [SAVE] player_data.health:", player_data.health)
		print("[Player] Saved position and health to player_data: %s, %s" % [str(position), str(player_data.health)])
		print("[Player] player_data singleton ref:", player_data)

func load_from_player_data():
	if player_data:
		if player_data.position:
			position = player_data.position
		if has_node("HealthBar"):
			var bar = get_node("HealthBar")
			if player_data.health != null:
				bar.value = player_data.health
				print("[Player] [LOAD] Loaded health from player_data:", player_data.health)
			else:
				bar.value = 100 # Only set to 100 if no value is present
				player_data.health = 100
				print("[Player] [LOAD] No health in player_data, defaulting to 100")
		print("[Player] Loaded position and health from player_data: %s, %s" % [str(player_data.position), str(player_data.health)])
		print("[Player] player_data singleton ref:", player_data)

func _ready():
	burnout_level = player_data.burnout_level if player_data and player_data.burnout_level != null else 0
	load_from_player_data()
	if burnout_label:
		burnout_label.visible = true
		burnout_label.text = "Burnout: %d" % burnout_level

func _process(delta):
	# print("[Player] _process running")  # Commented out to reduce console spam
	if Input.is_action_just_pressed("ui_debug_save"):
		save_to_player_data()
	if Input.is_action_just_pressed("ui_debug_load"):
		load_from_player_data()
	if burnout_label:
		burnout_label.text = "Burnout: %d" % burnout_level

func show_floating_feedback(text: String, color: Color = Color(0.2, 0.9, 0.2, 1)):
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.global_position = global_position + Vector2(0, -40)
	label.z_index = 100
	get_tree().current_scene.add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0, 2.0)
	tween.tween_property(label, "position:y", label.position.y - 30, 2.0)
	tween.finished.connect(label.queue_free)

func show_damage_popup(amount: int):
	var label = Label.new()
	label.text = "-" + str(amount)
	label.modulate = Color("f24646")  # Red for damage
	label.global_position = global_position + Vector2(0, -60)
	label.z_index = 100
	label.add_theme_font_size_override("font_size", 24)
	get_tree().current_scene.add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0, 1.2)
	tween.tween_property(label, "position:y", label.position.y - 20, 1.2)
	tween.finished.connect(label.queue_free)

func take_damage(amount: int) -> void:
	if has_node("HealthBar"):
		var bar = get_node("HealthBar")
		bar.value = max(bar.value - amount, bar.min_value)
		save_to_player_data()
		show_damage_popup(amount)
		if has_node("/root/GlobalAudio/Player/PlayerDamageSound"):
			var sfx = get_node("/root/GlobalAudio/Player/PlayerDamageSound")
			sfx.stop()
			sfx.play()
		else:
			print("[Player] ERROR: /root/GlobalAudio/Player/PlayerDamageSound not found!")

		if bar.value <= bar.min_value:
			if player_data:
				player_data.burnout_level = clamp(player_data.burnout_level + 1, 1, 5)
				burnout_level = player_data.burnout_level
				player_data.health = 0
				player_data.position = Vector2.ZERO
				get_tree().change_scene_to_file("res://scenes/CORP/skyline/SkylineWatch.tscn")
				return

	if animated_sprite:
		var original_pos = animated_sprite.position
		var tween = create_tween()
		tween.tween_property(animated_sprite, "position:x", original_pos.x + 10, 0.05)
		tween.tween_property(animated_sprite, "position:x", original_pos.x - 10, 0.05)
		tween.tween_property(animated_sprite, "position:x", original_pos.x, 0.05)

	if animated_sprite:
		var flash_tween = create_tween()
		flash_tween.tween_property(animated_sprite, "modulate", Color(1,1,1), 0.05)
		flash_tween.tween_property(animated_sprite, "modulate", Color(1,1,1,0.5), 0.05)
		flash_tween.tween_property(animated_sprite, "modulate", Color(1,1,1,1), 0.1)

func heal(amount: int):
	if has_node("HealthBar"):
		var bar = get_node("HealthBar")
		bar.value = min(bar.value + amount, bar.max_value)
		save_to_player_data() # Save health after healing
