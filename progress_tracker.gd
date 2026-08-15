extends Node

signal progress_changed(flag_name: StringName)

var found_seed := false
var got_cloak := false
var got_spear := false
var repaired_grass := false
var saw_memory := false
var completed_chase := false
var planted_seed := false


func mark_found_seed() -> void:
	if found_seed:
		return
	found_seed = true
	progress_changed.emit(&"found_seed")


func mark_got_cloak() -> void:
	if got_cloak:
		return
	got_cloak = true
	progress_changed.emit(&"got_cloak")


func mark_got_spear() -> void:
	if got_spear:
		return
	got_spear = true
	progress_changed.emit(&"got_spear")


func mark_repaired_grass() -> void:
	if repaired_grass:
		return
	repaired_grass = true
	progress_changed.emit(&"repaired_grass")


func mark_saw_memory() -> void:
	if saw_memory:
		return
	saw_memory = true
	progress_changed.emit(&"saw_memory")


func mark_completed_chase() -> void:
	if completed_chase:
		return
	completed_chase = true
	progress_changed.emit(&"completed_chase")


func mark_planted_seed() -> void:
	if planted_seed:
		return
	planted_seed = true
	progress_changed.emit(&"planted_seed")
