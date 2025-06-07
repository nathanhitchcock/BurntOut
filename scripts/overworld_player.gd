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
		print("[Player] Saved position to player_data: %s" % str(position))
		print("[Player] player_data singleton ref:", player_data)

func load_from_player_data():
	if player_data and player_data.position:
		position = player_data.position
		print("[Player] Loaded position from player_data: %s" % str(player_data.position))
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
