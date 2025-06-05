extends CharacterBody2D

var speed := 400.0
# Set your map boundaries here (adjust as needed)
var map_bounds := Rect2(Vector2(0, 0), Vector2(1024, 768))

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null
@onready var fire_trail: GPUParticles2D = $FireTrail if has_node("FireTrail") else null

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
	# Clamp position to map bounds
	position.x = clamp(position.x, map_bounds.position.x, map_bounds.position.x + map_bounds.size.x)
	position.y = clamp(position.y, map_bounds.position.y, map_bounds.position.y + map_bounds.size.y)
