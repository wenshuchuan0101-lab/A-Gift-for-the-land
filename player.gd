extends CharacterBody2D

@export var move_speed: float = 220.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * move_speed

	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()
