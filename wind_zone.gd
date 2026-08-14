extends Area2D

const NORMAL_ZONE_COLOR := Color(0.28, 0.55, 0.68, 0.18)
const REDUCED_ZONE_COLOR := Color(0.24, 0.5, 0.34, 0.14)
const NORMAL_DIRECTION_TEXT := "<<<<    <<<<"
const REDUCED_DIRECTION_TEXT := "<<      <<"

@export var wind_direction: Vector2 = Vector2.LEFT
@export var wind_force: float = 120.0

@onready var visual: Polygon2D = $Visual
@onready var direction_label: Label = $DirectionLabel

var player: CharacterBody2D
var player_in_zone := false
var wind_velocity := Vector2.ZERO
var wind_multiplier := 1.0
var environment_multiplier := 1.0


func _ready() -> void:
	wind_velocity = wind_direction.normalized() * wind_force
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_environment_visual()


func _physics_process(_delta: float) -> void:
	if player_in_zone and player != null and player.is_physics_processing():
		var player_wind_multiplier := 1.0
		if player.has_method("get_wind_resistance"):
			player_wind_multiplier = clampf(float(player.call("get_wind_resistance")), 0.0, 1.0)
		player.add_external_force(
			wind_velocity * wind_multiplier * environment_multiplier * player_wind_multiplier
		)


func set_wind_multiplier(multiplier: float) -> void:
	wind_multiplier = clampf(multiplier, 0.0, 1.0)


func set_environment_modifier(modifier: float) -> void:
	environment_multiplier = clampf(modifier, 0.0, 1.0)
	_update_environment_visual()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("add_external_force"):
		player = body
		player_in_zone = true


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_zone = false
		player = null


func _update_environment_visual() -> void:
	var wind_reduced := environment_multiplier < 1.0
	visual.color = REDUCED_ZONE_COLOR if wind_reduced else NORMAL_ZONE_COLOR
	direction_label.text = REDUCED_DIRECTION_TEXT if wind_reduced else NORMAL_DIRECTION_TEXT
