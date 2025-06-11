extends Sprite2D

@onready var screen_flicker = $ScreenFlicker
@onready var candle = $Candle

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
