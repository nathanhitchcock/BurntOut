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

func _ready():
	if candle:
		candle_base_pos = candle.position
		candle_base_scale = candle.scale
	# Set ProgressBar max value (e.g., 10 sprint points for full bar)
	if progress_bar:
		progress_bar.max_value = 10

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
