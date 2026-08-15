extends Node2D

@export var player_path: NodePath
@export var chase_controller_path: NodePath
@export var wind_zone_path: NodePath

@onready var safe_zone: Area2D = $SafeZone

var player: CharacterBody2D
var chase_controller: Node
var wind_zone: Area2D
var player_in_safe_zone := false


func _ready() -> void:
	player = get_node_or_null(player_path) as CharacterBody2D
	chase_controller = get_node_or_null(chase_controller_path)
	wind_zone = get_node_or_null(wind_zone_path) as Area2D
	safe_zone.body_entered.connect(_on_safe_zone_body_entered)
	safe_zone.body_exited.connect(_on_safe_zone_body_exited)


func _on_safe_zone_body_entered(body: Node2D) -> void:
	if body != player:
		return

	player_in_safe_zone = true
	if chase_controller != null and chase_controller.has_method("stop_chase"):
		chase_controller.stop_chase()
	if wind_zone != null and wind_zone.has_method("set_wind_multiplier"):
		wind_zone.set_wind_multiplier(0.0)


func _on_safe_zone_body_exited(body: Node2D) -> void:
	if body != player:
		return

	player_in_safe_zone = false
	if wind_zone != null and wind_zone.has_method("set_wind_multiplier"):
		wind_zone.set_wind_multiplier(1.0)
