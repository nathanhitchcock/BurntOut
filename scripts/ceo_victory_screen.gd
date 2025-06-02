extends CanvasLayer

func _ready():
	get_tree().paused = false
	GlobalUI.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	print("GlobalUI exists? ", GlobalUI)
	call_deferred("_enable_global_ui")
	
	print("GlobalUI visible? ", GlobalUI.visible)
	GlobalUI.visible = true
	print("GlobalUI forced visible")

func _on_exit_pressed():
	get_tree().quit()
	
func _enable_global_ui():
	if GlobalUI:
		GlobalUI.visible = true
		GlobalUI.set_process_input(true)

		for child in GlobalUI.get_children():
			child.visible = true
			child.set_process_input(true)
