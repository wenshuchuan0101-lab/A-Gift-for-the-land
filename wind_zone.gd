extends Area2D

@export var wind_direction: Vector2 = Vector2.LEFT
@export var wind_force: float = 120.0

var player: CharacterBody2D
var player_in_zone := false
var wind_velocity := Vector2.ZERO


func _ready() -> void:
	wind_velocity = wind_direction.normalized() * wind_force
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	if player_in_zone and player != null and player.is_physics_processing():
		player.add_external_force(wind_velocity)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("add_external_force"):
		player = body
		player_in_zone = true


func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player_in_zone = false
		player = null
