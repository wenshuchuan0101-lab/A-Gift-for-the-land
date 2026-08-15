extends StaticBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var active := false


func _ready() -> void:
	visible = false
	collision_shape.disabled = true


func activate() -> bool:
	if active:
		return false

	active = true
	visible = true
	collision_shape.set_deferred("disabled", false)
	return true
