extends Node2D

@export var bug_scene: PackedScene
@export var bug_count := 10
@export var spawn_area_top_left := Vector2(0, 0)
@export var spawn_area_bottom_right := Vector2(1024, 768)
var bugs := []
var bugs_remaining := 0
var win_label: Label = null
var count_label: Label = null
var bugs_smashed := 0
var total_bugs := 0

# Margin to keep bugs away from walls
const BUG_SPAWN_MARGIN := 0
const BUG_MIN_SPAWN_DISTANCE := 128.0 # Minimum distance between bugs

func _ready():
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
	
	# Create a win label but keep it hidden
	win_label = Label.new()
	win_label.text = "You Win!"
	win_label.visible = false
	win_label.position = Vector2(200, 100)
	win_label.add_theme_color_override("font_color", Color(1,1,0))
	win_label.add_theme_font_size_override("font_size", 48)
	add_child(win_label)
	# Create a count label
	count_label = Label.new()
	count_label.text = "Bugs Smashed: %d / %d" % [bugs_smashed, total_bugs]
	count_label.position = Vector2(200, 50)
	count_label.add_theme_color_override("font_color", Color(1,1,1))
	count_label.add_theme_font_size_override("font_size", 32)
	add_child(count_label)

func register_bug(bug):
	if bug and not bugs.has(bug):
		bugs.append(bug)
		total_bugs += 1
		bugs_remaining += 1
		print("[BugSmashManager] Registered bug. Total bugs: %d, Bugs remaining: %d" % [total_bugs, bugs_remaining])
		if count_label:
			count_label.text = "Bugs Smashed: %d / %d" % [bugs_smashed, total_bugs]
			print("[BugSmashManager] Updated label to: %s" % count_label.text)

func on_bug_smashed():
	bugs_remaining -= 1
	bugs_smashed += 1
	print("[BugSmashManager] Bug smashed! Bugs remaining: %d, Bugs smashed: %d / %d" % [bugs_remaining, bugs_smashed, total_bugs])
	if count_label:
		count_label.text = "Bugs Smashed: %d / %d" % [bugs_smashed, total_bugs]
		print("[BugSmashManager] Updated label to: %s" % count_label.text)
	if bugs_remaining <= 0:
		puzzle_complete()

func puzzle_complete():
	print("Puzzle complete! All bugs smashed!")
	if win_label:
		win_label.visible = true
	# Reward player with a sprint point
	if has_node("/root/player_data"):
		get_node("/root/player_data").sprint_points += 1
