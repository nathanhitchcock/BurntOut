extends TextureButton
@export var defense_type: String = "CoffeeMachine"

func _ready():
	print("Ready for:", defense_type)  # Debug check
	self.pressed.connect(
		func(): get_tree().get_current_scene().select_defense(defense_type)
	)
