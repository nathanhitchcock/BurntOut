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
	update_shop_ui()
	update_shop_ui()

func update_shop_ui():
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
		if has_node("/root/player_data"):
			player_data.health = min(player_data.health + 30, 100)
		if has_node("/root/GlobalUI"):
			get_node("/root/GlobalUI")._update_health_bar()
		if player and player.has_method("show_floating_feedback"):
			player.show_floating_feedback("+30 Health!", Color(0.2,0.8,1))
	elif upgrade.effect == "shield":
		if has_node("/root/player_data"):
			player_data.has_shield = true
			player_data.shield_hp = 100 # Set shield HP to max when purchased
		if has_node("/root/GlobalUI"):
			get_node("/root/GlobalUI")._update_shield_bar()
		if player and player.has_method("show_floating_feedback"):
			player.show_floating_feedback("Shield Ready!", Color(1,1,0.2))
	# Add more effects as needed
	update_shop_ui()
