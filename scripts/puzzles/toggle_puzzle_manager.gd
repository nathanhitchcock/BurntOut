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
	for i in range(TOGGLE_COUNT):
		indices.append(i)
	indices.shuffle()
	solution = indices.duplicate()
	print("[TogglePuzzle] Solution:", solution)

	# Connect signals from all ToggleButton children
	for i in range(TOGGLE_COUNT):
		var btn = get_node("ToggleButton%d" % (i+1))
		if btn:
			btn.toggle_index = i
			btn.connect("toggle_pressed", Callable(self, "_on_toggle_pressed"))
			# Disable mouse input for accessibility: toggles are only activated by keyboard
			btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Remove gui_input connection for mouse clicks

	# Connect Area2D signals for each ToggleButton
	for i in range(TOGGLE_COUNT):
		var btn = get_node("ToggleButton%d" % (i+1))
		if btn and btn.has_node("Area2D"):
			var area = btn.get_node("Area2D")
			area.body_entered.connect(_on_toggle_area_body_entered.bind(i, btn))
			area.body_exited.connect(_on_toggle_area_body_exited.bind(i, btn))
		# Connect GUI input to track mouse selection
		if btn.has_method("connect"):
			btn.connect("gui_input", Callable(self, "_on_toggle_button_gui_input").bind(i))

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
			# Randomize damage between 5 and 10
			var damage = randi_range(5, 10)
			if player and player.has_method("take_damage"):
				player.take_damage(damage) # Deal random damage on fail
			elif player and player.has_node("HealthBar"):
				var bar = player.get_node("HealthBar")
				bar.value = max(bar.value - damage, bar.min_value)
			if incorrect_label:
				incorrect_label.visible = true
				# No await/timer needed, just show until next input
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
		player_sequence.clear()
		_reset_toggles()

func _reset_toggles():
	for i in range(TOGGLE_COUNT):
		var btn = get_node("ToggleButton%d" % (i+1))
		if btn:
			btn.is_on = false
			btn.update_visual()

# Track which button the player is near
var player_near_toggle := [-1, -1, -1]
var interact_prompt_shown := [false, false, false]

func _on_toggle_area_body_entered(body, toggle_index, btn):
	if body.name == "Player":
		player_near_toggle[toggle_index] = 1
		if not interact_prompt_shown[toggle_index]:
			# Show the floating [E] prompt near the player's head (use player global position)
			if GlobalUI and GlobalUI.has_method("show_interact_popup_near_player"):
				GlobalUI.show_interact_popup_near_player(player)
			interact_prompt_shown[toggle_index] = true
		# Do NOT trigger the button interaction here; wait for input

func _on_toggle_area_body_exited(body, toggle_index, btn):
	if body.name == "Player":
		player_near_toggle[toggle_index] = -1
		if interact_prompt_shown[toggle_index]:
			GlobalUI.show_interact_prompt(false)
			interact_prompt_shown[toggle_index] = false

func _process(_delta):
	# Handle interaction for toggles
	var toggle_to_press := -1
	for i in range(TOGGLE_COUNT):
		if player_near_toggle[i] == 1:
			toggle_to_press = i
			break
	if toggle_to_press != -1 and Input.is_action_just_pressed("ui_accept"):
		var btn = get_node("ToggleButton%d" % (toggle_to_press+1))
		if btn:
			btn._on_pressed()
	# Show interact prompt when player is near interactable (example usage)
	GlobalUI.show_interact_prompt(true)
