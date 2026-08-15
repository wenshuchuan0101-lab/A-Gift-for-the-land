extends Area2D

const INACTIVE_COLOR := Color(0.62, 0.56, 0.42, 1.0)
const ACTIVE_COLOR := Color(0.42, 0.76, 0.48, 1.0)

@onready var visual: Polygon2D = $Visual

var activated := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_visual()


func _on_body_entered(body: Node2D) -> void:
	if activated:
		return
	if body is CharacterBody2D and body.has_method("set_checkpoint"):
		body.set_checkpoint(global_position)
		activated = true
		_update_visual()


func _update_visual() -> void:
	visual.color = ACTIVE_COLOR if activated else INACTIVE_COLOR
