extends Area2D

signal memory_completed

@export var player_path: NodePath
@export var mobile_controls_path: NodePath
@export_range(3.0, 5.0, 0.5) var memory_duration: float = 4.0

@onready var memory_panel: Control = $MemoryOverlay/MemoryPanel
@onready var memory_timer: Timer = $MemoryTimer

var player: CharacterBody2D
var mobile_controls: CanvasLayer
var player_in_range := false
var memory_active := false
var mobile_controls_were_visible := true


func _ready() -> void:
	player = get_node_or_null(player_path) as CharacterBody2D
	mobile_controls = get_node_or_null(mobile_controls_path) as CanvasLayer
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	memory_timer.timeout.connect(_finish_memory)
	memory_panel.visible = false
	set_process(false)


func _process(_delta: float) -> void:
	if player_in_range and not memory_active and Input.is_action_just_pressed("interact"):
		_start_memory()


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player_in_range = true
		set_process(true)


func _on_body_exited(body: Node2D) -> void:
	if body != player:
		return

	player_in_range = false
	if memory_active:
		_finish_memory()
	else:
		set_process(false)


func _start_memory() -> void:
	if memory_active or player == null:
		return

	memory_active = true
	memory_panel.visible = true
	if mobile_controls != null:
		mobile_controls_were_visible = mobile_controls.visible
		mobile_controls.visible = false
	_set_player_control_enabled(false)
	memory_timer.start(memory_duration)
	set_process(false)


func _finish_memory() -> void:
	if not memory_active:
		return

	memory_active = false
	memory_timer.stop()
	memory_panel.visible = false
	_set_player_control_enabled(true)
	if mobile_controls != null:
		mobile_controls.visible = mobile_controls_were_visible
	set_process(player_in_range)
	memory_completed.emit()


func _set_player_control_enabled(enabled: bool) -> void:
	if player == null:
		return
	if player.has_method("set_control_enabled"):
		player.call("set_control_enabled", enabled)
	else:
		player.velocity = Vector2.ZERO
		player.set_physics_process(enabled)
