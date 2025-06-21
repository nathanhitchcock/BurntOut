extends Area2D

@export var swing_duration := 0.2
@export var swing_arc_degrees := 90.0
var swinging := false
var initial_rotation: float
var impact_flash: Sprite2D

func _ready():
	print("[HAMMER] _ready() called - Script is running!")
	set_process(true)
	$CollisionShape2D.disabled = true
	initial_rotation = rotation
	print("[HAMMER] Initial rotation:", rad_to_deg(initial_rotation), " degrees")
	print("[HAMMER] Hammer ready to swing!")
	
	# Create impact flash effect
	setup_impact_flash()

func _process(delta):
	if Input.is_action_just_pressed("swing_hammer"):
		print("[HAMMER] Swing input detected!")
		if not swinging:
			swing()
		else:
			print("[HAMMER] Already swinging, ignoring")
	
	# Debug: Check every few seconds if we're still alive
	if Engine.get_process_frames() % 180 == 0:  # Every 3 seconds at 60fps
		print("[HAMMER] Still processing... Position:", position, " Visible:", visible)

func setup_impact_flash():
	# Create a circular impact flash effect
	impact_flash = Sprite2D.new()
	add_child(impact_flash)
	
	# Create a simple white circle texture for the flash
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var center = Vector2(32, 32)
	var radius = 30.0
	
	# Draw a bright orange/yellow circle with some transparency
	for x in range(64):
		for y in range(64):
			var distance = center.distance_to(Vector2(x, y))
			if distance <= radius:
				var alpha = 1.0 - (distance / radius) * 0.5  # Fade from center, less fade for visibility
				image.set_pixel(x, y, Color(1.0, 0.5, 0.0, alpha))  # Bright orange
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	impact_flash.texture = texture
	
	# Position the flash at the impact point (bottom of hammer when slammed)
	impact_flash.position = Vector2(-50, 25)  # Moved 25 pixels to the left
	impact_flash.scale = Vector2(0.5, 0.5)  # Start small
	impact_flash.modulate.a = 0.0  # Start invisible
	impact_flash.z_index = 10  # In front of everything for visibility

func swing():
	print("[HAMMER] Starting SLAM swing!")
	swinging = true
	# Keep collision disabled during wind-up and slam
	$CollisionShape2D.disabled = true
	
	# AGGRESSIVE domino slam - top hits the floor!
	var tween = create_tween()
	var initial_position = position
	var initial_scale = scale
	
	# Much more dramatic fall
	var fall_scale = 0.2  # Squish down to 20% height (way more dramatic)
	var slam_distance = 150.0  # Much farther down so top hits floor
	
	# Set parallel mode for simultaneous animations
	tween.set_parallel(true)
	
	# Quick wind-up
	tween.tween_property(self, "position", initial_position + Vector2(0, -15), swing_duration * 0.1).set_ease(Tween.EASE_OUT)
	
	# Wait for wind-up to finish
	await get_tree().create_timer(swing_duration * 0.1).timeout
	
	# Create new tween for slam
	var slam_tween = create_tween()
	slam_tween.set_parallel(true)
	
	# SLAM DOWN - aggressive squish and fast downward motion
	slam_tween.tween_property(self, "scale", Vector2(initial_scale.x, initial_scale.y * fall_scale), swing_duration * 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	slam_tween.tween_property(self, "position", initial_position + Vector2(0, slam_distance), swing_duration * 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	
	# Wait for slam
	await get_tree().create_timer(swing_duration * 0.3).timeout
	
	# ENABLE COLLISION AT IMPACT MOMENT!
	print("[HAMMER] IMPACT - Collision enabled!")
	$CollisionShape2D.disabled = false
	
	# TRIGGER IMPACT FLASH!
	show_impact_flash()
	
	# IMPACT SHAKE EFFECT!
	var shake_tween = create_tween()
	var camera = get_viewport().get_camera_2d()
	var original_offset = Vector2.ZERO
	if camera:
		original_offset = camera.offset
	
	# Multiple quick shakes for impact
	var shake_intensity = 8.0
	var shake_duration = 0.08  # Slightly faster shake
	
	for i in range(4):  # 4 quick shakes instead of 5
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		if camera:
			shake_tween.tween_property(camera, "offset", original_offset + shake_offset, shake_duration / 4)
		await get_tree().create_timer(shake_duration / 4).timeout
	
	# Reset camera
	if camera:
		camera.offset = original_offset
	
	# DISABLE COLLISION AFTER IMPACT WINDOW
	print("[HAMMER] Impact window over - Collision disabled!")
	$CollisionShape2D.disabled = true
	
	# Brief pause at impact (reduced since we had shake time)
	await get_tree().create_timer(0.02).timeout
	
	# Create new tween for recovery
	var recovery_tween = create_tween()
	recovery_tween.set_parallel(true)
	
	# Fast recovery - bounce back up
	recovery_tween.tween_property(self, "scale", initial_scale, swing_duration * 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	recovery_tween.tween_property(self, "position", initial_position, swing_duration * 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	
	# Wait for recovery
	await recovery_tween.finished
	
	# Force cleanup
	position = initial_position
	scale = initial_scale
	# Ensure collision is disabled at end
	$CollisionShape2D.disabled = true
	swinging = false
	print("[HAMMER] SLAM complete!")

func show_impact_flash():
	if not impact_flash:
		return
	
	# Quick bright flash that fades out
	var flash_tween = create_tween()
	flash_tween.set_parallel(true)
	
	# Much brighter flash with high contrast
	impact_flash.modulate = Color(1.2, 0.8, 0.0, 1.0)  # Bright orange, slightly oversaturated
	impact_flash.scale = Vector2(0.2, 0.2)  # Start smaller for more dramatic growth
	
	# Scale up and fade out simultaneously - longer duration for visibility
	flash_tween.tween_property(impact_flash, "scale", Vector2(1.5, 1.5), 0.2).set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(impact_flash, "modulate:a", 0.0, 0.2).set_ease(Tween.EASE_OUT)
	
	print("[HAMMER] Impact flash triggered!")
