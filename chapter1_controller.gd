extends Node

signal chapter_completed

enum ChapterState {
	START,
	WIND,
	HOUSE,
	REPAIR,
	MEMORY,
	CHASE,
	TREE,
	ENDING,
}

const CLOAK_GATE_MESSAGE := "前方的风太强了。\n先找到能够抵挡风的东西。"

@export var player_path: NodePath
@export var seed_path: NodePath
@export var wind_trigger_path: NodePath
@export var house_trigger_path: NodePath
@export var repair_trigger_path: NodePath
@export var totem_memory_path: NodePath
@export var grass_manager_path: NodePath
@export var chase_controller_path: NodePath
@export var ending_controller_path: NodePath
@export var cloak_gate_collision_path: NodePath
@export var cloak_gate_visual_path: NodePath
@export var cloak_gate_hint_path: NodePath
@export var tutorial_text_path: NodePath

@onready var progress_tracker: Node = $ProgressTracker
@onready var gate_prompt_timer: Timer = $GatePromptTimer

var current_state: ChapterState = ChapterState.START
var player: CharacterBody2D
var seed: Node2D
var cloak_gate_collision: CollisionShape2D
var cloak_gate_visual: CanvasItem
var cloak_gate_hint: Area2D
var tutorial_text: Label
var gate_prompt_shown := false


func _ready() -> void:
	player = get_node_or_null(player_path) as CharacterBody2D
	seed = get_node_or_null(seed_path) as Node2D
	cloak_gate_collision = get_node_or_null(cloak_gate_collision_path) as CollisionShape2D
	cloak_gate_visual = get_node_or_null(cloak_gate_visual_path) as CanvasItem
	cloak_gate_hint = get_node_or_null(cloak_gate_hint_path) as Area2D
	tutorial_text = get_node_or_null(tutorial_text_path) as Label

	_connect_body_trigger(wind_trigger_path, _on_wind_trigger_entered)
	_connect_body_trigger(house_trigger_path, _on_house_trigger_entered)
	_connect_body_trigger(repair_trigger_path, _on_repair_trigger_entered)

	if player != null and player.has_signal("item_received"):
		player.connect("item_received", _on_player_item_received)
		_sync_equipment_progress()
	if seed != null:
		progress_tracker.call("mark_found_seed")
		if seed.has_signal("seed_placed"):
			seed.connect("seed_placed", _on_seed_placed)

	var grass_manager := get_node_or_null(grass_manager_path)
	if grass_manager != null and grass_manager.has_signal("repair_count_changed"):
		grass_manager.connect("repair_count_changed", _on_repair_count_changed)

	var totem_memory := get_node_or_null(totem_memory_path)
	if totem_memory != null and totem_memory.has_signal("memory_completed"):
		totem_memory.connect("memory_completed", _on_memory_completed)

	var chase_controller := get_node_or_null(chase_controller_path)
	if chase_controller != null:
		if chase_controller.has_signal("chase_started"):
			chase_controller.connect("chase_started", _on_chase_started)
		if chase_controller.has_signal("chase_completed"):
			chase_controller.connect("chase_completed", _on_chase_completed)

	var ending_controller := get_node_or_null(ending_controller_path)
	if ending_controller != null and ending_controller.has_signal("ending_completed"):
		ending_controller.connect("ending_completed", _on_ending_completed)

	if cloak_gate_hint != null:
		cloak_gate_hint.body_entered.connect(_on_cloak_gate_hint_body_entered)
	gate_prompt_timer.timeout.connect(_hide_gate_prompt)
	_set_cloak_gate_open(bool(progress_tracker.get("got_cloak")))


func _connect_body_trigger(trigger_path: NodePath, callback: Callable) -> void:
	var trigger := get_node_or_null(trigger_path) as Area2D
	if trigger != null:
		trigger.body_entered.connect(callback)


func _sync_equipment_progress() -> void:
	if bool(player.get("has_cloak")):
		progress_tracker.call("mark_got_cloak")
	if bool(player.get("has_spear")):
		progress_tracker.call("mark_got_spear")


func _on_wind_trigger_entered(body: Node2D) -> void:
	if body == player:
		_advance_to(ChapterState.WIND)


func _on_house_trigger_entered(body: Node2D) -> void:
	if body == player:
		_advance_to(ChapterState.HOUSE)


func _on_repair_trigger_entered(body: Node2D) -> void:
	if body == player:
		_advance_to(ChapterState.REPAIR)


func _on_player_item_received(item_type: StringName) -> void:
	match item_type:
		&"cloak":
			progress_tracker.call("mark_got_cloak")
			_set_cloak_gate_open(true)
		&"spear":
			progress_tracker.call("mark_got_spear")


func _on_repair_count_changed(repaired_count: int, _total_count: int) -> void:
	if repaired_count > 0:
		progress_tracker.call("mark_repaired_grass")
		_advance_to(ChapterState.REPAIR)


func _on_memory_completed() -> void:
	progress_tracker.call("mark_saw_memory")
	_advance_to(ChapterState.MEMORY)


func _on_chase_started() -> void:
	_advance_to(ChapterState.CHASE)


func _on_chase_completed() -> void:
	progress_tracker.call("mark_completed_chase")
	_advance_to(ChapterState.TREE)


func _on_seed_placed() -> void:
	progress_tracker.call("mark_planted_seed")
	_advance_to(ChapterState.ENDING)


func _on_ending_completed() -> void:
	chapter_completed.emit()


func _advance_to(next_state: ChapterState) -> void:
	if next_state > current_state:
		current_state = next_state


func _set_cloak_gate_open(open: bool) -> void:
	if cloak_gate_collision != null:
		cloak_gate_collision.set_deferred("disabled", open)
	if cloak_gate_visual != null:
		cloak_gate_visual.visible = not open
	if cloak_gate_hint != null and open:
		cloak_gate_hint.set_deferred("monitoring", false)
		_hide_gate_prompt()


func _on_cloak_gate_hint_body_entered(body: Node2D) -> void:
	if body != player or bool(progress_tracker.get("got_cloak")) or gate_prompt_shown:
		return
	gate_prompt_shown = true
	if tutorial_text != null:
		tutorial_text.text = CLOAK_GATE_MESSAGE
		tutorial_text.visible = true
		gate_prompt_timer.start()


func _hide_gate_prompt() -> void:
	gate_prompt_timer.stop()
	if tutorial_text != null and tutorial_text.text == CLOAK_GATE_MESSAGE:
		tutorial_text.visible = false
