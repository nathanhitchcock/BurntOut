extends CanvasLayer

var resume_button: Button = null
var quit_button: Button = null
var restart_button: Button = null
var sprint_points_label: Label = null
var pause_menu: Control = null
var pause_bg: Control = null
var interact_prompt: Label = null
var volume_slider: HSlider = null
var volume_label: Label = null
var health_bar: ProgressBar = null
var burnout_flames: Array = []
var burnout_flame_nodes: Array = []

# Remove tree pausing, use a gameplay_enabled flag instead
var gameplay_enabled := true

var shield_icon: TextureRect = null
var shield_images: Array = []

# Bug smash counter
var bug_counter_label: Label = null
var bug_win_label: Label = null

# Toggle puzzle level info
var toggle_level_label: Label = null
var end_screen: Control = null
var end_message_label: Label = null
var end_shown: bool = false

func _ready():
	set_process_input(true)
	# Assign UI nodes robustly for all scenes (fix: include CanvasLayer/Control in path)
	resume_button = get_node_or_null("CanvasLayer/Control/VBoxContainer/ResumeButton")
	quit_button = get_node_or_null("CanvasLayer/Control/VBoxContainer/QuitButton")
	restart_button = get_node_or_null("CanvasLayer/Control/VBoxContainer/RestartButton")
	sprint_points_label = get_node_or_null("CanvasLayer/Control/SprintPointsLabel")
	pause_menu = get_node_or_null("CanvasLayer/Control/VBoxContainer")
	pause_bg = get_node_or_null("CanvasLayer/Control/PauseBackground")
	interact_prompt = get_node_or_null("CanvasLayer/Control/InteractPrompt")
	volume_slider = get_node_or_null("CanvasLayer/Control/VBoxContainer/VolumeSlider")
	volume_label = get_node_or_null("CanvasLayer/Control/VBoxContainer/VolumeLabel")
	health_bar = get_node_or_null("CanvasLayer/Control/HealthBar")
	# Removed all shield_bar ProgressBar code

	# Find the parent node for UI elements
	var parent = get_node_or_null("CanvasLayer/Control")

	# Build a hidden end screen overlay (simple message)
	end_screen = Control.new()
	end_screen.name = "EndScreen"
	end_screen.visible = false
	end_screen.mouse_filter = Control.MOUSE_FILTER_STOP
	end_screen.anchor_left = 0
	end_screen.anchor_top = 0
	end_screen.anchor_right = 1
	end_screen.anchor_bottom = 1
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.anchor_left = 0
	bg.anchor_top = 0
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	end_screen.add_child(bg)
	end_message_label = Label.new()
	end_message_label.name = "EndMessageLabel"
	end_message_label.text = "Great work! Next sprint, we’re targeting 120%!!"
	end_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	end_message_label.add_theme_font_size_override("font_size", 36)
	end_message_label.add_theme_color_override("font_color", Color(1, 1, 1))
	end_message_label.anchor_left = 0.5
	end_message_label.anchor_top = 0.5
	end_message_label.anchor_right = 0.5
	end_message_label.anchor_bottom = 0.5
	end_message_label.position = Vector2(0, 0)
	end_screen.add_child(end_message_label)
	if parent:
		parent.add_child(end_screen)

	# Add a TextureRect for the shield icon
	var shield_icon = TextureRect.new()
	shield_icon.name = "ShieldIcon"
	shield_icon.anchor_left = 0
	shield_icon.anchor_top = 0
	shield_icon.anchor_right = 0
	shield_icon.anchor_bottom = 0
	shield_icon.position = Vector2(-475, -200) # Adjust as needed for UI placement
	shield_icon.custom_minimum_size = Vector2(48, 48)
	shield_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	if parent:
		parent.add_child(shield_icon)

	# Preload shield images for 1-5
	var shield_images = [
		load("res://assets/images/ui/hud/shields/shield1.png"), # not purchased
		load("res://assets/images/ui/hud/shields/shield2.png"), # 25%
		load("res://assets/images/ui/hud/shields/shield3.png"), # 50%
		load("res://assets/images/ui/hud/shields/shield4.png"), # 75%
		load("res://assets/images/ui/hud/shields/shield5.png")  # 100%
	]

	# Store for later updates
	self.shield_icon = shield_icon
	self.shield_images = shield_images

	# Create bug counter label (center top of screen)
	bug_counter_label = Label.new()
	bug_counter_label.name = "BugCounterLabel"
	bug_counter_label.text = "Bugs: 0 / 0"
	bug_counter_label.anchor_left = 0.5
	bug_counter_label.anchor_right = 0.5
	bug_counter_label.anchor_top = 0.0
	bug_counter_label.anchor_bottom = 0.0
	bug_counter_label.position = Vector2(-60, -250)  # Center top, moved up 200 pixels
	bug_counter_label.add_theme_color_override("font_color", Color(1, 1, 1))
	bug_counter_label.add_theme_font_size_override("font_size", 24)
	bug_counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bug_counter_label.visible = false  # Hidden by default, shown only in bug room
	if parent:
		parent.add_child(bug_counter_label)

	# Create bug win label (underneath the counter)
	bug_win_label = Label.new()
	bug_win_label.name = "BugWinLabel"
	bug_win_label.text = "You Win!"
	bug_win_label.anchor_left = 0.5
	bug_win_label.anchor_right = 0.5
	bug_win_label.anchor_top = 0.0
	bug_win_label.anchor_bottom = 0.0
	bug_win_label.position = Vector2(-60, -220)  # Just underneath the bug counter
	bug_win_label.add_theme_color_override("font_color", Color(1, 1, 0))  # Yellow color
	bug_win_label.add_theme_font_size_override("font_size", 32)  # Larger font for celebration
	bug_win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bug_win_label.visible = false  # Hidden by default, shown only when puzzle complete
	if parent:
		parent.add_child(bug_win_label)

	# Create toggle level label (center top of screen, for progressive toggle puzzle)
	toggle_level_label = Label.new()
	toggle_level_label.name = "ToggleLevelLabel"
	toggle_level_label.text = "Level 1 - Worth 1 Point"
	toggle_level_label.anchor_left = 0.5
	toggle_level_label.anchor_right = 0.5
	toggle_level_label.anchor_top = 0.0
	toggle_level_label.anchor_bottom = 0.0
	toggle_level_label.position = Vector2(-80, -250)  # Center top
	toggle_level_label.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0))  # Light blue
	toggle_level_label.add_theme_font_size_override("font_size", 24)
	toggle_level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toggle_level_label.visible = false  # Hidden by default, shown only in toggle room
	if parent:
		parent.add_child(toggle_level_label)

	# Always show the sprint points label
	if sprint_points_label:
		sprint_points_label.visible = true
	# Hide pause menu and background at start
	if pause_menu:
		pause_menu.visible = false
	if pause_bg:
		pause_bg.visible = false
	# Ensure pause menu and its buttons process input when paused (recursively)
	if pause_menu:
		pause_menu.process_mode = 1
		_set_buttons_pausable(pause_menu)
	# Debug: print when pause menu is shown and connect button signals
	if pause_menu:
		if resume_button:
			resume_button.pressed.connect(_on_resume_button_pressed)
		if quit_button:
			quit_button.pressed.connect(_on_quit_pressed)
		if restart_button:
			restart_button.pressed.connect(_on_restart_button_pressed)
		if pause_menu:
			pause_menu.connect("gui_input", Callable(self, "_on_pause_menu_gui_input"))
	if volume_slider:
		volume_slider.value = 0.5
		volume_slider.connect("value_changed", Callable(self, "_on_volume_slider_changed"))
		_update_volume_label()
	if health_bar:
		health_bar.value = 100
		_update_health_bar()
	# Removed all shield_bar ProgressBar code
	# Load flame textures for burnout levels 1-5
	burnout_flames = []
	for i in range(1, 6):
		var tex = load("res://assets/images/ui/hud/burnout_level/flame%d.png" % i)
		if tex:
			burnout_flames.append(tex)
	# Create flame nodes (hidden by default)
	burnout_flame_nodes = []
	for i in range(5):
		var sprite = TextureRect.new()
		if burnout_flames.size() > 0:
			sprite.texture = burnout_flames[0]
		else:
			sprite.texture = null
		sprite.visible = false
		sprite.anchor_left = 0
		sprite.anchor_top = 0
		sprite.anchor_right = 0
		sprite.anchor_bottom = 0
		# Set all flames to the same size as the shield icon
		var size = 48
		sprite.custom_minimum_size = Vector2(size, size)
		# Position flames to the right of the shield icon, spaced evenly
		var flame_spacing = 40 # horizontal space between flames
		var base_x = -475 + 48 + 8 + i * flame_spacing # shield x + shield width + gap + index * spacing
		sprite.position = Vector2(base_x, -200)
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		parent.add_child(sprite)
		burnout_flame_nodes.append(sprite)
		# --- BEGIN OPTIONAL PARTICLE EFFECTS FOR BURNOUT FLAMES 3, 4, 5 ---
		# To re-enable, uncomment this block.
		'''
		if i == 2:
			var particles3 = GPUParticles2D.new()
			var material3 = ParticleProcessMaterial.new()
			material3.gravity = Vector3(0, -8, 0)
			material3.direction = Vector3(0, -1, 0)
			material3.spread = 0.22 # narrower
			material3.initial_velocity_min = 4
			material3.initial_velocity_max = 7
			material3.scale_min = 0.11 # smaller
			material3.scale_max = 0.16 # smaller
			material3.angle_min = -4
			material3.angle_max = 4
			material3.angular_velocity_min = -0.4
			material3.angular_velocity_max = 0.4
			material3.color = Color(0.949, 0.361, 0.220, 0.18) # lower alpha
			var ramp3 = Gradient.new()
			ramp3.colors = [Color(0.949, 0.361, 0.220, 0.22), Color(0.949, 0.361, 0.220, 0.10), Color(0.949, 0.361, 0.220, 0.0)]
			ramp3.offsets = [0.0, 0.5, 1.0]
			material3.color_ramp = ramp3
			particles3.process_material = material3
			particles3.amount = 2 # fewer particles
			particles3.lifetime = 0.22 # shorter
			particles3.texture = burnout_flames[2]
			particles3.position = sprite.position + Vector2(18, 23)
			particles3.scale = Vector2(0.95, 0.95) # smaller
			particles3.z_index = 2
			sprite.z_index = 1
			parent.add_child(particles3)
			particles3.owner = parent
			parent.move_child(particles3, 0)
		if i == 3:
			var particles4 = GPUParticles2D.new()
			var material4 = ParticleProcessMaterial.new()
			material4.gravity = Vector3(0, -8, 0)
			material4.direction = Vector3(0, -1, 0)
			material4.spread = 0.22
			material4.initial_velocity_min = 5
			material4.initial_velocity_max = 9
			material4.scale_min = 0.10
			material4.scale_max = 0.15
			material4.angle_min = -5
			material4.angle_max = 5
			material4.angular_velocity_min = -0.5
			material4.angular_velocity_max = 0.5
			material4.color = Color(0.6, 0.25, 0.8, 0.14) # lower alpha
			var ramp4 = Gradient.new()
			ramp4.colors = [Color(0.7, 0.4, 1.0, 0.18), Color(0.6, 0.25, 0.8, 0.08), Color(0.6, 0.25, 0.8, 0.0)]
			ramp4.offsets = [0.0, 0.5, 1.0]
			material4.color_ramp = ramp4
			particles4.process_material = material4
			particles4.amount = 2
			particles4.lifetime = 0.22
			particles4.texture = burnout_flames[3]
			particles4.position = sprite.position + Vector2(22, 25)
			particles4.scale = Vector2(0.85, 0.85)
			particles4.z_index = 2
			sprite.z_index = 1
			parent.add_child(particles4)
			particles4.owner = parent
			parent.move_child(particles4, 0)
		if i == 4:
			var particles = GPUParticles2D.new()
			var material = ParticleProcessMaterial.new()
			material.gravity = Vector3(0, -8, 0)
			material.direction = Vector3(0, -1, 0)
			material.spread = 0.28
			material.initial_velocity_min = 7
			material.initial_velocity_max = 13
			material.scale_min = 0.10
			material.scale_max = 0.16
			material.angle_min = -6
			material.angle_max = 6
			material.angular_velocity_min = -0.7
			material.angular_velocity_max = 0.7
			material.color = Color(0.7, 0.3, 1.0, 0.18) # lower alpha
			var ramp = Gradient.new()
			ramp.colors = [Color(0.85, 0.5, 1.0, 0.22), Color(0.7, 0.3, 1.0, 0.10), Color(0.7, 0.3, 1.0, 0.0)]
			ramp.offsets = [0.0, 0.5, 1.0]
			material.color_ramp = ramp
			particles.process_material = material
			particles.amount = 3
			particles.lifetime = 0.26
			particles.texture = burnout_flames[4]
			particles.position = sprite.position + Vector2(27, 25)
			particles.scale = Vector2(0.85, 0.85)
			particles.z_index = 2
			sprite.z_index = 1
			parent.add_child(particles)
			particles.owner = parent
			parent.move_child(particles, 0)
		'''
		# --- END OPTIONAL PARTICLE EFFECTS ---
	_update_burnout_flames()
	# Force initial HUD visibility update for StartScreen/Skyline scenes
	_process(0)

