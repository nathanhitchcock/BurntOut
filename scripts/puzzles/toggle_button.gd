extends TextureButton

# Use a different signal name to avoid conflict with TextureButton's built-in 'toggled' signal 
signal toggle_pressed(toggle_index: int)

@export var toggle_index: int = 0
@export var show_sparks_on_load: bool = false

var is_on: bool = false

func _ready():
	print("[ToggleButton] _ready called for toggle_index %s" % str(toggle_index))
	self.modulate = Color(1,1,1,1) # Ensure default color
	update_visual()
	self.pressed.connect(_on_pressed)
	# Delay showing the toggle for effect
	self.visible = false
	await get_tree().create_timer(2.0).timeout
	self.visible = true
	# Only one random button gets the effect
	if is_random_effect_target():
		await get_tree().process_frame # Ensure button is visible before flash
		spawn_sparks()

# Helper to determine if this button is the random target
func is_random_effect_target() -> bool:
	# Only run on first frame for all toggles
	if not get_tree().has_meta("_toggle_effect_randomized"):
		var toggles = get_parent().get_children().filter(func(n): return n is TextureButton)
		if toggles.size() == 0:
			return false
		# Always pick at least one
		var idx = randi() % toggles.size()
		for i in range(toggles.size()):
			toggles[i].set_meta("random_effect_target", i == idx)
		get_tree().set_meta("_toggle_effect_randomized", true)
	return self.get_meta("random_effect_target", false)

func _on_pressed():
	if has_node("ClickSound"):
		$ClickSound.play()
	is_on = !is_on
	update_visual()
	emit_signal("toggle_pressed", toggle_index)

func update_visual():
	if is_on:
		# Set the texture for the ON state
		self.texture_normal = preload("res://assets/images/ui/toggle_button/toggle_on.png")
		self.texture_pressed = preload("res://assets/images/ui/toggle_button/toggle_on.png")
	else:
		# Set the texture for the OFF state
		self.texture_normal = preload("res://assets/images/ui/toggle_button/toggle_off.png")
		self.texture_pressed = preload("res://assets/images/ui/toggle_button/toggle_off.png")

func set_on(on: bool = true):
	is_on = on
	update_visual()
	print("[ToggleButton] set_on called for toggle_index %s, is_on: %s" % [str(toggle_index), str(is_on)])

func animate_toggle_off(delay: float = 0.0):
	# Tween the button visually from on to off after a delay
	if is_on:
		print("[ToggleButton] animate_toggle_off called for toggle_index %s, delay: %s" % [str(toggle_index), str(delay)])
		var tween = create_tween()
		tween.tween_interval(delay)
		tween.tween_callback(Callable(self, "set_on").bind(false))

func spawn_sparks():
	var sparks = preload("res://scenes/vfx/ButtonUnlockParticles.tscn").instantiate()
	add_child(sparks)
	sparks.global_position = self.global_position
	var particles = sparks.get_node_or_null("CPUParticles2D")
	if particles:
		particles.emitting = true
	# Play short-circuit sound effect (revert to original file name)
	var sfx = AudioStreamPlayer.new()
	sfx.stream = preload("res://assets/audio/sfx/short_circuit_01.wav")
	add_child(sfx)
	sfx.play()
	# Shake effect (runs in parallel with flashing)
	var original_pos = self.position
	var shake_tween = create_tween()
	shake_tween.tween_property(self, "position:x", original_pos.x + 8, 0.05)
	shake_tween.tween_property(self, "position:x", original_pos.x - 8, 0.05)
	shake_tween.tween_property(self, "position:x", original_pos.x, 0.08)
	# Flash the button multiple times for visibility
	for i in range(3):
		self.modulate = Color(1,1,1,1) # Pure white
		await get_tree().create_timer(0.1).timeout
		self.modulate = Color(1,0.7,0.2,1) # Orange/yellow
		await get_tree().create_timer(0.1).timeout
	self.modulate = Color(1,1,1,1)
	print("[ToggleButton] Flash end for toggle_index %s" % str(toggle_index))
