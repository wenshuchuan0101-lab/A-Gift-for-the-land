extends Control

const NEXT_SCENE_PATH := "res://scenes/chapter1/scene_intro.tscn"
const CHAPTER_SELECTION_PATH := "res://scenes/ui/chapter_selection.tscn"

var is_transitioning := false


func _ready() -> void:
	var selection_button := get_node_or_null("ChapterSelectionButton") as Button
	if selection_button != null:
		selection_button.pressed.connect(_open_chapter_selection)


func _unhandled_input(event: InputEvent) -> void:
	if is_transitioning:
		return

	if event is InputEventMouseButton or event is InputEventScreenTouch:
		return

	if not _is_transition_input(event):
		return

	is_transitioning = true
	get_viewport().set_input_as_handled()
	get_tree().change_scene_to_file(NEXT_SCENE_PATH)


func _open_chapter_selection() -> void:
	if is_transitioning:
		return
	is_transitioning = true
	get_tree().change_scene_to_file(CHAPTER_SELECTION_PATH)


func _is_transition_input(event: InputEvent) -> bool:
	if event is InputEventKey:
		return event.pressed and not event.echo
	if event is InputEventMouseButton:
		return event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventScreenTouch:
		return event.pressed
	return false