func _set_buttons_pausable(node):
	for child in node.get_children():
		if child is Button:
			child.process_mode = 1
		if child.get_child_count() > 0:
			_set_buttons_pausable(child)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	if pause_menu and pause_bg:
		pause_menu.visible = not pause_menu.visible
		pause_bg.visible = not pause_bg.visible
		gameplay_enabled = not pause_menu.visible
		# Pause or resume music
		var music_player = GlobalAudio.get_node_or_null("AmbientHum")
		if music_player:
			music_player.stream_paused = pause_menu.visible
func _on_quit_pressed():
	get_tree().quit()

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_restart_button_pressed() -> void:
	if pause_menu:
		pause_menu.visible = false
	if pause_bg:
		pause_bg.visible = false
	gameplay_enabled = true
	await get_tree().create_timer(0.3).timeout
	get_tree().reload_current_scene()

func update_sprint_points_display():
	if sprint_points_label:
		var points = 0
		if has_node("/root/player_data"):
			points = get_node("/root/player_data").sprint_points
		sprint_points_label.text = "Sprint Points: %d" % points

func _process(_delta):
	# Hide sprint points, health bar, and burnout label on StartScreen and SkylineWatch
	var current_scene = get_tree().current_scene
	var hide_hud = false
	var scene_path = ""
	if current_scene and "scene_file_path" in current_scene:
		scene_path = current_scene.scene_file_path
		hide_hud = scene_path.ends_with("StartScreen.tscn") or scene_path.ends_with("SkylineWatch.tscn")
	var empty_tex = load("res://assets/images/ui/hud/empty.png")
	if shield_icon:
		if hide_hud:
			shield_icon.texture = empty_tex
		else:
			_update_shield_bar()
	for i in range(burnout_flame_nodes.size()):
		var flame = burnout_flame_nodes[i]
		if hide_hud and i == 0:
			flame.texture = empty_tex
		elif not hide_hud and burnout_flames.size() > i:
			flame.texture = burnout_flames[i]
		# Explicitly hide the first flame icon on Start Screen
		if hide_hud and i == 0:
			flame.visible = false
		flame.visible = not hide_hud and flame.texture != null
	update_sprint_points_display()
	_update_health_bar()
	if not hide_hud:
		_update_burnout_flames()
	# After all other logic, ensure health bar and sprint points label are hidden on Start Screen
	if health_bar:
		health_bar.visible = not hide_hud
	if sprint_points_label:
		sprint_points_label.visible = not hide_hud

