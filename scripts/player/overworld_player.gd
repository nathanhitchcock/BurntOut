extends CharacterBody2D

var speed := 220.0 # Comfortable walk speed
var burnout_level: int = 0 # 0 = no burnout, 1-5 = burnout stages

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var fire_trail: GPUParticles2D = $FireTrail if has_node("FireTrail") else null
@onready var player_data = get_node_or_null("/root/player_data")
@onready var burnout_label = $BurnoutLabel if has_node("BurnoutLabel") else null
@onready var camera: Camera2D = $Camera2D if has_node("Camera2D") else null
@onready var shield_bar: ProgressBar = null

var camera_zoom_in := Vector2(1.5, 1.5)
var camera_zoom_out := Vector2(2.5, 2.5)
var camera_zoom_duration := 1.5 # Slower zoom for smoother effect
var _is_zoomed_in := false
@export var speed_multiplier: float = 1.0

func _ready():
	burnout_level = player_data.burnout_level if player_data and player_data.burnout_level != null else 0
	# Start player with 20 sprint points for testing
	if player_data:
		player_data.sprint_points = 20
	# Apply speed multiplier (editable in Inspector)
	speed *= speed_multiplier
	load_from_player_data()
	if burnout_label:
		burnout_label.visible = true
		burnout_label.text = "Burnout: %d" % burnout_level
	if camera:
		camera.make_current()
		camera.zoom = camera_zoom_out
	shield_bar = null
	if has_node("/root/GlobalUI"):
		var global_ui = get_node("/root/GlobalUI")
		if global_ui.has_node("CanvasLayer/Control/ShieldBar"):
			shield_bar = global_ui.get_node("CanvasLayer/Control/ShieldBar")

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
	var moving = input.length() > 0
	if moving:
		input = input.normalized()
		velocity = input * speed
		if animated_sprite:
			animated_sprite.play("walk")
		if fire_trail:
			fire_trail.emitting = true
		if camera and not _is_zoomed_in:
			_is_zoomed_in = true
			var tween = create_tween()
			tween.tween_property(camera, "zoom", camera_zoom_in, camera_zoom_duration)
	else:
		velocity = Vector2.ZERO
		if animated_sprite:
			animated_sprite.stop()
		if fire_trail:
			fire_trail.emitting = false
		if camera and _is_zoomed_in:
			_is_zoomed_in = false
			var tween = create_tween()
			tween.tween_property(camera, "zoom", camera_zoom_out, camera_zoom_duration)
	move_and_slide()
	# No code-based clamping; rely on collision shapes for movement boundaries

func save_to_player_data():
	if player_data:
		player_data.position = position
		player_data.health = player_data.health # Already up to date elsewhere
		print("[Player] [SAVE] player_data.health:", player_data.health)
		print("[Player] Saved position and health to player_data: %s, %s" % [str(position), str(player_data.health)])
		print("[Player] player_data singleton ref:", player_data)

func load_from_player_data():
	if player_data:
		if player_data.position:
			position = player_data.position
		if player_data.health != null:
			player_data.health = player_data.health
			if has_node("/root/GlobalUI"):
				get_node("/root/GlobalUI")._update_health_bar()
		# No local has_shield or shield_hp, always use player_data.has_shield and player_data.shield_hp
	else:
		player_data.health = 100
		if has_node("/root/GlobalUI"):
			get_node("/root/GlobalUI")._update_health_bar()
	print("[Player] Loaded position and health from player_data: %s, %s" % [str(player_data.position), str(player_data.health)])
	print("[Player] player_data singleton ref:", player_data)

func _process(delta):
	# print("[Player] _process running")  # Commented out to reduce console spam
	if Input.is_action_just_pressed("ui_debug_save"):
		save_to_player_data()
	if Input.is_action_just_pressed("ui_debug_load"):
		load_from_player_data()
	if burnout_label:
		burnout_label.text = "Burnout: %d" % burnout_level

func _update_shield_bar():
	if shield_bar:
		if player_data and player_data.shield_hp > 0:
			shield_bar.value = player_data.shield_hp
			shield_bar.visible = true
		else:
			shield_bar.value = 0
			shield_bar.visible = false

func show_floating_feedback(text: String, color: Color, offset := Vector2.ZERO):
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.global_position = global_position + Vector2(0, -60) + offset
	label.z_index = 100
	label.add_theme_font_size_override("font_size", 24)
	get_tree().current_scene.add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0, 1.2)
	tween.tween_property(label, "position:y", label.position.y - 20, 1.2)
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
	if player_data:
		# Shield acts as temporary HP
		if player_data.shield_hp > 0:
			var absorbed = min(amount, player_data.shield_hp)
			player_data.shield_hp -= absorbed
			amount -= absorbed
			show_floating_feedback("Shield Absorbed %d!" % absorbed, Color(1,1,0.2))
			_update_shield_bar()
			if player_data.shield_hp <= 0:
				player_data.shield_hp = 0
				# Shift 'Shield Broken!' text down by 20 pixels to avoid overlap
				show_floating_feedback("Shield Broken!", Color(1,0.5,0.2), Vector2(0, 20))
			if amount <= 0:
				return
		player_data.health = max(player_data.health - amount, 0)
		save_to_player_data()
		if has_node("/root/GlobalUI"):
			get_node("/root/GlobalUI")._update_health_bar()
		show_damage_popup(amount)
		if has_node("/root/GlobalAudio/Player/PlayerDamageSound"):
			var sfx = get_node("/root/GlobalAudio/Player/PlayerDamageSound")
			sfx.stop()
			sfx.play()
		else:
			print("[Player] ERROR: /root/GlobalAudio/Player/PlayerDamageSound not found!")

		if player_data.health <= 0:
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
	if player_data:
		player_data.health = min(player_data.health + amount, 100)
		save_to_player_data()
		if has_node("/root/GlobalUI"):
			get_node("/root/GlobalUI")._update_health_bar()
