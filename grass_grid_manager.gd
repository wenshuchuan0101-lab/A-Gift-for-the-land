extends Node

const WIND_MODIFIERS: Array[float] = [1.0, 0.8, 0.6, 0.4]

@export var wind_zone_path: NodePath

var wind_zone: Area2D
var repaired_count := 0
var total_count := 0
var current_wind_modifier := 1.0


func _ready() -> void:
	wind_zone = get_node_or_null(wind_zone_path) as Area2D
	var repair_callback := Callable(self, "_on_grass_repair_completed")
	for child in get_parent().get_children():
		if child.has_signal("repair_completed"):
			total_count += 1
			if not child.is_connected("repair_completed", repair_callback):
				child.connect("repair_completed", repair_callback)
	call_deferred("_apply_wind_modifier")


func _on_grass_repair_completed() -> void:
	if repaired_count >= total_count:
		return
	repaired_count += 1
	_apply_wind_modifier()


func _apply_wind_modifier() -> void:
	var modifier_index := mini(repaired_count, WIND_MODIFIERS.size() - 1)
	current_wind_modifier = WIND_MODIFIERS[modifier_index]
	if wind_zone != null and wind_zone.has_method("set_environment_modifier"):
		wind_zone.set_environment_modifier(current_wind_modifier)
