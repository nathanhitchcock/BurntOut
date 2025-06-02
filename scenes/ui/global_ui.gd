extends CanvasLayer

@onready var resume_button = $VBoxContainer/ResumeButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var restart_button = $VBoxContainer/QuitButton

func _ready():
	print("GlobalUI loaded!")
	visible = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	visible = not visible
	get_tree().paused = visible
	if visible:
		resume_button.grab_focus()

func _on_quit_pressed():
	get_tree().quit()

func _on_resume_button_pressed() -> void:
	toggle_pause()

func _on_restart_button_pressed() -> void:
	visible = false
	get_tree().paused = false
	await get_tree().create_timer(0.3).timeout
	get_tree().reload_current_scene()
