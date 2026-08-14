extends Node2D

const ITEM_PROMPTS := {
	"MapItem": "查看地图",
	"CloakItem": "发现旧斗篷",
	"SpearItem": "发现旧长矛",
}

@export var wind_zone_path: NodePath
@export var prompt_label_path: NodePath
@export_range(0.0, 1.0, 0.05) var indoor_wind_multiplier := 0.0

var wind_zone: Area2D
var prompt_label: Label
var house_player: CharacterBody2D
var active_item: Area2D


func _ready() -> void:
	wind_zone = get_node_or_null(wind_zone_path) as Area2D
	prompt_label = get_node_or_null(prompt_label_path) as Label
	$DoorTrigger.body_entered.connect(_on_door_trigger_body_entered)
	$DoorTrigger.body_exited.connect(_on_door_trigger_body_exited)

	for item_name in ITEM_PROMPTS:
		var item := get_node(NodePath(item_name)) as Area2D
		item.body_entered.connect(_on_item_body_entered.bind(item))
		item.body_exited.connect(_on_item_body_exited.bind(item))

	_hide_prompt()
	set_process(false)


func _process(_delta: float) -> void:
	if active_item != null and prompt_label != null and Input.is_action_just_pressed("interact"):
		prompt_label.text = ITEM_PROMPTS[String(active_item.name)]
		prompt_label.visible = true


func _on_door_trigger_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		house_player = body
		_set_wind_multiplier(indoor_wind_multiplier)


func _on_door_trigger_body_exited(body: Node2D) -> void:
	if body == house_player:
		house_player = null
		_set_wind_multiplier(1.0)


func _on_item_body_entered(body: Node2D, item: Area2D) -> void:
	if body is CharacterBody2D:
		active_item = item
		_hide_prompt()
		set_process(true)


func _on_item_body_exited(body: Node2D, item: Area2D) -> void:
	if body is CharacterBody2D and item == active_item:
		active_item = null
		_hide_prompt()
		set_process(false)


func _set_wind_multiplier(multiplier: float) -> void:
	if wind_zone != null and wind_zone.has_method("set_wind_multiplier"):
		wind_zone.set_wind_multiplier(multiplier)


func _hide_prompt() -> void:
	if prompt_label != null:
		prompt_label.visible = false
