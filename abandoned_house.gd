extends Node2D

const ITEM_PROMPTS := {
	"MapItem": "查看地图",
	"LetterItem": "阅读信件",
	"CloakItem": "发现旧斗篷",
	"SpearItem": "发现旧长矛",
}

@export var wind_zone_path: NodePath
@export var prompt_label_path: NodePath
@export var letter_panel_path: NodePath
@export_range(0.0, 1.0, 0.05) var indoor_wind_multiplier := 0.0

var wind_zone: Area2D
var prompt_label: Label
var letter_panel: Control
var house_player: CharacterBody2D
var active_item: Area2D
var active_player: CharacterBody2D
var reading_player: CharacterBody2D
var letter_open := false


func _ready() -> void:
	wind_zone = get_node_or_null(wind_zone_path) as Area2D
	prompt_label = get_node_or_null(prompt_label_path) as Label
	letter_panel = get_node_or_null(letter_panel_path) as Control
	$DoorTrigger.body_entered.connect(_on_door_trigger_body_entered)
	$DoorTrigger.body_exited.connect(_on_door_trigger_body_exited)

	for item_name in ITEM_PROMPTS:
		var item := get_node(NodePath(item_name)) as Area2D
		item.body_entered.connect(_on_item_body_entered.bind(item))
		item.body_exited.connect(_on_item_body_exited.bind(item))

	_hide_prompt()
	if letter_panel != null:
		letter_panel.visible = false
	set_process(false)


func _process(_delta: float) -> void:
	if not Input.is_action_just_pressed("interact"):
		return

	if letter_open:
		_set_letter_open(false)
		return

	if active_item == null:
		return

	var item := active_item
	if item.name == &"LetterItem":
		_set_letter_open(true)
		return

	if prompt_label != null:
		prompt_label.text = ITEM_PROMPTS[String(item.name)]
		prompt_label.visible = true
		if item.has_method("pickup"):
			item.pickup()
			active_item = null
			set_process(false)


func _on_door_trigger_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		house_player = body
		_set_wind_multiplier(indoor_wind_multiplier)


func _on_door_trigger_body_exited(body: Node2D) -> void:
	if body == house_player:
		_set_letter_open(false)
		house_player = null
		_set_wind_multiplier(1.0)
		_hide_prompt()


func _on_item_body_entered(body: Node2D, item: Area2D) -> void:
	if body is CharacterBody2D:
		active_player = body
		if item.has_signal("picked_up") and body.has_method("receive_item"):
			var receiver := Callable(body, "receive_item")
			if not item.is_connected("picked_up", receiver):
				item.connect("picked_up", receiver)
		active_item = item
		_hide_prompt()
		set_process(true)


func _on_item_body_exited(body: Node2D, item: Area2D) -> void:
	if body is CharacterBody2D and item == active_item:
		_set_letter_open(false)
		active_item = null
		active_player = null
		_hide_prompt()
		set_process(false)


func _set_wind_multiplier(multiplier: float) -> void:
	if wind_zone != null and wind_zone.has_method("set_wind_multiplier"):
		wind_zone.set_wind_multiplier(multiplier)


func _set_letter_open(open: bool) -> void:
	letter_open = open and letter_panel != null and active_player != null
	if letter_panel != null:
		letter_panel.visible = letter_open
	_hide_prompt()

	if letter_open:
		reading_player = active_player
		reading_player.velocity = Vector2.ZERO
		reading_player.set_physics_process(false)
	elif reading_player != null:
		reading_player.velocity = Vector2.ZERO
		reading_player.set_physics_process(true)
		reading_player = null


func _hide_prompt() -> void:
	if prompt_label != null:
		prompt_label.visible = false
