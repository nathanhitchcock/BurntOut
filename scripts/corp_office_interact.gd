extends Node2D

var player_in_range := false

func _ready():
    var btn = get_node_or_null("Button")
    if btn:
        btn.pressed.connect(_on_scrum_dsu_board_pressed)
    var area = get_node_or_null("ScrumDSUBoardArea")
    if area:
        area.body_entered.connect(_on_area_body_entered)
        area.body_exited.connect(_on_area_body_exited)

func _on_scrum_dsu_board_pressed():
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_area_body_entered(body):
    if body.name == "Player":
        player_in_range = true

func _on_area_body_exited(body):
    if body.name == "Player":
        player_in_range = false

func _process(_delta):
    if player_in_range and Input.is_action_just_pressed("ui_accept"):
        get_tree().change_scene_to_file("res://scenes/main.tscn")
