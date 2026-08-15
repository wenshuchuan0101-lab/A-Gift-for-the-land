extends CharacterBody2D

signal player_caught
signal obstacle_hit(obstacle: Node)

@export var player_path: NodePath
@export_range(1.0, 1000.0, 1.0) var chase_speed: float = 180.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var player: CharacterBody2D
var active := false
var spawn_position := Vector2.ZERO
var current_chase_speed := 180.0
var last_obstacle: Node


func _ready() -> void:
	player = get_node_or_null(player_path) as CharacterBody2D
	spawn_position = global_position
	current_chase_speed = chase_speed
	visible = false
	collision_shape.disabled = true
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if not active or not is_instance_valid(player):
		stop_chase()
		return

	var horizontal_direction := signf(player.global_position.x - global_position.x)
	velocity = Vector2(horizontal_direction * current_chase_speed, 0.0)
	move_and_slide()

	for collision_index in range(get_slide_collision_count()):
		var collision := get_slide_collision(collision_index)
		var collider := collision.get_collider()
		if collider == player:
			_catch_player()
			return
		if collider is StaticBody2D and collider != last_obstacle:
			last_obstacle = collider
			obstacle_hit.emit(collider)


func start_chase() -> void:
	if active or not is_instance_valid(player):
		return
	last_obstacle = null
	active = true
	visible = true
	collision_shape.set_deferred("disabled", false)
	set_physics_process(true)


func stop_chase() -> void:
	active = false
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	set_physics_process(false)


func set_chase_speed(speed: float) -> void:
	current_chase_speed = maxf(speed, 0.0)


func _catch_player() -> void:
	stop_chase()
	global_position = spawn_position
	visible = false
	reset_physics_interpolation()
	if player != null and player.has_method("respawn"):
		player.respawn()
	player_caught.emit()
