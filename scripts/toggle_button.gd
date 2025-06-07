extends TextureButton

# Use a different signal name to avoid conflict with TextureButton's built-in 'toggled' signal 
signal toggle_pressed(toggle_index: int)

@export var toggle_index: int = 0
var is_on: bool = false

func _ready():
	update_visual()
	self.pressed.connect(_on_pressed)

func _on_pressed():
	is_on = !is_on
	update_visual()
	emit_signal("toggle_pressed", toggle_index)

func update_visual():
	if is_on:
		# Set the texture for the ON state
		self.texture_normal = preload("res://assets/images/ui/toggle_button/toggle_on.png")
	else:
		# Set the texture for the OFF state
		self.texture_normal = preload("res://assets/images/ui/toggle_button/toggle_off.png")
