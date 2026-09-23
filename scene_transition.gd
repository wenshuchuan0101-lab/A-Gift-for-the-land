extends Node

@export var player_path: NodePath
@export var first_scene_path: NodePath
@export var next_scene_path: NodePath
@export var trigger_path: NodePath
@export var overlay_path: NodePath
@export_range(0.1, 2.0, 0.05) var fade_duration := 0.35

var transitioning := false

@onready var player: CharacterBody2D = get_node(player_path) as CharacterBody2D
@onready var first_scene: Node2D = get_node(first_scene_path) as Node2D
@onready var next_scene: Node2D = get_node(next_scene_path) as Node2D
@onready var trigger: Area2D = get_node(trigger_path) as Area2D
@onready var overlay: ColorRect = get_node(overlay_path) as ColorRect


func _ready() -> void:
	next_scene.visible = false
	overlay.modulate.a = 0.0
	trigger.body_entered.connect(_on_trigger_body_entered)


func _on_trigger_body_entered(body: Node2D) -> void:
	if transitioning or body != player:
		return
	transitioning = true
	trigger.set_deferred("monitoring", false)
	player.set_control_enabled(false)
	await _fade_to(1.0)

	first_scene.visible = false
	next_scene.visible = true
	var player_start := next_scene.get_node_or_null("SceneMarkers/PlayerStart") as Marker2D
	if player_start != null:
		player.global_position = player_start.global_position
		player.set_checkpoint(player.global_position)
		player.reset_physics_interpolation()

	await get_tree().process_frame
	await _fade_to(0.0)
	player.set_control_enabled(true)


func _fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(overlay, "modulate:a", alpha, fade_duration)
	await tween.finished
