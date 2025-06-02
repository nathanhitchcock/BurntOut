## -- INIT --
extends Node2D

## -- VARIABLES & CONFIGURATIONS --
### -- inital variables ---
var leadership_points = 30
var current_wave = 1
var total_projects = 3
var current_project_progress = 0
var progress_per_wave = 1
var teammates := []
@onready var TeammateScene = preload("res://scenes/teammates/teammate_1.tscn")
var hired_teammate_2 = false

### -- defense variables
var defense_types = {
	"CoffeeMachine": {
		"scene": "res://scenes/defenses/CoffeeMachine.tscn",
		"cost": 1,
		"heal": 20
	},
	"StandingDesk": {
		"scene": "res://scenes/defenses/StandingDesk.tscn",
		"cost": 5,
		"reduction": 14
	}}
var selected_button: TextureButton = null
var current_defense_type = "CoffeeMachine" # Can be "CoffeeMachine" or "StandingDesk"
@export var defense_type: String = "CoffeeMachine"

### -- sfx sounds --
var sfx_ui_button
var sfx_coffee
var sfx_high_stress
var sfx_game_over
var sfx_victory
var sfx_hire_sound
var bgm
var sfx_evil_laugh

### -- New Features, Debugs, & Cheats --
var ceo_trigger_ready = false
var ceo_cutscene_played = false
var boss_wave_trigger = 25
var executive_progress = 0
var toggles_locked = true

var teammate_1_exec = false
func _on_teammate1_toggle_pressed():
	teammate_1_exec = !teammate_1_exec
	var label = "Executive" if teammate_1_exec else "Customer"
	var btn = get_node_or_null("Teammate1/Sprite2D/ToggleWorkButton")
	if btn:
		btn.text = label
	else:
		print("❌ ToggleWorkButton not found under teammate1")

## -- LIFECYCLE & HOOKS --
func _ready():
	# add the first teammate to the scene
	var teammate1 = TeammateScene.instantiate()
	teammate1.name = "Teammate1"
	teammate1.position = Vector2(-4, -2)
	teammate1.scale = Vector2(1, 1)  # 🧼 Reset any inherited scale
	add_child(teammate1)
	teammate1.add_to_group("teammates")
	print("📦 teammate1 loaded at:", teammate1.position)
	
	# initalize the timers
	randomize()
	$StressTimer.timeout.connect(_on_stress_timeout)
	update_leadership_display()
	update_wave_display()
	$CanvasLayer/ProjectProgressBar.max_value = total_projects * 10
	$CanvasLayer/ProjectProgressBar.value = current_project_progress
	teammates = get_tree().get_nodes_in_group("teammates")
	
	# - initalizing the audio -
	sfx_ui_button = $Audio/UIButtonSound
	sfx_coffee = $Audio/CoffeeSound
	sfx_high_stress = get_node("/root/Main/Audio/HighStressSound") if has_node("/root/Main/Audio/HighStressSound") else null
	sfx_game_over = $Audio/GameOverSound
	sfx_victory = $Audio/VictorySound
	sfx_hire_sound = $Audio/HirePoofSound
	sfx_evil_laugh = $Audio/EvilLaughSound
	bgm = $Audio/BackgroundMusic
	$CanvasLayer/DefenseHUD/HBoxContainer/VBoxContainer3/HireButton.pressed.connect(_on_HireButton_pressed)
	
	# - lock toggles at the start of the game -
	await get_tree().process_frame  # ensure all nodes are ready
	teammates = get_tree().get_nodes_in_group("teammates")
	print("Found", teammates.size(), "teammates.")

	for t in teammates:
		#var btn = t.get_node_or_null("ToggleWorkButton")
		var btn = get_node_or_null("Teammate1/Sprite2D/ToggleWorkButton")
		if btn:
			print("🔍 Found ToggleWorkButton under:", t.name)
			btn.disabled = true
			btn.modulate = Color(0.5, 0.5, 0.5)  # optional visual dimming
		else:
			print("❌ ToggleWorkButton not found under:", t.name)

	#- CEO Splash screen initialization 
	get_tree().paused = false
	var splash = get_node_or_null("CEOSplash")
	if splash:
		splash.queue_free()
	await get_tree().create_timer(3.0).timeout
	ceo_trigger_ready = true

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_position = get_viewport().get_mouse_position()
		var teammates = get_tree().get_nodes_in_group("teammates")

		for teammate in teammates:
			if teammate.is_burned_out:
				var click_area = teammate.get_node("ClickArea")
				if click_area and click_area is Area2D:
					if click_area.get_overlapping_point(click_position):
						try_revive(teammate)
						return
					
		# If no teammate was revived, try placing a defense
		place_defense(click_position)

