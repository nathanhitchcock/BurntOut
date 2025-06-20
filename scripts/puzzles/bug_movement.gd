extends CharacterBody2D

@export var walk_speed := 40.0
@export var walk_radius := 10000.0
@export var bug_type := "basic"
@export var hit_points := 1
@export var smash_points := 10 # Points awarded for smashing this bug
@export var small_bug_scene: PackedScene = preload("res://scenes/puzzles/bug_small.tscn")
var origin := Vector2.ZERO
var direction := Vector2.ZERO
var alive := true
var skitter_timer := 0.0
var skitter_interval := 0.2 + randf() * 0.4 # Change direction every 0.2-0.6s
var burst_timer := 0.0
var burst_duration := 0.1
var burst_speed := 120.0
var is_bursting := false
var speed_ramp_timer := 0.0
var immunity_time := 0.0  # Time of immunity after spawning
var immunity_duration := 0.3  # Immunity duration in seconds
const SPEED_RAMP_INTERVAL := 2.0 # seconds
const SPEED_RAMP_AMOUNT := 10.0 # increase per interval

func register_with_manager():
	var manager = get_tree().current_scene.get_node_or_null("BugSmash")
	if manager and manager.has_method("register_bug"):
		manager.register_bug(self)

func _ready():
	print("[BUG] _ready called for bug:", self, " at position:", global_position)
	origin = global_position
	pick_new_direction()
	set_process(true)
	register_with_manager()
	
	# Set immunity for small bugs to prevent immediate smashing
	if self.has_meta("is_small_bug"):
		immunity_time = immunity_duration
		print("[BUG] Small bug spawned with", immunity_duration, "s immunity")
	
	# Connect Area2D collision
	if has_node("Area2D"):
		$Area2D.collision_layer = 1
		$Area2D.collision_mask = 1
		$Area2D.connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	if not alive:
		return
	
	# Handle immunity countdown
	if immunity_time > 0:
		immunity_time -= delta
		if immunity_time <= 0:
			print("[BUG] Immunity expired for bug:", self)
	
	# Speed ramp logic
	speed_ramp_timer += delta
	if speed_ramp_timer > SPEED_RAMP_INTERVAL:
		walk_speed += SPEED_RAMP_AMOUNT
		burst_speed += SPEED_RAMP_AMOUNT
		speed_ramp_timer = 0.0
	# Skittering logic
	skitter_timer += delta
	if skitter_timer > skitter_interval:
		pick_new_direction()
		skitter_timer = 0.0
		skitter_interval = 0.2 + randf() * 0.4
		# 20% chance to burst
		if randf() < 0.2:
			is_bursting = true
			burst_timer = 0.0
	# Burst movement
	var speed = walk_speed
	if is_bursting:
		burst_timer += delta
		speed = burst_speed
		if burst_timer > burst_duration:
			is_bursting = false
	# Move in current direction using move_and_collide for wall bounce
	var jitter = Vector2(randf() * 4.0 - 2.0, randf() * 4.0 - 2.0) # jitter effect
	var velocity = direction * speed + jitter
	var collision = move_and_collide(velocity * delta)
	if collision:
		# Bounce: reflect direction
		direction = direction.bounce(collision.get_normal())
		# Move bug out of wall
		global_position += collision.get_normal() * 2.0
	if (global_position - origin).length() > walk_radius:
		pick_new_direction()

func pick_new_direction():
	direction = Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0).normalized()

func _on_area_entered(area):
	print("[BUG] area_entered! Collided with:", area, " name:", area.name)
	print("[BUG] Other area collision_layer:", area.collision_layer, " mask:", area.collision_mask)
	print("[BUG] Immunity time remaining:", immunity_time)
	
	if alive and area.name == "Hammer" and immunity_time <= 0:
		print("[BUG] Smashed by Hammer!")
		alive = false
		if has_node("Area2D/CollisionShape2D"):
			get_node("Area2D/CollisionShape2D").disabled = true
		# Spawn 3 small bugs if this is not already a small bug
		if small_bug_scene and not self.has_meta("is_small_bug"):
			print("[BUG] About to spawn small bugs. small_bug_scene:", small_bug_scene)
			# Delay spawning slightly to let hammer collision finish
			await get_tree().create_timer(0.1).timeout
			for i in range(3):
				print("[BUG] Spawning small bug", i + 1)
				var bug = small_bug_scene.instantiate()
				print("[BUG] Instantiated bug:", bug)
				print("[BUG] Bug script:", bug.get_script())
				
				# Manually attach the script if it's missing
				if bug.get_script() == null:
					print("[BUG] Script missing! Manually attaching bug_movement.gd")
					var script = load("res://scripts/puzzles/bug_movement.gd")
					bug.set_script(script)
					print("[BUG] Script attached. Has _ready method:", bug.has_method("_ready"))
				
				bug.position = self.global_position + Vector2(randf_range(-24,24), randf_range(-24,24))
				bug.set_meta("is_small_bug", true)
				print("[BUG] Adding bug to scene at position:", bug.position)
				get_tree().current_scene.add_child(bug)
				print("[BUG] Small bug added to scene")
				
				# Register the new bug with the manager
				if get_parent() and get_parent().has_method("register_bug"):
					print("[BUG] Registering small bug with manager")
					get_parent().register_bug(bug)
				else:
					print("[BUG] Warning: Could not find manager to register small bug")
		else:
			print("[BUG] Not spawning small bugs. small_bug_scene:", small_bug_scene, " is_small_bug:", self.has_meta("is_small_bug"))
		self.visible = false
		# Delay destruction to ensure small bugs can initialize
		call_deferred("queue_free")
		if get_parent() and get_parent().has_method("on_bug_smashed"):
			get_parent().on_bug_smashed()
	elif alive and area.name == "Hammer" and immunity_time > 0:
		print("[BUG] Hammer hit but bug is immune! Immunity time remaining:", immunity_time)
