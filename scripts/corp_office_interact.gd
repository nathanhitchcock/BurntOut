extends Node2D

var player_in_range := false
var interact_prompt_shown := false

func _ready():
    var btn = get_node_or_null("Button")
    if btn:
        btn.pressed.connect(_on_scrum_dsu_board_pressed)
    var area = get_node_or_null("ScrumDSUBoardArea")
    if area:
        area.body_entered.connect(_on_area_body_entered)
        area.body_exited.connect(_on_area_body_exited)

func save_player_state_before_scene_change():
    var player = get_node_or_null("Player")
    if player and player.has_method("save_to_player_data"):
        player.save_to_player_data()

func _on_scrum_dsu_board_pressed():
    save_player_state_before_scene_change()
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_area_body_entered(body):
    if body.name == "Player":
        player_in_range = true

func _on_area_body_exited(body):
    if body.name == "Player":
        player_in_range = false

func _process(_delta):
    if player_in_range:
        if not interact_prompt_shown and has_node("/root/GlobalUI"):
            get_node("/root/GlobalUI").show_interact_prompt(true)
            interact_prompt_shown = true
    else:
        if interact_prompt_shown and has_node("/root/GlobalUI"):
            get_node("/root/GlobalUI").show_interact_prompt(false)
            interact_prompt_shown = false
    if player_in_range and Input.is_action_just_pressed("ui_accept"):
        save_player_state_before_scene_change()
        get_tree().change_scene_to_file("res://scenes/main.tscn")