func _process(_delta):
	if not ceo_cutscene_played and ceo_trigger_ready:
		if float(current_project_progress) / float(total_projects * 10) >= 0.7 or current_wave >= boss_wave_trigger:
			trigger_ceo_cutscene()
	if toggles_locked and executive_progress >= 50:
		unlock_toggles()

## -- CORE GAME MECHANICS --
### -- timers & state --
func _on_stress_timeout():
	var teammates = get_tree().get_nodes_in_group("teammates")
	var active_teammates = teammates.filter(func(t): return not t.is_burned_out)
	var damage = randi_range(1, 5)
	var is_high_stress_wave = current_wave % 5 == 0  # Every 5th wave
	# print("Active teammates:", active_teammates.size())
	
	if is_high_stress_wave:
		damage = randi_range(20, 30)
		# print("⚠️ HIGH STRESS WAVE! ⚠️ Damage: ", damage)
		$CanvasLayer/WaveLabel.text = "💥 High Stress Wave! 💥"
		flash_high_stress_effect()
		play_high_stress_sound()
		shake_background()
	
	if active_teammates.size() == 0:
		check_game_over()
		return
		
	# Choose target
	var chosen: Node
	if active_teammates.size() == 1:
		chosen = active_teammates[0]
	else:
		chosen = active_teammates[randi() % active_teammates.size()]

	# Shared defense logic
	var defenses = get_tree().get_nodes_in_group("defenses")
	var total_reduction = 0

	for defense in defenses:
		# print("🪑 Checking defense:", defense.name)
		var shape_node = defense.get_node_or_null("CollisionShape2D")
		if shape_node == null:
			shape_node = defense.get_node_or_null("Sprite2D/CollisionShape2D")

		if shape_node == null or shape_node.shape == null:
			# print("❌ Missing shape for", defense.name)
			continue

		if shape_node.shape is CircleShape2D:
			var radius = shape_node.shape.radius

			if chosen.has_method("get_target_position"):
				var distance = defense.global_position.distance_to(chosen.get_target_position())

				if distance <= radius:
					var def_type = null
					if defense.has_method("get") and "defense_type" in defense:
						def_type = defense.get("defense_type")
					else:
						print("❌ Defense has no defense_type!")

					var reduction = defense_types.get(def_type, {}).get("reduction", 0)
					total_reduction += reduction


	# ✅ Only apply damage after all defenses have been checked
	if total_reduction > 0:
		damage = max(damage - total_reduction, 0)
		show_defense_reduction_popup("-" + str(total_reduction) + " blocked", chosen.get_target_position())
		# print("Total damage reduction from defenses: ", total_reduction)
	
	# print("💢 Dealing", damage, "damage to", chosen.name)
	chosen.lower_morale(damage)
	
	if current_wave == 1 and not hired_teammate_2:
		$CanvasLayer/DefenseHUD/HBoxContainer/VBoxContainer3/HireButton.visible = true
		$CanvasLayer/DefenseHUD/HBoxContainer/VBoxContainer3/Label.visible = true
	
	check_game_over()
	
	# Reward leadership point and advance current_wave
	leadership_points += 1
	current_wave += 1
	update_leadership_display()
	update_wave_display()
	update_defense_hud()
	
	# new feature - CEO interruption and refocuses team
	for t in active_teammates:
		if not t.is_executive_mode:
			current_project_progress += progress_per_wave
		else:
			executive_progress += progress_per_wave

	print("📦 Customer Progress: ", current_project_progress, "/", total_projects * 10)
	print("📊 Executive Progress: ", executive_progress, "/ 10", total_projects)

	$CanvasLayer/ProjectProgressBar.value = current_project_progress
	$CanvasLayer/ExecutiveProgressBar.value = executive_progress

	if current_project_progress >= total_projects * 10:
		trigger_win_state()
		
	if executive_progress >= 100:
		trigger_ceo_victory()

