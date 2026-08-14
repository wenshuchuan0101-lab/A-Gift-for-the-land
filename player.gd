extends CharacterBody2D

const DEFEND_MOVE_MULTIPLIER := 0.5
const DEFEND_WIND_MULTIPLIER := 0.3

@export var move_speed: float = 220.0
@export var jump_velocity: float = -420.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var external_force := Vector2.ZERO
var has_cloak := false
var has_spear := false
var is_defending := false


func _physics_process(delta: float) -> void:
	is_defending = has_cloak and Input.is_action_pressed("defend")
	var direction := Input.get_axis("move_left", "move_right")
	var current_move_speed := move_speed
	if is_defending:
		current_move_speed *= DEFEND_MOVE_MULTIPLIER
	velocity.x = direction * current_move_speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if not is_on_floor():
		velocity.y += gravity * delta

	velocity += external_force
	move_and_slide()
	external_force = Vector2.ZERO


func add_external_force(force: Vector2) -> void:
	external_force += force


func get_wind_resistance() -> float:
	if is_defending:
		return DEFEND_WIND_MULTIPLIER
	return 1.0


func receive_item(item_type: StringName) -> void:
	match item_type:
		&"cloak":
			has_cloak = true
		&"spear":
			has_spear = true
