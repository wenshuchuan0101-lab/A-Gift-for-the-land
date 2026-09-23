extends Control

const INTRO_DURATION := 10.0
const FADE_IN_DURATION := 2.0
const HOLD_DURATION := 6.0
const FADE_OUT_DURATION := 2.0

@export_file("*.tscn") var next_scene_path := "res://Demo_Level.tscn"

@onready var text_container: Control = $TextContainer

var is_transitioning := false


func _ready() -> void:
	text_container.modulate.a = 0.0
	_play_intro()


func _play_intro() -> void:
	await _fade_text(1.0, FADE_IN_DURATION)
	await get_tree().create_timer(HOLD_DURATION).timeout
	await _fade_text(0.0, FADE_OUT_DURATION)
	if is_transitioning:
		return
	is_transitioning = true
	get_tree().change_scene_to_file(next_scene_path)


func _fade_text(alpha: float, duration: float) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(text_container, "modulate:a", alpha, duration)
	await tween.finished
