extends Node2D

# The correct sequence of toggle indices to solve the puzzle
var solution: Array = []
# The player's current input sequence
var player_sequence: Array = []
# Number of toggles in the puzzle
const TOGGLE_COUNT := 3

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

func _on_toggle_pressed(toggle_index: int):
	print("[TogglePuzzle] Player pressed:", toggle_index)
	player_sequence.append(toggle_index)
	# Check if the player's input matches the solution so far
	for i in player_sequence.size():
		if player_sequence[i] != solution[i]:
			print("[TogglePuzzle] Incorrect! Resetting.")
			player_sequence.clear()
			_reset_toggles()
			return
	# If the player has completed the sequence
	if player_sequence.size() == solution.size():
		print("[TogglePuzzle] Puzzle solved!")
		# TODO: Add your puzzle completion logic here
		player_sequence.clear()
		_reset_toggles()

func _reset_toggles():
	for i in TOGGLE_COUNT:
		var btn = get_node("ToggleButton%d" % (i+1))
		if btn:
			btn.is_on = false
			btn.update_visual()