func _update_health_bar():
	if health_bar:
		var health = 100
		if has_node("/root/player_data"):
			health = get_node("/root/player_data").health
		health_bar.value = health

func _update_shield_bar():
	# Use shield_icon and shield_images instead of ProgressBar
	if not ("shield_icon" in self and "shield_images" in self):
		return
	var shield_icon = self.shield_icon
	var shield_images = self.shield_images
	var shield = 0
	if has_node("/root/player_data"):
		shield = get_node("/root/player_data").shield_hp
	# Determine which image to show
	var idx = 0
	if shield <= 0:
		idx = 0 # not purchased or depleted
	elif shield < 25:
		idx = 1
	elif shield < 50:
		idx = 2
	elif shield < 75:
		idx = 3
	else:
		idx = 4
	shield_icon.texture = shield_images[idx]
	shield_icon.visible = (shield > 0 or idx == 0)

func _update_burnout_flames():
	# Show flames and their particle effects up to the current burnout level
	if burnout_flame_nodes.size() == 5 and burnout_flames.size() > 0:
		var burnout_level = 0
		if has_node("/root/player_data"):
			burnout_level = get_node("/root/player_data").burnout_level
		for i in range(5):
			burnout_flame_nodes[i].texture = burnout_flames[min(i, burnout_flames.size()-1)]
			burnout_flame_nodes[i].visible = i <= burnout_level # Only show up to current burnout level

