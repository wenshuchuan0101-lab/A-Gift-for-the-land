extends Node

const CHAPTER_SELECTION_PATH := "res://scenes/ui/chapter_selection.tscn"
@export var map_title := "Scene"
@export var player_start := Vector2(180, 500)

func _ready() -> void:
	var player := get_node_or_null("Player") as CharacterBody2D
	if player != null:
		player.global_position = player_start
		var camera := player.get_node_or_null("Camera2D") as Camera2D
		if camera != null:
			camera.enabled = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_file(CHAPTER_SELECTION_PATH)
