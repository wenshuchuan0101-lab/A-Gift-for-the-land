extends Node2D

signal seed_placed

enum SeedState {
	FOLLOW,
	PLACED,
}

const MIN_ENERGY_SCALE := 0.7
const PLACED_SCALE_MULTIPLIER := 1.25
const PLACEMENT_SNAP_DISTANCE := 1.0
const FOLLOW_COLOR := Color(0.96, 0.82, 0.24, 1.0)
const PLACED_COLOR := Color(0.5, 0.92, 0.62, 1.0)

@export var player_path: NodePath
@export var target_path: NodePath
@export var follow_offset: Vector2 = Vector2(60, -50)
@export var follow_speed: float = 5.0
@export var guide_distance: float = 70.0
@export_range(0.1, 20.0, 0.1) var placement_speed: float = 6.0
@export_range(0.0, 10000.0, 1.0) var max_energy: float = 100.0
@export_range(0.0, 10000.0, 1.0) var energy: float = 100.0

@onready var visual: Polygon2D = $Visual

var player: Node2D
var target: Node2D
var state: SeedState = SeedState.FOLLOW
var placement_target := Vector2.ZERO
var placement_in_progress := false


func _ready() -> void:
	player = get_node_or_null(player_path) as Node2D
	target = get_node_or_null(target_path) as Node2D
	energy = clampf(energy, 0.0, maxf(max_energy, 0.0))
	_update_energy_visual()
	if player != null:
		global_position = _get_desired_position()


func _process(delta: float) -> void:
	if state == SeedState.PLACED:
		_move_to_placement(delta)
		return

	if player == null:
		return
	var target_position := _get_desired_position()
	var weight := clampf(follow_speed * delta, 0.0, 1.0)
	global_position = global_position.lerp(target_position, weight)


func place_at(target_position: Vector2) -> bool:
	if state != SeedState.FOLLOW:
		return false

	state = SeedState.PLACED
	placement_target = target_position
	placement_in_progress = true
	set_process(true)
	return true


func _move_to_placement(delta: float) -> void:
	if not placement_in_progress:
		return

	var weight := clampf(placement_speed * delta, 0.0, 1.0)
	global_position = global_position.lerp(placement_target, weight)
	if global_position.distance_to(placement_target) > PLACEMENT_SNAP_DISTANCE:
		return

	global_position = placement_target
	placement_in_progress = false
	_update_energy_visual()
	seed_placed.emit()
	set_process(false)


func _get_desired_position() -> Vector2:
	var desired_position := player.global_position + follow_offset
	if target != null:
		var direction := player.global_position.direction_to(target.global_position)
		desired_position += direction * guide_distance
	return desired_position


func add_energy(value: float) -> void:
	energy = clampf(energy + value, 0.0, maxf(max_energy, 0.0))
	_update_energy_visual()


func consume_energy(value: float) -> void:
	energy = clampf(energy - value, 0.0, maxf(max_energy, 0.0))
	_update_energy_visual()


func get_energy_ratio() -> float:
	if max_energy <= 0.0:
		return 0.0
	return clampf(energy / max_energy, 0.0, 1.0)


func _update_energy_visual() -> void:
	if visual == null:
		return
	var energy_scale := lerpf(MIN_ENERGY_SCALE, 1.0, get_energy_ratio())
	if state == SeedState.PLACED and not placement_in_progress:
		energy_scale *= PLACED_SCALE_MULTIPLIER
		visual.color = PLACED_COLOR
	else:
		visual.color = FOLLOW_COLOR
	visual.scale = Vector2.ONE * energy_scale
