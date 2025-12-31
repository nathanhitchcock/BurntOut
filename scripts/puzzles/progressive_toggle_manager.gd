extends Node2D

# Progressive difficulty toggle puzzle system
# Starts with 1 toggle, progressively adds more after each successful solve

# Current difficulty level (number of toggles to solve)
var current_level: int = 1
var max_level: int = 10  # Can be adjusted based on room size/balance

# Puzzle state
var solution: Array = []
var player_sequence: Array = []
var active_toggles: Array = []  # Array of active toggle nodes
var is_level_active: bool = false  # Lock input during transitions

# Toggle spawning positions (predefined grid)
var toggle_positions: Array = []

# References
@onready var toggle_button_scene = preload("res://scenes/CORP/toggle_room/ToggleButton.tscn")
@onready var player = $Player if has_node("Player") else null
@onready var portal = $PortalToCorpOffice if has_node("PortalToCorpOffice") else null

# Audio/UI
@onready var success_sound = $SuccessSound if has_node("SuccessSound") else null
@onready var fail_sound = $FailSound if has_node("FailSound") else null

func _ready():
	print("[ProgressiveToggle] Starting progressive toggle puzzle system")
	
	# Set player z-index to be in front of toggles
	if player:
		player.z_index = 10
		print("[ProgressiveToggle] Set player z-index to 10")
	
	# Initialize toggle spawn positions in a grid pattern
	_setup_toggle_positions()
	
	# Start with level 1 (1 toggle)
	_start_level(current_level)

func _setup_toggle_positions():
	# Create a grid of positions where toggles can spawn
	# Adjust these coordinates based on the toggle room layout
	var center_x = 0
	var center_y = -100  # Move up a bit to be more centered in the room
	var spacing = 150  # Increase spacing for better visibility
	
	# Create a 4x3 grid (enough for up to 12 toggles)
	for row in range(3):
		for col in range(4):
			var pos = Vector2(
				center_x + (col - 1.5) * spacing,
				center_y + (row - 1) * spacing
			)
			toggle_positions.append(pos)
	
	print("[ProgressiveToggle] Setup", toggle_positions.size(), "toggle positions")

func _start_level(level: int):
	print("[ProgressiveToggle] Starting level", level, "with", level, "toggles")
	is_level_active = true
	
	# Clear any existing toggles
	_clear_toggles()
	
	# Reset puzzle state
	solution.clear()
	player_sequence.clear()
	active_toggles.clear()
	
	# Spawn the required number of toggles for this level
	_spawn_toggles(level)
	
	# Generate solution sequence
	_generate_solution(level)
	
	# Update Global UI to show current level info
	if GlobalUI and GlobalUI.has_method("show_toggle_level_info"):
		GlobalUI.show_toggle_level_info(level, level)  # (current_level, reward_points)

func _spawn_toggles(count: int):
	# Use the first 'count' positions to spawn toggles
	for i in range(min(count, toggle_positions.size())):
		var toggle = toggle_button_scene.instantiate()
		toggle.position = toggle_positions[i]
		toggle.toggle_index = i
		toggle.name = "Toggle_" + str(i)
		toggle.z_index = 0  # Set toggles to background layer
		toggle.scale = Vector2(0.5, 0.5)  # Make toggles half size
		# Ensure input is enabled for a new level
		if "disabled" in toggle:
			toggle.disabled = false
		
		# Enable mouse interaction but prevent focus issues
		toggle.mouse_filter = Control.MOUSE_FILTER_PASS
		toggle.focus_mode = Control.FOCUS_NONE  # Prevent focus to avoid [E] key conflicts
		
		# Connect the toggle signal
		toggle.connect("toggle_pressed", Callable(self, "_on_toggle_pressed"))
		
		# Connect Area2D signals (Area2D is now built into the ToggleButton scene)
		if toggle.has_node("Area2D"):
			var area = toggle.get_node("Area2D")
			area.body_entered.connect(_on_toggle_area_body_entered.bind(i, toggle))
			area.body_exited.connect(_on_toggle_area_body_exited.bind(i, toggle))
			print("[ProgressiveToggle] Connected Area2D signals for toggle", i)
		else:
			print("[ProgressiveToggle] Warning: No Area2D found in toggle", i)
		
		add_child(toggle)
		active_toggles.append(toggle)
		
		print("[ProgressiveToggle] Spawned toggle", i, "at position", toggle.position)

func _generate_solution(level: int):
	# Create a random sequence of all toggle indices
	solution.clear()
	for i in range(level):
		solution.append(i)
	solution.shuffle()
	
	print("[ProgressiveToggle] Generated solution for level", level, ":", solution)

func _clear_toggles():
	# Remove all existing toggle nodes
	for toggle in active_toggles:
		if is_instance_valid(toggle):
			toggle.queue_free()
	active_toggles.clear()

func _reset_toggles():
	# Reset all toggle button states to OFF without removing them
	for toggle in active_toggles:
		if is_instance_valid(toggle):
			toggle.is_on = false
			toggle.update_visual()
	print("[ProgressiveToggle] Reset all toggle button states to OFF")

func _on_toggle_pressed(toggle_index: int):
	print("[ProgressiveToggle] Player pressed toggle:", toggle_index)
	# Ignore input when level is transitioning to the next set
	if not is_level_active or solution.size() == 0:
		return
	player_sequence.append(toggle_index)

	# Check if the player's input matches the solution so far (guard array bounds)
	var upto: int = min(player_sequence.size(), solution.size())
	for i in upto:
		if player_sequence[i] != solution[i]:
			print("[ProgressiveToggle] Incorrect sequence! Resetting level.")
			_handle_failure()
			return
	
	# Check if puzzle is solved
	if player_sequence.size() == solution.size():
		_handle_success()

