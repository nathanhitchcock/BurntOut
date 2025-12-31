extends Sprite2D

@onready var screen_flicker = $ScreenFlicker
@onready var candle = $Candle
@onready var progress_bar = $ProgressBar if has_node("ProgressBar") else null
var _end_triggered: bool = false

# Flicker parameters
var flicker_timer := 0.0
var flicker_interval := 0.03

# Candle flicker parameters
var candle_base_pos := Vector2.ZERO
var candle_base_scale := Vector2.ONE

# 🧾 Productivity Machine Proximity Phrases
var proximity_quotes := [
	# 🔥 Motivational (but off)
	"Stay productive. Stay flammable.",
	"Success is measured in sprints, not survival.",
	"One more push. One more loop.",
	"Efficiency is your only virtue.",
	"You're not tired. You're trending upward.",
	# 💀 Creepy Corporate
	"Your burnout is our breakthrough.",
	"We monitor with care.",
	"Emotion detected. Suppressing...",
	"All morale units must be accounted for.",
	"Human capital approaching terminal velocity.",
	# 🧘 Ritualistic & Arcane
	"The gears require sacrifice.",
	"The system remembers your effort.",
	"You have been seen.",
	"Flame acknowledged. Continue offering.",
	"Offer your spark and be unburdened.",
	# 💼 Bureaucratic Weirdness
	"Loop quota 63% complete.",
	"All anomalies logged. Resume cycle.",
	"Unauthorized passion will be deprecated.",
	"Please refrain from self-awareness.",
	"Congratulations. Your suffering is within expected parameters.",
	# 🌱 Poetic or Ominous
	"The plant grows. The room darkens.",
	"It feeds on what you leave behind.",
	"One day, this will all make sense. Probably.",
	"The system hums your name.",
	"You’re not done yet. You’re never done."
]

@onready var area2d = $Area2D if has_node("Area2D") else null
@onready var player_data = get_node_or_null("/root/player_data")

# Remove local machine_points, use player_data.machine_points
var max_machine_points: int = 10

func _ready():
	if candle:
		candle_base_pos = candle.position
		candle_base_scale = candle.scale
	if progress_bar:
		progress_bar.max_value = max_machine_points
		progress_bar.value_changed.connect(_on_progress_value_changed)
	if area2d:
		area2d.body_entered.connect(_on_area2d_body_entered)
	# Connect SpendButton if present
	var spend_button = get_node_or_null("SpendButton")
	if spend_button:
		spend_button.pressed.connect(_on_spend_button_pressed)
	# Set progress bar from persistent machine_points
	if progress_bar and player_data:
		progress_bar.value = clamp(player_data.machine_points, progress_bar.min_value, progress_bar.max_value)
		_check_end_condition()

func _process(delta):
	# CRT screen flicker: randomize modulate.a and color slightly
	if screen_flicker:
		flicker_timer += delta
		if flicker_timer > flicker_interval:
			flicker_timer = 0.0
			var flicker_alpha = randf_range(0.05, 0.18)
			var flicker_color = Color(1, 1, 1, flicker_alpha)
			# Add a slight green/blue tint for CRT effect
			flicker_color.g = clamp(0.9 + randf_range(-0.05, 0.05), 0.85, 1.0)
			flicker_color.b = clamp(0.9 + randf_range(-0.05, 0.05), 0.85, 1.0)
			screen_flicker.modulate = flicker_color

	# Candle flicker: randomize scale and position for a fire effect
	if candle:
		var flicker_offset = Vector2(randf_range(-1.5, 1.5), randf_range(-2.5, 2.5))
		var flicker_scale = Vector2(1.0 + randf_range(-0.07, 0.07), 1.0 + randf_range(-0.12, 0.12))
		candle.position = candle_base_pos + flicker_offset
		candle.scale = candle_base_scale * flicker_scale

	# Update ProgressBar from persistent machine_points
	if progress_bar and player_data:
		progress_bar.value = clamp(player_data.machine_points, progress_bar.min_value, progress_bar.max_value)
		_check_end_condition()

func _on_area2d_body_entered(body):
	if body.name == "Player":
		_show_random_quote()
		_show_spend_prompt()

func _show_spend_prompt():
	# Show a floating label: Press [E] to spend 1 Sprint Point on the machine
	var label = Label.new()
	# label.text = "Press [E] to spend 1 Sprint Point on the machine"
	label.modulate = Color(0.8, 1, 1, 0.95)
	label.add_theme_font_size_override("font_size", 48)
	label.position = Vector2(0, 80)
	label.z_index = 101
	label.name = "SpendPromptLabel"
	add_child(label)
	# Remove after 2.5s or if spent
	label.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.95, 0.5)
	tween.tween_property(label, "modulate:a", 0, 2.0).set_delay(2.0)
	tween.finished.connect(label.queue_free)

func _input(event):
	if area2d and area2d.get_overlapping_bodies().has(get_tree().current_scene.get_node_or_null("Player")):
		if event.is_action_pressed("ui_accept"):
			_spend_sprint_point()

func _spend_sprint_point():
	var pd = get_node("/root/player_data")
	if pd.sprint_points > 0 and pd.machine_points < max_machine_points:
		pd.sprint_points -= 1
		pd.machine_points += 1
		_show_floating_feedback("+1 to Machine!", Color(0.2, 0.9, 1, 1))
	else:
		_show_floating_feedback("No points to spend!", Color(1,0.2,0.2,1))

func _show_floating_feedback(text, color):
	var label = Label.new()
	label.text = text
	label.modulate = color
	label.add_theme_font_size_override("font_size", 48)
	label.position = Vector2(0, -120)
	label.z_index = 102
	add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0, 2.0)
	tween.tween_property(label, "position:y", label.position.y - 40, 2.0)
	tween.finished.connect(label.queue_free)

func _show_random_quote():
	var quote = proximity_quotes[randi() % proximity_quotes.size()]
	# Show as a floating label bottom right of the machine (larger text)
	var label = Label.new()
	label.text = quote
	label.modulate = Color(1, 1, 1, 0.95)
	label.add_theme_font_size_override("font_size", 128) # Increased font size
	label.position = Vector2(0, 180) # bottom right of the machine
	label.z_index = 100
	add_child(label)
	# Fade and float up, then free
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0, 2.5)
	tween.tween_property(label, "position:y", label.position.y - 40, 2.5)
	tween.finished.connect(label.queue_free)

func _show_upgrade_shop_label():
	var label = Label.new()
	label.text = "Sprint Points allocated to self are withheld from the machine."
	label.modulate = Color(1, 1, 0.8, 0.92) # Slightly yellow for distinction
	label.add_theme_font_size_override("font_size", 40)
	label.position = Vector2(0, 260) # Below the machine, near upgrade shop
	label.z_index = 100
	add_child(label)
	# Fade in, then fade out after a delay
	label.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.92, 0.7)
	tween.tween_property(label, "modulate:a", 0, 2.5).set_delay(3.5)
	tween.finished.connect(label.queue_free)

func _on_spend_button_pressed():
	_spend_sprint_point()

func _on_progress_value_changed(_value):
	_check_end_condition()

func _check_end_condition():
	if _end_triggered:
		return
	if progress_bar and progress_bar.max_value > 0:
		var percent := (float(progress_bar.value) / float(progress_bar.max_value)) * 100.0
		if percent >= 100.0:
			_end_triggered = true
			if has_node("/root/GlobalUI"):
				get_node("/root/GlobalUI").show_end_screen("Great work! Next sprint, we’re targeting 120%!!")
