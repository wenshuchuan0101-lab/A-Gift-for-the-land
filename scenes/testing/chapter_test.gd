extends Node

const CHAPTER_SELECTION_PATH := "res://scenes/ui/chapter_selection.tscn"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(CHAPTER_SELECTION_PATH)
