extends CanvasLayer

@onready var resume_button = $VBoxContainer/ResumeButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var restart_button = $VBoxContainer/RestartButton
@onready var sprint_points_label = $SprintPointsLabel if has_node("SprintPointsLabel") else null
@onready var pause_menu = $VBoxContainer
@onready var pause_bg = $PauseBackground
@onready var interact_prompt = $CanvasLayer/InteractPrompt if has_node("CanvasLayer/InteractPrompt") else null

func _ready():
	print("GlobalUI loaded!")
	# Always show the sprint points label
	if sprint_points_label:
		sprint_points_label.visible = true
	# Hide pause menu and background at start
	if pause_menu:
		pause_menu.visible = false
	if pause_bg:
		pause_bg.visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	if pause_menu:
		pause_menu.visible = not pause_menu.visible
	if pause_bg:
		pause_bg.visible = not pause_bg.visible
	get_tree().paused = pause_menu.visible
	if pause_menu.visible and resume_button:
		resume_button.grab_focus()

func _on_quit_pressed():
	get_tree().quit()

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_restart_button_pressed() -> void:
	if pause_menu:
		pause_menu.visible = false
	if pause_bg:
		pause_bg.visible = false
	get_tree().paused = false
	await get_tree().create_timer(0.3).timeout
	get_tree().reload_current_scene()

func update_sprint_points_display():
	if sprint_points_label:
		var points = 0
		if has_node("/root/player_data"):
			points = get_node("/root/player_data").sprint_points
		sprint_points_label.text = "Sprint Points: %d" % points

func _process(_delta):
	# Hide sprint points label on StartScreen
	var current_scene = get_tree().current_scene
	if sprint_points_label:
		if current_scene and current_scene.scene_file_path.ends_with("StartScreen.tscn"):
			sprint_points_label.visible = false
		else:
			sprint_points_label.visible = true
	update_sprint_points_display()

func show_interact_prompt(show: bool = true, position: Vector2 = Vector2.INF):
	if interact_prompt:
		interact_prompt.visible = show
		if position != Vector2.INF:
			interact_prompt.global_position = position

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
	if interact_prompt:
		interact_prompt.text = text

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
