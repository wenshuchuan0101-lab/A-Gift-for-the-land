extends Control

const CHAPTER_CATALOG = preload("res://chapter_catalog.gd")
const MAIN_MENU_PATH := "res://Opening.tscn"
const SELECTED_COLOR := Color(1.0, 0.97, 0.86, 1.0)
const IDLE_COLOR := Color(0.72, 0.74, 0.73, 0.85)

@onready var chapter_list: VBoxContainer = $ChapterList
@onready var selection_marker: ColorRect = $SelectionMarker
@onready var begin_button: Button = $Footer/BeginButton

var selected_index := 0
var chapter_buttons: Array[Button] = []


func _ready() -> void:
	$Footer/BackButton.pressed.connect(_return_to_main_menu)
	begin_button.pressed.connect(_begin_selected_chapter)
	_build_chapter_buttons()
	_update_selection()


func _unhandled_input(event: InputEvent) -> void:
	if not is_inside_tree():
		return
	if event.is_action_pressed("ui_left"):
		get_viewport().set_input_as_handled()
		_move_selection(-1)
	elif event.is_action_pressed("ui_right"):
		get_viewport().set_input_as_handled()
		_move_selection(1)
	elif event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_begin_selected_chapter()
	elif event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_return_to_main_menu()


func _build_chapter_buttons() -> void:
	for index in CHAPTER_CATALOG.CHAPTERS.size():
		var chapter: Dictionary = CHAPTER_CATALOG.CHAPTERS[index]
		var button := Button.new()
		button.name = "Chapter%dButton" % (index + 1)
		button.text = chapter.display_name
		button.custom_minimum_size = Vector2(0, 74)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size", 30)
		button.add_theme_color_override("font_color", IDLE_COLOR)
		button.add_theme_color_override("font_hover_color", SELECTED_COLOR)
		button.add_theme_color_override("font_pressed_color", SELECTED_COLOR)
		button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_entered.connect(_select_chapter.bind(index))
		button.pressed.connect(_on_chapter_pressed.bind(index))
		chapter_list.add_child(button)
		chapter_buttons.append(button)


func _move_selection(direction: int) -> void:
	var next_index := selected_index
	for _attempt in CHAPTER_CATALOG.CHAPTERS.size():
		next_index = posmod(next_index + direction, CHAPTER_CATALOG.CHAPTERS.size())
		if CHAPTER_CATALOG.is_chapter_unlocked(next_index):
			_select_chapter(next_index)
			return


func _on_chapter_pressed(index: int) -> void:
	_select_chapter(index)
	_begin_selected_chapter()


func _select_chapter(index: int) -> void:
	if not CHAPTER_CATALOG.is_chapter_unlocked(index):
		return
	selected_index = index
	_update_selection()


func _update_selection() -> void:
	if chapter_buttons.is_empty() or not is_instance_valid(selection_marker):
		return
	for index in chapter_buttons.size():
		chapter_buttons[index].add_theme_color_override(
			"font_color", SELECTED_COLOR if index == selected_index else IDLE_COLOR
		)
	var selected_button := chapter_buttons[selected_index]
	selection_marker.position = chapter_list.position + selected_button.position + Vector2(-14.0, 19.0)


func _begin_selected_chapter() -> void:
	if not CHAPTER_CATALOG.is_chapter_unlocked(selected_index):
		return
	var chapter: Dictionary = CHAPTER_CATALOG.CHAPTERS[selected_index]
	get_tree().change_scene_to_file(chapter.scene_path)


func _return_to_main_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
