extends Node

const CHAPTER_SELECTION_PATH := "res://scenes/ui/chapter_selection.tscn"

func _ready() -> void:
	var player := get_node_or_null("Player") as CharacterBody2D
	if player != null:
		var camera := player.get_node_or_null("Camera2D") as Camera2D
		if camera != null:
			camera.offset = Vector2(115.2, -200.0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(CHAPTER_SELECTION_PATH)
