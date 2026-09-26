extends Node

const SAVE_PATH := "user://fengyu_save.json"
const CHAPTER_SELECTION_PATH := "res://scenes/ui/chapter_selection.tscn"

var notice: Label
var notice_timer: Timer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_notice()

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey or not event.pressed or event.echo:
		return
	if event.keycode == KEY_F5:
		get_viewport().set_input_as_handled()
		save_game()
	elif event.keycode == KEY_F6:
		get_viewport().set_input_as_handled()
		return_to_chapter_selection()

func save_game() -> void:
	var data := {
		"scene_path": get_tree().current_scene.scene_file_path if get_tree().current_scene != null else "",
		"saved_at": Time.get_datetime_string_from_system(),
		"progress": _read_progress(),
		"player_position": _read_player_position(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_show_notice("SAVE FAILED")
		return
	file.store_string(JSON.stringify(data))
	file.close()
	_show_notice("GAME SAVED")

func return_to_chapter_selection() -> void:
	get_tree().change_scene_to_file(CHAPTER_SELECTION_PATH)

func _read_progress() -> Dictionary:
	var tracker := get_tree().get_first_node_in_group("progress_tracker")
	if tracker == null:
		tracker = get_tree().current_scene.get_node_or_null("Chapter1Controller/ProgressTracker") if get_tree().current_scene != null else null
	if tracker == null:
		return {}
	var result := {}
	for property_name in ["found_seed", "got_cloak", "got_spear", "repaired_grass", "saw_memory", "completed_chase", "planted_seed"]:
		result[property_name] = bool(tracker.get(property_name))
	return result

func _read_player_position() -> Dictionary:
	var player := get_tree().get_first_node_in_group("player")
	if player == null and get_tree().current_scene != null:
		player = get_tree().current_scene.get_node_or_null("PlayerSpawn/Player")
	if player == null:
		return {}
	var position: Vector2 = player.global_position
	return {"x": position.x, "y": position.y}

func _setup_notice() -> void:
	notice = Label.new()
	notice.name = "SaveNotice"
	notice.position = Vector2(0, 0)
	notice.size = Vector2(260, 44)
	notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notice.add_theme_font_size_override("font_size", 18)
	notice.add_theme_color_override("font_color", Color(0.95, 0.94, 0.86, 1))
	notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notice.visible = false
	var layer := CanvasLayer.new()
	layer.layer = 200
	layer.add_child(notice)
	add_child(layer)
	notice_timer = Timer.new()
	notice_timer.one_shot = true
	notice_timer.wait_time = 1.5
	notice_timer.timeout.connect(func(): notice.visible = false)
	add_child(notice_timer)

func _show_notice(message: String) -> void:
	if notice == null:
		return
	notice.text = message
	notice.position = Vector2((get_viewport().get_visible_rect().size.x - notice.size.x) * 0.5, get_viewport().get_visible_rect().size.y - 86.0)
	notice.visible = true
	notice_timer.start()

