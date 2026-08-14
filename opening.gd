extends Control

const NEXT_SCENE_PATH := "res://Demo_Level.tscn"

var is_transitioning := false


func _unhandled_input(event: InputEvent) -> void:
	if is_transitioning:
		return

	if not _is_transition_input(event):
		return

	is_transitioning = true
	get_viewport().set_input_as_handled()
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)


func _is_transition_input(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.pressed and not event.echo
	if event is InputEventMouseButton:
		return event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventScreenTouch:
		return event.pressed
	return false