func show_defense_reduction_popup(text: String, position: Vector2):
	print("🛡️ Showing blocked damage: ", text)
	var label = Label.new()
	label.text = text
	label.modulate = Color("7dc0ff")  # 💙 soft blue
	label.global_position = position + Vector2(65, -30)  # aligned with damage text
	label.z_index = 100

	# 👁‍🗨 Make it larger for visibility
	label.add_theme_font_size_override("font_size", 20)

	get_tree().current_scene.add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0, 1.2)  # slower fade
	tween.tween_property(label, "position:y", label.position.y - 20, 1.2)
	await tween.finished
	label.queue_free()

func trigger_ceo_cutscene():
	ceo_cutscene_played = true
	play_evil_laugh_sound()
	var cutscene = preload("res://scenes/CEOSplash.tscn").instantiate()
	add_child(cutscene)
	# Wait a frame to ensure cutscene is added before pausing
	await get_tree().process_frame
	get_tree().paused = true
	# Connect to cutscene finished signal if needed
	cutscene.connect("cutscene_finished", Callable(self, "_on_ceo_cutscene_finished"))

func _on_ceo_cutscene_finished():
	get_tree().paused = false

	for t in get_tree().get_nodes_in_group("teammates"):
		t.is_executive_mode = true

	show_fake_progress_bar()
	await get_tree().process_frame
	unlock_toggles()  # 🧠 let teammates handle visual sync

func show_fake_progress_bar():
	print("🎯 Showing fake progress bar (executive work)")
	$CanvasLayer/ExecutiveProgressBar.visible = true
	$CanvasLayer/ExecutiveWorkLabel.visible = true

func enable_team_toggles():
	for t in get_tree().get_nodes_in_group("teammates"):
		t.is_executive_mode = true
		t.lock_toggle()

func unlock_toggles():
	for t in get_tree().get_nodes_in_group("teammates"):
		t.unlock_toggle()

### -- defense placement --
func select_defense(type: String):
	current_defense_type = type
	update_defense_hud()
	# Reset visual highlight for all buttons
	for vbox in $CanvasLayer/DefenseHUD/HBoxContainer.get_children():
		var btn = vbox.get_node("TextureButton")
		if btn:
			btn.scale = Vector2.ONE  # Reset size

	# Highlight selected button
	for vbox in $CanvasLayer/DefenseHUD/HBoxContainer.get_children():
		var btn = vbox.get_node("TextureButton")
		if btn and "defense_type" in btn and btn.defense_type == type:
			btn.scale = Vector2(1.1, 1.1)
			selected_button = btn

	print("Selected defense:", type)
	update_defense_hud()

