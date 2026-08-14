extends Area2D

const UNREPAIRED_COLOR := Color(0.46, 0.3, 0.16, 1.0)
const REPAIRED_COLOR := Color(0.3, 0.64, 0.28, 1.0)

@export var seed_path: NodePath
@export var wind_zone_path: NodePath
@export_range(0.0, 1000.0, 1.0) var energy_reward: float = 20.0
@export_range(0.0, 1.0, 0.05) var repaired_wind_modifier: float = 0.5

@onready var visual: Polygon2D = $Visual

var seed: Node2D
var wind_zone: Area2D
var player: CharacterBody2D
var repaired := false


func _ready() -> void:
	seed = get_node_or_null(seed_path) as Node2D
	wind_zone = get_node_or_null(wind_zone_path) as Area2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_visual()
	set_process(false)


func _process(_delta: float) -> void:
	if not repaired and player != null and Input.is_action_just_pressed("interact"):
		repair()


func repair() -> void:
	if repaired:
		return

	repaired = true
	_update_visual()
	if seed != null and seed.has_method("add_energy"):
		seed.add_energy(energy_reward)
	if wind_zone != null and wind_zone.has_method("set_environment_modifier"):
		wind_zone.set_environment_modifier(repaired_wind_modifier)
	set_process(false)


func _on_body_entered(body: Node2D) -> void:
	if not repaired and body is CharacterBody2D:
		player = body
		set_process(true)


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		set_process(false)


func _update_visual() -> void:
	visual.color = REPAIRED_COLOR if repaired else UNREPAIRED_COLOR
