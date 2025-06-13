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
var burnout_label: Label = null

# Remove tree pausing, use a gameplay_enabled flag instead
var gameplay_enabled := true

func _ready():
	set_process_input(true)
	print("GlobalUI loaded!")
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
	burnout_label = get_node_or_null("CanvasLayer/Control/BurnoutLabel")
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
		print("[DEBUG] Pause menu node found and ready.")
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
	if burnout_label:
		_update_burnout_label()

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
		print("[DEBUG] toggle_pause: pause_menu.visible=", pause_menu.visible, ", gameplay_enabled=", gameplay_enabled)
		if pause_menu.visible:
			pause_menu.move_to_front()
			if resume_button:
				resume_button.grab_focus()
	else:
		print("[GlobalUI] Warning: pause_menu or pause_bg is null!")

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
	# Hide sprint points, health bar, and burnout label on StartScreen
	var current_scene = get_tree().current_scene
	if sprint_points_label:
		if current_scene and current_scene.scene_file_path.ends_with("StartScreen.tscn"):
			sprint_points_label.visible = false
			if health_bar:
				health_bar.visible = false
			if has_node("CanvasLayer/Control/BurnoutLabel"):
				get_node("CanvasLayer/Control/BurnoutLabel").visible = false
		else:
			sprint_points_label.visible = true
			if health_bar:
				health_bar.visible = true
			if has_node("CanvasLayer/Control/BurnoutLabel"):
				get_node("CanvasLayer/Control/BurnoutLabel").visible = true
	update_sprint_points_display()
	_update_health_bar()
	_update_burnout_label()

func _update_health_bar():
	if health_bar:
		var health = 100
		if has_node("/root/player_data"):
			health = get_node("/root/player_data").health
		health_bar.value = health

func _update_burnout_label():
	if burnout_label and has_node("/root/player_data"):
		var pd = get_node("/root/player_data")
		var burnout = 0
		if "burnout_level" in pd:
			burnout = pd.burnout_level
		burnout_label.text = "Burnout Lvl: %d" % burnout

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
	print("[DEBUG] Pause menu received input: ", event)

func _unhandled_input(event):
	# Workaround: Forward mouse input to pause menu when paused so UI buttons work
	if get_tree().paused and pause_menu and pause_menu.visible:
		if event is InputEventMouseButton or event is InputEventMouseMotion:
			pause_menu.propagate_call("gui_input", [event])

func _on_volume_slider_changed(value):
	# Set global audio volume using the Master bus
	var db = lerp(-40, 0, value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), db)
	_update_volume_label()

func _update_volume_label():
	if volume_label and volume_slider:
		volume_label.text = "Volume: %d%%" % int(volume_slider.value * 100)
