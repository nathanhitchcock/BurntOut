extends Node2D

func _ready():
	# On scene load, set all toggles ON, then animate them OFF after a short delay
	var toggles := [get_node("ToggleButton1"), get_node("ToggleButton2"), get_node("ToggleButton3")]
	for toggle in toggles:
		if toggle:
			toggle.set_on(true)
	# Add a delay before starting the OFF animation
	await get_tree().create_timer(0.7).timeout
	for i in range(toggles.size()):
		var toggle = toggles[i]
		if toggle:
			toggle.animate_toggle_off(i * 0.3)
