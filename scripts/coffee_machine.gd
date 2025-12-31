extends VBoxContainer

signal productivity_full

@export_range(0, 100, 1) var fill_percent: int = 0 : set = set_fill_percent
var _end_triggered: bool = false

func set_fill_percent(value: int) -> void:
	fill_percent = clamp(value, 0, 100)
	if fill_percent >= 100 and not _end_triggered:
		_end_triggered = true
		emit_signal("productivity_full")
		# Show simple end screen via GlobalUI (autoload)
		if has_node("/root/GlobalUI"):
			get_node("/root/GlobalUI").show_end_screen("Great work! Next sprint, we’re targeting 120%!!")

func reset_productivity() -> void:
	fill_percent = 0
	_end_triggered = false
