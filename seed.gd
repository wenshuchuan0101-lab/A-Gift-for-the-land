extends Node2D

@export var player_path: NodePath
@export var target_path: NodePath
@export var follow_offset: Vector2 = Vector2(60, -50)
@export var follow_speed: float = 5.0
@export var guide_distance: float = 70.0

var player: Node2D
var target: Node2D


func _ready() -> void:
	player = get_node_or_null(player_path) as Node2D
	target = get_node_or_null(target_path) as Node2D
	if player != null:
		global_position = _get_desired_position()


func _process(delta: float) -> void:
	if player == null:
		return

	var target_position := _get_desired_position()
	var weight := clampf(follow_speed * delta, 0.0, 1.0)
	global_position = global_position.lerp(target_position, weight)


func _get_desired_position() -> Vector2:
	var desired_position := player.global_position + follow_offset
	if target != null:
		var direction := player.global_position.direction_to(target.global_position)
		desired_position += direction * guide_distance
	return desired_position
