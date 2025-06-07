extends CharacterBody2D

var speed := 400.0
# Set your map boundaries here (adjust as needed)
var map_bounds := Rect2(Vector2(0, 0), Vector2(1024, 768))

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var fire_trail: GPUParticles2D = $FireTrail if has_node("FireTrail") else null
@onready var player_data = get_node_or_null("/root/player_data")

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
	# Clamp position to map bounds, accounting for sprite height so player can't walk off the bottom
	var sprite_height := 0
	if animated_sprite and animated_sprite.sprite_frames:
		var anim = animated_sprite.animation
		var frame = animated_sprite.frame
		var tex = animated_sprite.sprite_frames.get_frame_texture(anim, frame)
		if tex:
			sprite_height = tex.get_height() * animated_sprite.scale.y
	# If no animated_sprite, fallback to 0
	position.x = clamp(position.x, map_bounds.position.x, map_bounds.position.x + map_bounds.size.x)
	position.y = clamp(position.y, map_bounds.position.y, map_bounds.position.y + map_bounds.size.y - sprite_height)

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
	load_from_player_data()

func _process(delta):
	# print("[Player] _process running")  # Commented out to reduce console spam
	if Input.is_action_just_pressed("ui_debug_save"):
		save_to_player_data()
	if Input.is_action_just_pressed("ui_debug_load"):
		load_from_player_data()

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

func take_damage(amount: int):
	# Reduce health if you have a health variable or bar
	if has_node("HealthBar"):
		var bar = get_node("HealthBar")
		bar.value = max(bar.value - amount, bar.min_value)
		save_to_player_data() # Save health after taking damage

	# Twitch (quick shake)
	if animated_sprite:
		var original_pos = animated_sprite.position
		var tween = create_tween()
		tween.tween_property(animated_sprite, "position:x", original_pos.x + 10, 0.05)
		tween.tween_property(animated_sprite, "position:x", original_pos.x - 10, 0.05)
		tween.tween_property(animated_sprite, "position:x", original_pos.x, 0.05)

	# Flash (white flash)
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
