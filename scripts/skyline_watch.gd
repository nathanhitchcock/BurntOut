extends Node2D

@onready var burnout_label = $BurnoutLabel if has_node("BurnoutLabel") else null
@onready var quote_label = $QuoteLabel if has_node("QuoteLabel") else null
@onready var continue_button = $ContinuePrompt if has_node("ContinuePrompt") else null
@onready var player_data = get_node_or_null("/root/player_data")

var burnout_quotes = {
	1: ["Rest is not idleness.", "Even machines need to cool down."],
	2: ["You can't pour from an empty cup.", "Take a breath, not a break."],
	3: ["Burnout is what happens when you try to avoid being human for too long.", "Let yourself pause."],
	4: ["Sometimes, the bravest thing is to rest.", "You are not a machine."],
	5: ["From burnout, new growth can begin.", "The fire within needs tending, not burning out."]
}

func _ready():
	if player_data:
		var burnout = clamp(player_data.burnout_level, 1, 5)
		if burnout_label:
			burnout_label.text = "Burnout: %d" % burnout
		if quote_label:
			var quotes = burnout_quotes.get(burnout, ["Take a moment."])
			quote_label.text = quotes[randi() % quotes.size()]
	if continue_button:
		continue_button.visible = true
		continue_button.pressed.connect(_on_continue_pressed)
	# Show the main pause menu so the player can Restart or Quit
	if has_node("/root/GlobalUI"):
		get_node("/root/GlobalUI").toggle_pause()

func _on_continue_pressed():
	# Restore player health and teleport to the main office (corp_office.tscn)
	if player_data:
		player_data.health = 100
		get_tree().change_scene_to_file("res://scenes/CORP/corp_office.tscn")
