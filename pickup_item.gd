extends Area2D

signal picked_up(item_type: StringName)

@export var item_type: StringName

var is_picked_up := false


func pickup() -> void:
	if is_picked_up:
		return

	is_picked_up = true
	picked_up.emit(item_type)
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)
