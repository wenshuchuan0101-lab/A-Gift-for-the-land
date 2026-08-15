extends Node2D

@export var player_path: NodePath
@export var seed_path: NodePath
@export var chase_controller_path: NodePath
@export var wind_zone_path: NodePath

@onready var safe_zone: Area2D = $SafeZone
@onready var seed_place_point: Area2D = $SeedPlacePoint

var player: CharacterBody2D
var seed: Node2D
var chase_controller: Node
var wind_zone: Area2D
var player_in_safe_zone := false
var can_place_seed := false


func _ready() -> void:
	player = get_node_or_null(player_path) as CharacterBody2D
	seed = get_node_or_null(seed_path) as Node2D
	chase_controller = get_node_or_null(chase_controller_path)
	wind_zone = get_node_or_null(wind_zone_path) as Area2D
	safe_zone.body_entered.connect(_on_safe_zone_body_entered)
	safe_zone.body_exited.connect(_on_safe_zone_body_exited)
	seed_place_point.body_entered.connect(_on_seed_place_point_body_entered)
	seed_place_point.body_exited.connect(_on_seed_place_point_body_exited)
	set_process(false)


func _process(_delta: float) -> void:
	if not can_place_seed or not Input.is_action_just_pressed("interact"):
		return
	if seed == null or not seed.has_method("place_at"):
		return

	var placement_started := bool(seed.call("place_at", seed_place_point.global_position))
	if not placement_started:
		return

	can_place_seed = false
	set_process(false)
	seed_place_point.set_deferred("monitoring", false)


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


func _on_seed_place_point_body_entered(body: Node2D) -> void:
	if body != player:
		return

	can_place_seed = true
	set_process(true)


func _on_seed_place_point_body_exited(body: Node2D) -> void:
	if body != player:
		return

	can_place_seed = false
	set_process(false)
