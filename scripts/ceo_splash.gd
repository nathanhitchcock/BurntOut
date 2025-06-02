extends CanvasLayer

signal cutscene_finished

@onready var continue_button := $ContinueButton

func _ready():
	# TEMP disable pause input while splash is active
	if GlobalUI:
		GlobalUI.set_process_input(false)
		GlobalUI.visible = false
	
	get_tree().paused = true
	continue_button.visible = false
	continue_button.disabled = true

	$AnimationPlayer.play("fade_in")
	await get_tree().create_timer(2.0).timeout

	# Enable the button after delay
	continue_button.visible = true
	continue_button.disabled = false
	continue_button.grab_focus()  # Optional: highlights the button

	# Optional: Add animation or effect
	if continue_button.has_node("AnimationPlayer"):
		continue_button.get_node("AnimationPlayer").play("blink")


func _on_continue_button_pressed() -> void:
	$AnimationPlayer.play("fade_out")
	await $AnimationPlayer.animation_finished
	queue_free()
	emit_signal("cutscene_finished")
	get_tree().paused = false