func get_interact_prompt():
	# Try direct path first
	if has_node("CanvasLayer/InteractPrompt"):
		return get_node("CanvasLayer/InteractPrompt")
	# Fallback: search recursively
	for child in get_children():
		var found = _find_interact_prompt_recursive(child)
		if found:
			return found
	return null

func _find_interact_prompt_recursive(node):
	if node is Label and node.name == "InteractPrompt":
		return node
	for child in node.get_children():
		var found = _find_interact_prompt_recursive(child)
		if found:
			return found
	return null

func set_interact_prompt_text(text: String):
	var prompt = get_interact_prompt()
	if prompt:
		prompt.text = text

func show_interact_prompt(show: bool = true, position: Vector2 = Vector2.INF):
	var prompt = get_interact_prompt()
	if prompt:
		prompt.visible = show
		if position != Vector2.INF:
			prompt.global_position = position

func show_interact_popup_near_player(player: Node):
	if not player:
		return
	var label = Label.new()
	label.text = "[E]"
	label.modulate = Color(1, 1, 1, 1)
	label.global_position = player.global_position + Vector2(0, -60)
	label.z_index = 1000
	label.add_theme_font_size_override("font_size", 24)
	get_tree().current_scene.add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0, 1.0)
	tween.tween_property(label, "position:y", label.position.y - 20, 1.0)
	tween.finished.connect(label.queue_free)

