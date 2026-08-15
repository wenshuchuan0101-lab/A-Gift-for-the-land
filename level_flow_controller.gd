extends Node

enum Stage {
	START,
	WIND,
	HOUSE,
	GRASS,
}

const START_MESSAGE := "沿着荒地向前走。"
const WIND_MESSAGE := "风越来越强了。"
const HOUSE_MESSAGE := "这里似乎有人生活过。"
const GRASS_MESSAGE := "土地正在恢复。"

@export var wind_trigger_path: NodePath
@export var house_trigger_path: NodePath
@export var grass_trigger_path: NodePath
@export var prompt_label_path: NodePath
@export_range(0.5, 10.0, 0.1) var prompt_duration: float = 2.5

@onready var prompt_timer: Timer = $PromptTimer

var prompt_label: Label
var current_stage: Stage = Stage.START


func _ready() -> void:
	prompt_label = get_node_or_null(prompt_label_path) as Label
	prompt_timer.timeout.connect(_hide_prompt)
	_connect_stage_trigger(wind_trigger_path, Stage.WIND, WIND_MESSAGE)
	_connect_stage_trigger(house_trigger_path, Stage.HOUSE, HOUSE_MESSAGE)
	_connect_stage_trigger(grass_trigger_path, Stage.GRASS, GRASS_MESSAGE)
	_show_prompt(START_MESSAGE)


func _connect_stage_trigger(trigger_path: NodePath, stage: Stage, message: String) -> void:
	var trigger := get_node_or_null(trigger_path) as Area2D
	if trigger != null:
		trigger.body_entered.connect(
			_on_stage_trigger_body_entered.bind(stage, message, trigger)
		)


func _on_stage_trigger_body_entered(
	body: Node2D,
	next_stage: Stage,
	message: String,
	trigger: Area2D
) -> void:
	if not body is CharacterBody2D or next_stage != current_stage + 1:
		return

	current_stage = next_stage
	trigger.set_deferred("monitoring", false)
	_show_prompt(message)


func _show_prompt(message: String) -> void:
	if prompt_label == null:
		return
	prompt_label.text = message
	prompt_label.visible = true
	prompt_timer.start(prompt_duration)


func _hide_prompt() -> void:
	if prompt_label != null:
		prompt_label.visible = false
