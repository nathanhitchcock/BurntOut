extends Sprite2D

@onready var screen_flicker = $ScreenFlicker
@onready var candle = $Candle
@onready var progress_bar = $ProgressBar if has_node("ProgressBar") else null

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

func _ready():
	if candle:
		candle_base_pos = candle.position
		candle_base_scale = candle.scale
	# Set ProgressBar max value (e.g., 10 sprint points for full bar)
	if progress_bar:
		progress_bar.max_value = 10
	if area2d:
		area2d.body_entered.connect(_on_area2d_body_entered)

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

	# Update ProgressBar from player_data.sprint_points
	if progress_bar and has_node("/root/player_data"):
		var pd = get_node("/root/player_data")
		progress_bar.value = clamp(pd.sprint_points, progress_bar.min_value, progress_bar.max_value)

func _on_area2d_body_entered(body):
	if body.name == "Player":
		_show_random_quote()

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