func _on_pause_menu_gui_input(event):
	pass

func _unhandled_input(event):
	# Workaround: Forward mouse input to pause menu when paused so UI buttons work
	if get_tree().paused and pause_menu and pause_menu.visible:
		if event is InputEventMouseButton or event is InputEventMouseMotion:
			pause_menu.propagate_call("gui_input", [event])

# End screen control
func show_end_screen(message: String = "Great work! Next sprint, we’re targeting 120%!!"):
	if end_shown:
		return
	end_shown = true
	gameplay_enabled = false
	if end_message_label:
		end_message_label.text = message
	# Position the message near the player's screen position if available
	var player = get_tree().current_scene.get_node_or_null("Player")
	if player and end_message_label:
		# Convert player's world position to screen/canvas coordinates
		var screen_pos: Vector2 = player.get_global_transform_with_canvas().origin
		var viewport_size: Vector2 = get_viewport().size
		# With centered anchors, offset from screen center to reach target
		end_message_label.position = screen_pos - (viewport_size * 0.5)
	if end_screen:
		end_screen.visible = true
	# Optionally pause ambient audio
	var music_player = GlobalAudio.get_node_or_null("AmbientHum")
	if music_player:
		music_player.stream_paused = true

func hide_end_screen():
	if end_screen:
		end_screen.visible = false
	gameplay_enabled = true

# Bug counter functions
func show_bug_counter():
	if bug_counter_label:
		bug_counter_label.visible = true
		print("[GLOBAL_UI] Bug counter shown")

func hide_bug_counter():
	if bug_counter_label:
		bug_counter_label.visible = false
		print("[GLOBAL_UI] Bug counter hidden")

func update_bug_counter(smashed: int, total: int):
	if bug_counter_label:
		bug_counter_label.text = "Bugs: %d / %d" % [smashed, total]
		print("[GLOBAL_UI] Bug counter updated: %d / %d" % [smashed, total])

func show_bug_win():
	if bug_win_label:
		bug_win_label.visible = true

func hide_bug_win():
	if bug_win_label:
		bug_win_label.visible = false

# Toggle level info functions
func show_toggle_level_info(level: int, points: int):
	if toggle_level_label:
		if level > 0:
			toggle_level_label.text = "Level %d - Worth %d Points" % [level, points]
			toggle_level_label.visible = true
		else:
			toggle_level_label.visible = false

func hide_toggle_level_info():
	if toggle_level_label:
		toggle_level_label.visible = false

func _on_volume_slider_changed(value):
	# Set global audio volume using the Master bus
	var db = lerp(-40, 0, value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	_update_volume_label()

func _update_volume_label():
	if volume_label and volume_slider:
		volume_label.text = "Volume: %d%%" % int(volume_slider.value * 100)

func give_test_sprint_points():
	if has_node("/root/player_data"):
		get_node("/root/player_data").sprint_points = 3
		update_sprint_points_display()