func place_defense(position: Vector2):
	var def_info = defense_types.get(current_defense_type)
	if def_info == null:
		print("Invalid defense type!")
		return
	
	var cost = def_info.cost
	if leadership_points < cost:
		# print("Not enough Leadership Points!")
		show_insufficient_points_warning()
		return
	
	var scene_path = def_info.scene
	var DefenseScene = load(scene_path)
	var defense = DefenseScene.instantiate()
	add_child(defense)
	defense.position = position
	defense.add_to_group("defenses")
	
	# 🧱 Set its type for later reference in damage calculation
	defense.defense_type = current_defense_type
	
	# ☕️ Heal teammates if this is a CoffeeMachine
	if current_defense_type == "CoffeeMachine":
		play_coffee_sound()
		var teammates = get_tree().get_nodes_in_group("teammates")
		for t in teammates:
			if t.get_target_position().distance_to(position) < 100:
				t.restore_morale(defense_types["CoffeeMachine"].get("heal", 0))
				show_heal_effect(t.get_target_position())
		# ☕️ Coffee is a one-time use — remove after healing
		await get_tree().create_timer(0.5).timeout  # slight delay before fade
		var tween = create_tween()
		tween.tween_property(defense, "modulate:a", 0.0, 0.5)  # fade over 0.5s
		await tween.finished
		defense.queue_free()

	leadership_points -= cost
	update_leadership_display()
	update_defense_hud()
	
	print(current_defense_type, " placed at ", position)

### -- team management --
func _on_HireButton_pressed():
	var cost = 10
	if leadership_points < cost:
		# print("Not enough Leadership Points to hire!")
		show_insufficient_points_warning()
		return

	leadership_points -= cost
	update_leadership_display()

	hire_teammate("res://scenes/teammates/teammate_2.tscn", Vector2(389.688, 329.507)) # Adjust position as needed
	hired_teammate_2 = true
	$CanvasLayer/DefenseHUD/HBoxContainer/VBoxContainer3/HireButton.visible = false
	$CanvasLayer/DefenseHUD/HBoxContainer/VBoxContainer3/Label.visible = false
	print("🧑‍💻 Teammate 2 hired!")

func hire_teammate(scene_path: String, position: Vector2):
	var TeammateScene = load(scene_path)
	var new_teammate = TeammateScene.instantiate()
	add_child(new_teammate)
	new_teammate.position = position
	# print("📍 Teammate positioned at: ", position)
	new_teammate.add_to_group("teammates")
	play_hire_sound()
	
	# Add hiring poof
	var PoofScene = preload("res://scenes/vfx/HirePoof.tscn")
	var poof = PoofScene.instantiate()
	add_child(poof)
	poof.global_position = position
	await get_tree().create_timer(1.0).timeout
	poof.queue_free()
	

### -- player actions --
func try_revive(teammate):
	var cost = teammate.revive_cost if teammate.has_method("revive_cost") else 2
	
	if leadership_points < cost:
		print("Not enough Leadership Points to revive!")
		show_insufficient_points_warning()
		return

	leadership_points -= cost
	teammate.revive()
	update_leadership_display()
	update_defense_hud()

## -- UI UPDATES --
func update_leadership_display():
	$CanvasLayer/LeadershipLabel.text = "Points: " + str(leadership_points)

func update_wave_display():
	$CanvasLayer/WaveLabel.text = "Stress Level: %s" % str(current_wave)

func flash_high_stress_effect():
	$CanvasLayer/HighStressFlash.visible = true
	await get_tree().create_timer(0.2).timeout
	$CanvasLayer/HighStressFlash.visible = false

func shake_background():
	var wrapper = $BackgroundWrapper
	var original_pos = wrapper.position
	var tween = create_tween()

	tween.tween_property(wrapper, "position", original_pos + Vector2(8, 0), 0.05)
	tween.tween_property(wrapper, "position", original_pos - Vector2(8, 0), 0.05)
	tween.tween_property(wrapper, "position", original_pos, 0.05)

