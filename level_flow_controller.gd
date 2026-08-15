extends Node

enum TutorialStage {
	MOVE,
	WIND,
	SHELTER,
	TOOLS,
	REPAIR,
}

const MOVE_MESSAGE := "向左或向右移动，沿着荒地前进。"
const WIND_MESSAGE := "风开始推动你。\n寻找可以躲避的地方。"
const SHELTER_MESSAGE := "巨石挡住了风。"
const TOOLS_MESSAGE := "这里留下了过去的工具。"
const REPAIR_MESSAGE := "土地还能恢复。"

@export var wind_trigger_path: NodePath
@export var shelter_trigger_path: NodePath
@export var tools_trigger_path: NodePath
@export var repair_trigger_path: NodePath
@export var tutorial_text_path: NodePath
@export_range(0.5, 10.0, 0.1) var prompt_duration: float = 3.0

@onready var prompt_timer: Timer = $PromptTimer

var tutorial_text: Label
var current_stage: TutorialStage = TutorialStage.MOVE


func _ready() -> void:
	tutorial_text = get_node_or_null(tutorial_text_path) as Label
	prompt_timer.timeout.connect(_hide_prompt)
	_connect_stage_trigger(wind_trigger_path, TutorialStage.WIND, WIND_MESSAGE)
	_connect_stage_trigger(shelter_trigger_path, TutorialStage.SHELTER, SHELTER_MESSAGE)
	_connect_stage_trigger(tools_trigger_path, TutorialStage.TOOLS, TOOLS_MESSAGE)
	_connect_stage_trigger(repair_trigger_path, TutorialStage.REPAIR, REPAIR_MESSAGE)
	_show_prompt(MOVE_MESSAGE)


func _connect_stage_trigger(
	trigger_path: NodePath,
	stage: TutorialStage,
	message: String
) -> void:
	var trigger := get_node_or_null(trigger_path) as Area2D
	if trigger != null:
		trigger.body_entered.connect(
			_on_stage_trigger_body_entered.bind(stage, message, trigger)
		)


func _on_stage_trigger_body_entered(
	body: Node2D,
	next_stage: TutorialStage,
	message: String,
	trigger: Area2D
) -> void:
	if not body is CharacterBody2D or next_stage != current_stage + 1:
		return

	current_stage = next_stage
	trigger.set_deferred("monitoring", false)
	_show_prompt(message)


func _show_prompt(message: String) -> void:
	if tutorial_text == null:
		return
	tutorial_text.text = message
	tutorial_text.visible = true
	prompt_timer.start(prompt_duration)


func _hide_prompt() -> void:
	if tutorial_text != null:
		tutorial_text.visible = false
