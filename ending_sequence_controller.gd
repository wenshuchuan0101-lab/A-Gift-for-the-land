extends Node

enum EndingState {
	WAIT,
	MONSTER_ATTACK,
	SEED_POWER,
	TREE_GUARD,
	END,
}

const FIRST_TEXT := "种子一直没有发芽。\n\n因为它知道。\n\n这里需要的不是新的生命。\n\n而是守护生命的人。"
const SECOND_TEXT := "它把最后的力量交给土地。\n\n让曾经存在的乐园，\n再次留下影子。"

@export var seed_path: NodePath
@export var monster_path: NodePath
@export var monster_spawn_path: NodePath
@export var danger_trigger_path: NodePath
@export var tree_shadow_path: NodePath
@export var wind_zone_path: NodePath
@export var narrative_text_path: NodePath

@onready var attack_delay: Timer = $AttackDelay

var ending_state: EndingState = EndingState.WAIT
var seed: Node2D
var monster: CharacterBody2D
var monster_spawn: Marker2D
var danger_trigger: Area2D
var tree_shadow: StaticBody2D
var wind_zone: Area2D
var narrative_text: Label


func _ready() -> void:
	seed = get_node_or_null(seed_path) as Node2D
	monster = get_node_or_null(monster_path) as CharacterBody2D
	monster_spawn = get_node_or_null(monster_spawn_path) as Marker2D
	danger_trigger = get_node_or_null(danger_trigger_path) as Area2D
	tree_shadow = get_node_or_null(tree_shadow_path) as StaticBody2D
	wind_zone = get_node_or_null(wind_zone_path) as Area2D
	narrative_text = get_node_or_null(narrative_text_path) as Label

	if seed != null and seed.has_signal("seed_placed"):
		seed.connect("seed_placed", _on_seed_placed)
	if monster != null and monster.has_signal("obstacle_hit"):
		monster.connect("obstacle_hit", _on_monster_obstacle_hit)
	if danger_trigger != null:
		danger_trigger.body_entered.connect(_on_danger_trigger_body_entered)
	attack_delay.timeout.connect(_on_attack_delay_timeout)
	if narrative_text != null:
		narrative_text.visible = false


func _on_seed_placed() -> void:
	if ending_state != EndingState.WAIT:
		return

	ending_state = EndingState.MONSTER_ATTACK
	_show_narrative(FIRST_TEXT)
	attack_delay.start()


func _on_attack_delay_timeout() -> void:
	if ending_state != EndingState.MONSTER_ATTACK:
		return
	if monster == null or monster_spawn == null:
		return

	monster.global_position = monster_spawn.global_position
	monster.velocity = Vector2.ZERO
	monster.reset_physics_interpolation()
	if monster.has_method("start_chase"):
		monster.start_chase()


func _on_danger_trigger_body_entered(body: Node2D) -> void:
	if body != monster or ending_state != EndingState.MONSTER_ATTACK:
		return

	ending_state = EndingState.SEED_POWER
	if seed != null and seed.has_method("consume_energy"):
		seed.consume_energy(100.0)
	if tree_shadow != null and tree_shadow.has_method("activate"):
		tree_shadow.activate()
	_show_narrative(SECOND_TEXT)
	ending_state = EndingState.TREE_GUARD
	danger_trigger.set_deferred("monitoring", false)


func _on_monster_obstacle_hit(obstacle: Node) -> void:
	if ending_state != EndingState.TREE_GUARD or obstacle != tree_shadow:
		return

	if monster != null and monster.has_method("stop_chase"):
		monster.stop_chase()
	if wind_zone != null:
		if wind_zone.has_method("set_wind_multiplier"):
			wind_zone.set_wind_multiplier(0.0)
		if wind_zone.has_method("set_environment_modifier"):
			wind_zone.set_environment_modifier(0.0)
	ending_state = EndingState.END


func _show_narrative(text: String) -> void:
	if narrative_text == null:
		return
	narrative_text.text = text
	narrative_text.visible = true
