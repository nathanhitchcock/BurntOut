extends Node2D

@export var bug_scene: PackedScene
@export var bug_count := 10
@export var spawn_area_top_left := Vector2(0, 0)
@export var spawn_area_bottom_right := Vector2(1024, 768)
var bugs := []
var bugs_remaining := 0
var bugs_smashed := 0
var total_bugs := 0
var initial_big_bugs := 0  # Track the initial number of big bugs for reward calculation
var global_ui: CanvasLayer = null

# Margin to keep bugs away from walls
const BUG_SPAWN_MARGIN := 0
const BUG_MIN_SPAWN_DISTANCE := 128.0 # Minimum distance between bugs

func _ready():
	# Get Global UI reference
	global_ui = get_node_or_null("/root/GlobalUI")
	if global_ui:
		global_ui.show_bug_counter()
		print("[BugSmashManager] Connected to Global UI")
	else:
		print("[BugSmashManager] WARNING: Could not find Global UI")
	
	# Randomize the number of bugs (2-10)
	bug_count = randi_range(2, 10)
	initial_big_bugs = bug_count  # Store for reward calculation
	print("[BugSmashManager] Randomized bug count:", bug_count, " (initial big bugs for reward:", initial_big_bugs, ")")
	
	# Calculate safe spawn area based on wall positions and margin
	var left = spawn_area_top_left.x + BUG_SPAWN_MARGIN
	var right = spawn_area_bottom_right.x - BUG_SPAWN_MARGIN
	var top = spawn_area_top_left.y + BUG_SPAWN_MARGIN
	var bottom = spawn_area_bottom_right.y - BUG_SPAWN_MARGIN
	# Spawn bugs at random positions within safe area
	bugs = []
	total_bugs = 0
	bugs_smashed = 0
	bugs_remaining = 0
	
	for i in range(bug_count):
		if bug_scene:
			var tries = 0
			var max_tries = 20
			var pos = Vector2.ZERO
			var valid = false
			while not valid and tries < max_tries:
				pos = Vector2(
					randi_range(left, right),
					randi_range(top, bottom)
				)
				valid = true
				for other in bugs:
					if pos.distance_to(other.position) < BUG_MIN_SPAWN_DISTANCE:
						valid = false
						break
				tries += 1
			var bug = bug_scene.instantiate()
			bug.position = pos
			add_child(bug)
			# Use register_bug for consistency instead of directly manipulating bugs array
			register_bug(bug)
	
	if bugs_remaining == 0:
		print("[BugSmashManager] No bugs found!")
	
	# Update Global UI bug counter instead of creating local labels
	if global_ui:
		global_ui.update_bug_counter(bugs_smashed, total_bugs)

func register_bug(bug):
	if bug and not bugs.has(bug):
		bugs.append(bug)
		total_bugs += 1
		bugs_remaining += 1
		print("[BugSmashManager] Registered bug. Total bugs: %d, Bugs remaining: %d" % [total_bugs, bugs_remaining])
		if global_ui:
			global_ui.update_bug_counter(bugs_smashed, total_bugs)
			print("[BugSmashManager] Updated Global UI bug counter")

func on_bug_smashed():
	bugs_remaining -= 1
	bugs_smashed += 1
	print("[BugSmashManager] Bug smashed! Bugs remaining: %d, Bugs smashed: %d / %d" % [bugs_remaining, bugs_smashed, total_bugs])
	if global_ui:
		global_ui.update_bug_counter(bugs_smashed, total_bugs)
		print("[BugSmashManager] Updated Global UI bug counter")
	if bugs_remaining <= 0:
		puzzle_complete()

func puzzle_complete():
	print("Puzzle complete! All bugs smashed!")
	if global_ui:
		global_ui.show_bug_win()
	# Reward player with sprint points equal to initial big bugs
	if has_node("/root/player_data"):
		get_node("/root/player_data").sprint_points += initial_big_bugs
		print("[BugSmashManager] Rewarded", initial_big_bugs, "sprint points for completing puzzle!")

# Called when player enters the bug room
func _enter_tree():
	if global_ui:
		global_ui.show_bug_counter()

# Called when player exits the bug room
func _exit_tree():
	if global_ui:
		global_ui.hide_bug_counter()
		global_ui.hide_bug_win()
