extends CharacterBody2D

const DEFEND_MOVE_MULTIPLIER := 0.5
const DEFEND_WIND_MULTIPLIER := 0.3

@export var move_speed: float = 220.0
@export var jump_velocity: float = -420.0

@onready var anchor_visual: Polygon2D = $AnchorVisual

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var external_force := Vector2.ZERO
var has_cloak := false
var has_spear := false
var is_defending := false
var is_anchored := false


func _physics_process(delta: float) -> void:
	if not has_spear and is_anchored:
		_set_anchored(false)
	if has_spear and Input.is_action_just_pressed("anchor"):
		_set_anchored(not is_anchored)

	is_defending = has_cloak and not is_anchored and Input.is_action_pressed("defend")
	var direction := Input.get_axis("move_left", "move_right")
	var current_move_speed := move_speed
	if is_anchored:
		current_move_speed = 0.0
	elif is_defending:
		current_move_speed *= DEFEND_MOVE_MULTIPLIER
	velocity.x = direction * current_move_speed

	if not is_anchored and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if not is_on_floor():
		velocity.y += gravity * delta

	velocity += external_force
	move_and_slide()
	external_force = Vector2.ZERO


func add_external_force(force: Vector2) -> void:
	if is_anchored:
		return
	external_force += force


func get_wind_resistance() -> float:
	if is_anchored:
		return 0.0
	if is_defending:
		return DEFEND_WIND_MULTIPLIER
	return 1.0


func _set_anchored(anchored: bool) -> void:
	is_anchored = anchored
	anchor_visual.visible = anchored
	if anchored:
		velocity = Vector2.ZERO
		external_force = Vector2.ZERO


func receive_item(item_type: StringName) -> void:
	match item_type:
		&"cloak":
			has_cloak = true
		&"spear":
			has_spear = true
