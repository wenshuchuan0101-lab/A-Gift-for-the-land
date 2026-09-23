extends SceneTree

const SELECTOR_PATH := "res://scenes/ui/chapter_selection.tscn"
const MENU_PATH := "res://Opening.tscn"
const CHAPTER_PATHS := [
	"res://Demo_Level.tscn",
	"res://scenes/testing/chapter_2_test.tscn",
	"res://scenes/testing/chapter_3_test.tscn",
]

var failure_count := 0


func _initialize() -> void:
	_run_tests.call_deferred()


func _run_tests() -> void:
	await change_scene_to_file(SELECTOR_PATH)
	await process_frame
	await process_frame
	var selector := current_scene as Control
	_assert(selector != null, "chapter selection scene loads")
	_assert(selector.selected_index == 0, "initial chapter is Scene 1")
	_assert(selector.chapter_buttons[0].text == "Scene 1", "first entry label")
	_assert(selector.chapter_buttons[1].text == "Scene 2", "second entry label")
	_assert(selector.chapter_buttons[2].text == "Scene 3", "third entry label")

	var right := InputEventKey.new()
	right.keycode = KEY_RIGHT
	right.pressed = true
	Input.parse_input_event(right)
	await process_frame
	_assert(selector.selected_index == 1, "right arrow selects Scene 2")

	var left := InputEventKey.new()
	left.keycode = KEY_LEFT
	left.pressed = true
	Input.parse_input_event(left)
	await process_frame
	_assert(selector.selected_index == 0, "left arrow returns to Scene 1")

	selector.chapter_buttons[2].mouse_entered.emit()
	_assert(selector.selected_index == 2, "mouse hover selects Scene 3")
	selector.chapter_buttons[2].pressed.emit()
	await process_frame
	_assert(current_scene != null and current_scene.scene_file_path == CHAPTER_PATHS[2], "mouse click enters Scene 3")
	var mouse_cancel := InputEventAction.new()
	mouse_cancel.action = "ui_cancel"
	mouse_cancel.pressed = true
	current_scene._unhandled_input(mouse_cancel)
	await process_frame
	await process_frame
	selector = current_scene

	for chapter_path in CHAPTER_PATHS:
		var chapter_index := CHAPTER_PATHS.find(chapter_path)
		selector._select_chapter(chapter_index)
		var enter_key := InputEventAction.new()
		enter_key.action = "ui_accept"
		enter_key.pressed = true
		selector._unhandled_input(enter_key)
		await process_frame
		await process_frame
		_assert(current_scene != null and current_scene.scene_file_path == chapter_path, "BEGIN opens " + chapter_path)
		if chapter_index > 0:
			var cancel := InputEventAction.new()
			cancel.action = "ui_cancel"
			cancel.pressed = true
			current_scene._unhandled_input(cancel)
			await process_frame
			await process_frame
			_assert(current_scene != null and current_scene.scene_file_path == SELECTOR_PATH, "ESC returns from test scene")
			selector = current_scene
		else:
			await change_scene_to_file(SELECTOR_PATH)
			await process_frame
			selector = current_scene

	var back_key := InputEventAction.new()
	back_key.action = "ui_cancel"
	back_key.pressed = true
	selector._unhandled_input(back_key)
	await process_frame
	_assert(current_scene != null and current_scene.scene_file_path == MENU_PATH, "BACK returns to main menu")

	await change_scene_to_file(SELECTOR_PATH)
	await process_frame
	await process_frame
	if failure_count == 0:
		print("CHAPTER_SELECTION_TESTS_OK")
	else:
		printerr("CHAPTER_SELECTION_TESTS_FAILED: %d" % failure_count)
	quit(0 if failure_count == 0 else 1)


func _assert(condition: bool, description: String) -> void:
	if condition:
		print("PASS: " + description)
	else:
		failure_count += 1
		printerr("FAIL: " + description)
