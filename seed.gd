extends Node2D

@export var player_path: NodePath
@export var follow_offset: Vector2 = Vector2(60, -50)
@export var follow_speed: float = 5.0

var player: Node2D


func _ready() -> void:
	player = get_node_or_null(player_path) as Node2D
	if player != null:
		global_position = player.global_position + follow_offset


func _process(delta: float) -> void:
	if player == null:
		return

	var target_position := player.global_position + follow_offset
	var weight := clampf(follow_speed * delta, 0.0, 1.0)
	global_position = global_position.lerp(target_position, weight)
