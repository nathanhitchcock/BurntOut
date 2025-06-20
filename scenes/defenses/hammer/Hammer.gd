extends Area2D

@export var swing_duration := 0.3
@export var swing_arc_degrees := 90.0
var swinging := false
var initial_rotation: float

func _ready():
	print("[HAMMER] _ready() called - Script is running!")
	set_process(true)
	$CollisionShape2D.disabled = true
	initial_rotation = rotation
	print("[HAMMER] Using scene pivot point - Initial rotation:", rad_to_deg(initial_rotation), " degrees")
	print("[HAMMER] Node position:", position, " (this is where it rotates around)")
	print("[HAMMER] Node is visible:", visible)
	print("[HAMMER] Node is in scene tree:", is_inside_tree())

func _process(delta):
	if Input.is_action_just_pressed("swing_hammer"):
		print("[HAMMER] Swing key pressed! Currently swinging:", swinging)
		if not swinging:
			swing()
		else:
			print("[HAMMER] Already swinging, ignoring input")

func swing():
	print("[HAMMER] Starting swing!")
	swinging = true
	$CollisionShape2D.disabled = false
	
	# Play swing animation if AnimatedSprite2D exists
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("swing")
	
	# Simple rotation - just rotate the whole hammer around its center
	var tween = create_tween()
	
	# Clockwise swing motion
	var start_angle = initial_rotation - deg_to_rad(swing_arc_degrees / 4)  # Start raised
	var end_angle = initial_rotation + deg_to_rad(swing_arc_degrees * 3 / 4)  # Swing down
	
	# Just rotate around the scene's pivot point (node center)
	tween.tween_method(
		func(angle): 
			rotation = angle
			print("[HAMMER] Rotating to:", rad_to_deg(angle), " degrees"),
		start_angle,
		end_angle,
		swing_duration
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	
	# Reset rotation
	tween.tween_method(
		func(angle): rotation = angle,
		end_angle,
		initial_rotation,
		swing_duration * 0.3
	).set_delay(swing_duration * 0.7).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	await get_tree().create_timer(swing_duration).timeout
	
	# Force reset
	rotation = initial_rotation
	$CollisionShape2D.disabled = true
	swinging = false
