extends CharacterBody2D

@export var move_speed: float = 220.0
@export var jump_velocity: float = -420.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var external_force := Vector2.ZERO
var has_cloak := false
var has_spear := false


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * move_speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if not is_on_floor():
		velocity.y += gravity * delta

	velocity += external_force
	move_and_slide()
	external_force = Vector2.ZERO


func add_external_force(force: Vector2) -> void:
	external_force += force


func receive_item(item_type: StringName) -> void:
	match item_type:
		&"cloak":
			has_cloak = true
		&"spear":
			has_spear = true
