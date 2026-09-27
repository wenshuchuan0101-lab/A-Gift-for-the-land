extends CharacterBody3D

@export var run_speed: float = 4.2
@export var catch_distance: float = 2.4
@export var route_end_z: float = -458.0
var target: Node3D
var running := false
var home_transform: Transform3D
signal player_caught_target

func _ready() -> void:
	home_transform = global_transform
	target = get_parent().get_node_or_null("Player")

func _physics_process(_delta: float) -> void:
	if not running:
		velocity = Vector3.ZERO
		return
	velocity = Vector3(0.0, 0.0, -run_speed)
	move_and_slide()
	if is_instance_valid(target) and global_position.distance_to(target.global_position) <= catch_distance:
		running = false
		velocity = Vector3.ZERO
		player_caught_target.emit()
		visible = false
	elif global_position.z <= route_end_z:
		running = false
		velocity = Vector3.ZERO
		visible = false

func start_chase() -> void:
	running = true
	visible = true

func stop_chase() -> void:
	running = false
	velocity = Vector3.ZERO

func reset_to_home() -> void:
	global_transform = home_transform
	visible = true
	running = false
	velocity = Vector3.ZERO
	reset_physics_interpolation()