func update_defense_hud():
	# print("🛠 update_defense_hud() triggered")
	for vbox in $CanvasLayer/DefenseHUD/HBoxContainer.get_children():
		var btn: TextureButton = null
		for child in vbox.get_children():
			if child is TextureButton:
				btn = child
				break
		if btn == null:
			continue

		# Access defense_type directly
		var def_type = btn.defense_type if "defense_type" in btn else null
		if def_type == null or not defense_types.has(def_type):
			continue

		var cost = defense_types[def_type].cost

		# Dim if unaffordable
		btn.modulate = Color(1, 1, 1, 1) if leadership_points >= cost else Color(0.5, 0.5, 0.5, 1)

		# Highlight if selected
		if def_type == current_defense_type:
			btn.self_modulate = Color(1, 1, 1, 1)
			btn.scale = Vector2(1.2, 1.2)
		else:
			btn.self_modulate = Color(0.8, 0.8, 0.8, 1)
			btn.scale = Vector2(1, 1)

func show_insufficient_points_warning():
	var label = $CanvasLayer/InsufficientPointsLabel
	label.visible = true

	var original_pos = label.position

	var tween := create_tween()
	tween.tween_property(label, "position", original_pos + Vector2(-10, 0), 0.05)
	tween.tween_property(label, "position", original_pos + Vector2(10, 0), 0.05)
	tween.tween_property(label, "position", original_pos + Vector2(-6, 0), 0.05)
	tween.tween_property(label, "position", original_pos + Vector2(6, 0), 0.05)
	tween.tween_property(label, "position", original_pos, 0.05)

	await get_tree().create_timer(1.5).timeout
	label.visible = false

func show_heal_effect(position: Vector2):
	var label = Label.new()
	label.text = "+20 Morale"
	label.modulate = Color("46f2a3")  # Soothing green
	label.global_position = position + Vector2(0, -30)
	add_child(label)

	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0, 1.0)
	tween.tween_property(label, "position:y", label.position.y - 20, 1.0)
	await tween.finished
	label.queue_free()

## -- AUDIO HELPERS --
func play_ui_sound():
	if sfx_ui_button:
		sfx_ui_button.play()

func play_coffee_sound():
	if sfx_coffee:
		sfx_coffee.play()

func play_high_stress_sound():
	if sfx_high_stress:
		sfx_high_stress.play()

func play_game_over_sound():
	if sfx_game_over:
		sfx_game_over.play()

func play_victory_sound():
	if sfx_victory:
		sfx_victory.play()

func stop_music():
	if bgm:
		bgm.stop()

func play_hire_sound():
	if sfx_hire_sound:
		sfx_hire_sound.play()
		
func play_evil_laugh_sound():
	if sfx_evil_laugh:
		sfx_evil_laugh.play()

## -- END GAME  --
func check_game_over():
	var teammates = get_tree().get_nodes_in_group("teammates")
	var all_burned_out = true
	for teammate in teammates:
		if not teammate.is_burned_out:
			all_burned_out = false
			break
	if all_burned_out:
		print("💀 All teammates burned out!")
		trigger_game_over()
		# $CanvasLayer/GameOverLabel.visible = true
		# play_game_over_sound()
		# cleanup_game()

func trigger_game_over():
	cleanup_game()
	var loss_screen = preload("res://scenes/Game Over/GameOver-Burnout.tscn").instantiate()
	add_child(loss_screen)
	play_game_over_sound()

func trigger_win_state():
	print("🏆 YOU WIN!")
	$CanvasLayer/VictoryLabel.visible = true
	play_victory_sound()
	cleanup_game()

func trigger_ceo_victory():
	print("🛫 CEO Victory Achieved — customers be damned")
	play_victory_sound()
	get_tree().paused = false
	var ceo_win_screen = preload("res://scenes/Game Over/GameOver-CEOVictoryScreen.tscn").instantiate()
	add_child(ceo_win_screen)
	cleanup_game()

func cleanup_game():
	$CanvasLayer/ProjectProgressBar.visible = false
	$CanvasLayer/ExecutiveProgressBar.visible = false
	$CanvasLayer/ExecutiveWorkLabel.visible = false
	$StressTimer.stop()
	stop_music()
	$CanvasLayer/DefenseHUD.visible = false
	
	# Remove all defenses
	for defense in get_tree().get_nodes_in_group("defenses"):
		defense.queue_free() 
