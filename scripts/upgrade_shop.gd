extends Control

@onready var player_data = get_node("/root/player_data")
@onready var player = null # Set this from the scene or via script

# Example upgrades
var upgrades = [
	{
		"name": "Coffee (Heal)",
		"cost": 2,
		"description": "Restore 30 health.",
		"effect": "heal"
	},
	{
		"name": "Shield (Block 1 hit)",
		"cost": 3,
		"description": "Gain a shield that blocks the next damage.",
		"effect": "shield"
	}
]

func _ready():
	# Find player in the scene if not set
	if not player:
		player = get_tree().current_scene.get_node_or_null("Player")
	# Connect UI buttons
	$CanvasLayer/VBoxContainer/CoffeeButton.pressed.connect(func(): purchase_upgrade(0))
	$CanvasLayer/VBoxContainer/ShieldButton.pressed.connect(func(): purchase_upgrade(1))
	$CanvasLayer/VBoxContainer/CloseButton.pressed.connect(func(): self.visible = false) # If you have a close button
	update_shop_ui()
	update_shop_ui()

func update_shop_ui():
	# Update the points label
	$CanvasLayer/VBoxContainer/PointsLabel.text = "Sprint Points: %d" % player_data.sprint_points
	# This is a stub. In your actual UI, populate item buttons/labels with upgrade info.
	print("[Shop] Available upgrades:")
	for u in upgrades:
		print("- %s (%d points): %s" % [u.name, u.cost, u.description])

func purchase_upgrade(index):
	var upgrade = upgrades[index]
	if player_data.sprint_points < upgrade.cost:
		if player and player.has_method("show_floating_feedback"):
			player.show_floating_feedback("Not enough points!", Color(1,0.2,0.2))
		return
	player_data.sprint_points -= upgrade.cost
	if upgrade.effect == "heal":
		if player and player.has_node("HealthBar"):
			var bar = player.get_node("HealthBar")
			bar.value = min(bar.value + 30, bar.max_value)
			player.show_floating_feedback("+30 Health!", Color(0.2,0.8,1))
	elif upgrade.effect == "shield":
		if player:
			player.set_meta("has_shield", true)
			player.show_floating_feedback("Shield Ready!", Color(1,1,0.2))
	# Add more effects as needed
	update_shop_ui()
