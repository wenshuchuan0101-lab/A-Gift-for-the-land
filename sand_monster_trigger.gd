extends Area2D

@export var monster_path: NodePath

var monster: CharacterBody2D


func _ready() -> void:
	monster = get_node_or_null(monster_path) as CharacterBody2D
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("respawn"):
		if monster != null and monster.has_method("start_chase"):
			monster.start_chase()
