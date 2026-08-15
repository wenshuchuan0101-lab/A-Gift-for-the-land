extends Node

signal chase_started
signal chase_completed

enum ChaseState {
	IDLE,
	CHASE,
	COMPLETE,
}

@export var player_path: NodePath
@export var monster_path: NodePath
@export var start_trigger_path: NodePath
@export var end_trigger_path: NodePath
@export var grass_slow_zone_path: NodePath
@export_range(1.0, 1000.0, 1.0) var normal_monster_speed := 180.0
@export_range(1.0, 1000.0, 1.0) var grass_monster_speed := 120.0

var chase_state: ChaseState = ChaseState.IDLE
var player: CharacterBody2D
var monster: CharacterBody2D
var start_trigger: Area2D
var end_trigger: Area2D
var grass_slow_zone: Area2D
var player_in_grass := false


func _ready() -> void:
	player = get_node_or_null(player_path) as CharacterBody2D
	monster = get_node_or_null(monster_path) as CharacterBody2D
	start_trigger = get_node_or_null(start_trigger_path) as Area2D
	end_trigger = get_node_or_null(end_trigger_path) as Area2D
	grass_slow_zone = get_node_or_null(grass_slow_zone_path) as Area2D

	if start_trigger != null:
		start_trigger.body_entered.connect(_on_start_trigger_body_entered)
	if end_trigger != null:
		end_trigger.body_entered.connect(_on_end_trigger_body_entered)
	if grass_slow_zone != null:
		grass_slow_zone.body_entered.connect(_on_grass_slow_zone_body_entered)
		grass_slow_zone.body_exited.connect(_on_grass_slow_zone_body_exited)
	if monster != null and monster.has_signal("player_caught"):
		monster.connect("player_caught", _on_monster_player_caught)

	_set_monster_speed(normal_monster_speed)


func _on_start_trigger_body_entered(body: Node2D) -> void:
	if body != player or chase_state != ChaseState.IDLE:
		return

	chase_state = ChaseState.CHASE
	_set_monster_speed(grass_monster_speed if player_in_grass else normal_monster_speed)
	if monster != null and monster.has_method("start_chase"):
		monster.start_chase()
	chase_started.emit()


func _on_end_trigger_body_entered(body: Node2D) -> void:
	if body != player:
		return

	stop_chase()


func stop_chase() -> void:
	if chase_state != ChaseState.CHASE:
		return

	chase_state = ChaseState.COMPLETE
	player_in_grass = false
	_set_monster_speed(normal_monster_speed)
	if monster != null and monster.has_method("stop_chase"):
		monster.stop_chase()
	chase_completed.emit()


func _on_grass_slow_zone_body_entered(body: Node2D) -> void:
	if body != player:
		return

	player_in_grass = true
	if chase_state == ChaseState.CHASE:
		_set_monster_speed(grass_monster_speed)


func _on_grass_slow_zone_body_exited(body: Node2D) -> void:
	if body != player:
		return

	player_in_grass = false
	if chase_state == ChaseState.CHASE:
		_set_monster_speed(normal_monster_speed)


func _on_monster_player_caught() -> void:
	if chase_state != ChaseState.CHASE:
		return

	chase_state = ChaseState.IDLE
	player_in_grass = false
	_set_monster_speed(normal_monster_speed)


func _set_monster_speed(speed: float) -> void:
	if monster != null and monster.has_method("set_chase_speed"):
		monster.set_chase_speed(speed)
