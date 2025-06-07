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
			if fail_sound:
				fail_sound.play()
			if incorrect_label:
				incorrect_label.visible = true
				await get_tree().create_timer(1.0).timeout
				incorrect_label.visible = false
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
		# TODO: Add your puzzle completion logic here
		player_sequence.clear()
		_reset_toggles()

func _reset_toggles():
	for i in TOGGLE_COUNT:
		var btn = get_node("ToggleButton%d" % (i+1))
		if btn:
			btn.is_on = false
			btn.update_visual()