func _handle_failure():
	# Deal damage to player
	var damage = randi_range(3, 8)  # Moderate damage for failing
	if player and player.has_method("take_damage"):
		player.take_damage(damage)
		print("[ProgressiveToggle] Player took", damage, "damage for incorrect sequence")
	
	# Play fail sound
	if fail_sound and fail_sound.is_inside_tree():
		fail_sound.play()
	
	# Show feedback
	if player and player.has_method("show_floating_feedback"):
		# Offset further upward to avoid overlapping shield/damage labels
		player.show_floating_feedback("Wrong sequence!", Color(0.9, 0.2, 0.2, 1), Vector2(0, -40))
	
	# Reset the player sequence and toggle states, but keep the same level
	player_sequence.clear()
	_reset_toggles()
	
	print("[ProgressiveToggle] Incorrect sequence! Resetting button states but keeping level", current_level)

func _handle_success():
	print("[ProgressiveToggle] Level", current_level, "completed!")
	# Lock input while we transition to the next level
	is_level_active = false
	# Disable existing toggles to prevent further presses
	for t in active_toggles:
		if is_instance_valid(t) and ("disabled" in t):
			t.disabled = true
	
	# Play success sound
	if success_sound and success_sound.is_inside_tree():
		success_sound.play()
	
	# Award points equal to the current level
	var points_awarded = current_level
	if has_node("/root/player_data"):
		get_node("/root/player_data").sprint_points += points_awarded
	
	# Show feedback
	if player and player.has_method("show_floating_feedback"):
		var message = "+%d Sprint Points!" % points_awarded
		player.show_floating_feedback(message, Color(0.2, 0.9, 0.2, 1))
	
	# Update productivity progress
	if has_node("/root/player_data"):
		var pd = get_node("/root/player_data")
		var progress_gain = 0.1 * current_level  # More progress for higher levels
		pd.productivity_progress = clamp(pd.productivity_progress + progress_gain, 0.0, 1.0)
		pd.emit_signal("puzzle_solved", progress_gain)
	
	# Check if we've reached max level
	if current_level >= max_level:
		_handle_puzzle_complete()
		return
	
	# Advance to next level
	current_level += 1
	await get_tree().create_timer(1.5).timeout  # Brief celebration pause
	_start_level(current_level)

func _handle_puzzle_complete():
	print("[ProgressiveToggle] All levels completed! Puzzle finished.")
	
	# Show completion message
	if player and player.has_method("show_floating_feedback"):
		player.show_floating_feedback("All Levels Complete!", Color(1, 1, 0, 1))
	
	# Enable portal/exit
	if portal:
		portal.visible = true
	
	# Clear toggles since puzzle is done
	_clear_toggles()
	
	# Update Global UI
	if GlobalUI and GlobalUI.has_method("show_toggle_level_info"):
		GlobalUI.show_toggle_level_info(0, 0)  # Hide level info

# Player interaction tracking
var player_near_toggle := {}
var interact_prompt_shown := {}

func _on_toggle_area_body_entered(body, toggle_index, btn):
	if body.name == "Player":
		player_near_toggle[toggle_index] = true
		if not interact_prompt_shown.get(toggle_index, false):
			if GlobalUI and GlobalUI.has_method("show_interact_popup_near_player"):
				GlobalUI.show_interact_popup_near_player(player)
				print("[ProgressiveToggle] Showing [E] prompt for toggle", toggle_index)
			interact_prompt_shown[toggle_index] = true

func _on_toggle_area_body_exited(body, toggle_index, btn):
	if body.name == "Player":
		player_near_toggle[toggle_index] = false
		if interact_prompt_shown.get(toggle_index, false):
			if GlobalUI and GlobalUI.has_method("show_interact_prompt"):
				GlobalUI.show_interact_prompt(false)
				print("[ProgressiveToggle] Hiding [E] prompt for toggle", toggle_index)
			interact_prompt_shown[toggle_index] = false

func _process(_delta):
	# Block interaction via [E] during transitions or after solve
	if not is_level_active:
		return
	# Handle player interaction with toggles via [E] key only
	# Note: Mouse clicks are handled directly by the TextureButton
	if Input.is_action_just_pressed("ui_accept"):
		# Find which toggle the player is currently near
		var nearest_toggle_index = -1
		for toggle_index in player_near_toggle:
			if player_near_toggle[toggle_index]:
				nearest_toggle_index = toggle_index
				break
		
		# Only activate if player is actually near a toggle
		if nearest_toggle_index != -1 and nearest_toggle_index < active_toggles.size():
			var toggle = active_toggles[nearest_toggle_index]
			if toggle and is_instance_valid(toggle):
				# Respect disabled state; do not press programmatically if disabled
				if ("disabled" in toggle) and toggle.disabled:
					return
				print("[ProgressiveToggle] [E] key pressed near toggle", nearest_toggle_index)
				toggle._on_pressed()
	
	# Show interact prompt when near any toggle
	var near_any_toggle = false
	for is_near in player_near_toggle.values():
		if is_near:
			near_any_toggle = true
			break
	
	if GlobalUI:
		GlobalUI.show_interact_prompt(near_any_toggle)

# Functions for room management
func _exit_tree():
	# Clean up UI when the node is removed from the scene tree
	if GlobalUI and GlobalUI.has_method("hide_toggle_level_info"):
		GlobalUI.hide_toggle_level_info()

func reset_puzzle():
	# Function to reset the entire puzzle (useful for testing)
	current_level = 1
	_clear_toggles()
	_start_level(current_level)
