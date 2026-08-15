extends Area2D

@export var player_path: NodePath
@export var map_panel_path: NodePath
@export var mobile_controls_path: NodePath

var player: CharacterBody2D
var map_panel: Control
var mobile_controls: CanvasLayer
var player_in_range := false
var map_open := false
var mobile_controls_were_visible := true


func _ready() -> void:
	player = get_node_or_null(player_path) as CharacterBody2D
	map_panel = get_node_or_null(map_panel_path) as Control
	mobile_controls = get_node_or_null(mobile_controls_path) as CanvasLayer
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if map_panel != null:
		map_panel.visible = false
	set_process(false)


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		_set_map_open(not map_open)


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player_in_range = true
		set_process(true)


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_range = false
		_set_map_open(false)
		set_process(false)


func _set_map_open(open: bool) -> void:
	var was_open := map_open
	map_open = open
	if map_panel != null:
		map_panel.visible = open
	if mobile_controls != null:
		if open and not was_open:
			mobile_controls_were_visible = mobile_controls.visible
			mobile_controls.visible = false
		elif not open and was_open:
			mobile_controls.visible = mobile_controls_were_visible
	if player != null:
		player.velocity = Vector2.ZERO
		player.set_physics_process(not open)
