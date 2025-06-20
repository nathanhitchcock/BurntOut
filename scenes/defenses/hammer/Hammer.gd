extends Area2D

@export var swing_duration := 0.2
var swinging := false

func _ready():
	set_process(true)
	$CollisionShape2D.disabled = true

func _process(delta):
	if Input.is_action_just_pressed("swing_hammer") and not swinging:
		swing()

func swing():
	swinging = true
	$CollisionShape2D.disabled = false
	# Play swing animation if AnimatedSprite2D exists
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("swing")
	await get_tree().create_timer(swing_duration).timeout
	$CollisionShape2D.disabled = true
	swinging = false
