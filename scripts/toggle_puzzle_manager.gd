extends Node2D

# The correct sequence of toggle indices to solve the puzzle
var solution: Array = []
# The player's current input sequence
var player_sequence: Array = []
# Number of toggles in the puzzle
const TOGGLE_COUNT := 3

@onready var incorrect_label = $IncorrectLabel if has_node("IncorrectLabel") else null
@onready var solved_label = $SolvedLabel if has_node("SolvedLabel") else null
@onready var fail_sound = $FailSound if has_node("FailSound") else null
@onready var success_sound = $SuccessSound if has_node("SuccessSound") else null
@onready var portal = $PortalToCorpOffice if has_node("PortalToCorpOffice") else null
@onready var player = $Player if has_node("Player") else null

func _ready():
	# Generate a random solution sequence
	solution = []
	var indices = []
	for i in TOGGLE_COUNT:
		indices.append(i)
	indices.shuffle()
	solution = indices.duplicate()
	print("[TogglePuzzle] Solution:", solution)

	# Connect signals from all ToggleButton children
	for i in TOGGLE_COUNT:
		var btn = get_node("ToggleButton%d" % (i+1))
		if btn:
			btn.toggle_index = i
			btn.connect("toggle_pressed", Callable(self, "_on_toggle_pressed"))

	if incorrect_label:
		incorrect_label.visible = false
	if solved_label:
		solved_label.visible = false

func _on_toggle_pressed(toggle_index: int):
	print("[TogglePuzzle] Player pressed:", toggle_index)
	player_sequence.append(toggle_index)
	# Check if the player's input matches the solution so far
	for i in player_sequence.size():
		if player_sequence[i] != solution[i]:
			print("[TogglePuzzle] Incorrect! Resetting.")
			# if fail_sound:
			#     fail_sound.play()  # Commented out: use player damage SFX instead
			# Randomize damage between 10 and 30
			var damage = randi_range(5, 10)
			if player and player.has_method("take_damage"):
				player.take_damage(damage) # Deal random damage on fail
			elif player and player.has_node("HealthBar"):
				var bar = player.get_node("HealthBar")
				bar.value = max(bar.value - damage, bar.min_value)
			if incorrect_label:
				incorrect_label.visible = true
				await get_tree().create_timer(1.0).timeout
				incorrect_label.visible = false
			if portal:
				portal.visible = true
			player_sequence.clear()
			_reset_toggles()
			return
	# If the player has completed the sequence
	if player_sequence.size() == solution.size():
		print("[TogglePuzzle] Puzzle solved!")
		if success_sound:
			success_sound.play()
		if solved_label:
			solved_label.visible = true
			await get_tree().create_timer(1.0).timeout
			solved_label.visible = false
		if portal:
			portal.visible = true
		# Award sprint points for solving the puzzle
		if has_node("/root/player_data"):
			get_node("/root/player_data").sprint_points += 1
		# Show floating label for sprint point using player method
		if player and player.has_method("show_floating_feedback"):
			player.show_floating_feedback("+1 Sprint Point!", Color(0.2, 0.9, 0.2, 1))
		# TODO: Add your puzzle completion logic here
		player_sequence.clear()
		_reset_toggles()

func _reset_toggles():
	for i in TOGGLE_COUNT:
		var btn = get_node("ToggleButton%d" % (i+1))
		if btn:
			btn.is_on = false
			btn.update_visual()

func _process(_delta):
	if player and player.has_node("HealthBar"):
		var bar = player.get_node("HealthBar")
		if bar.value <= bar.min_value:
			if portal:
				# Show label before transporting
				var info_label = Label.new()
				info_label.text = "You are exhausted! Returning to the Corporate Office..."
				info_label.modulate = Color(1, 0.3, 0.3, 1)
				info_label.global_position = player.global_position + Vector2(0, -80)
				info_label.z_index = 200
				get_tree().current_scene.add_child(info_label)
				var tween = create_tween()
				tween.tween_property(info_label, "modulate:a", 0, 1.0).set_delay(1.5)
				tween.finished.connect(info_label.queue_free)
				portal.visible = true
				await get_tree().create_timer(1.5).timeout # Delay before transporting
				get_tree().change_scene_to_file("res://scenes/CORP/corp_office.tscn")
	# Show interact prompt when player is near interactable (example usage)
	GlobalUI.show_interact_prompt(true)
