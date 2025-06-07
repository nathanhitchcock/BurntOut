extends CanvasLayer

@onready var resume_button = $VBoxContainer/ResumeButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var restart_button = $VBoxContainer/RestartButton
@onready var sprint_points_label = $SprintPointsLabel if has_node("SprintPointsLabel") else null
@onready var pause_menu = $VBoxContainer
@onready var pause_bg = $PauseBackground

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
	update_sprint_points_display()
