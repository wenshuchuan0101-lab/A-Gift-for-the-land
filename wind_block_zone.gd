extends Area2D

@export var wind_zone_path: NodePath
@export_range(0.0, 1.0, 0.05) var sheltered_wind_multiplier := 0.2

var wind_zone: Area2D
var sheltered_player: CharacterBody2D


func _ready() -> void:
	wind_zone = get_node_or_null(wind_zone_path) as Area2D
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and wind_zone != null and wind_zone.has_method("set_wind_multiplier"):
		sheltered_player = body
		wind_zone.set_wind_multiplier(sheltered_wind_multiplier)


func _on_body_exited(body: Node2D) -> void:
	if body == sheltered_player:
		if wind_zone != null and wind_zone.has_method("set_wind_multiplier"):
			wind_zone.set_wind_multiplier(1.0)
		sheltered_player = null
