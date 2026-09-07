extends Node2D

@export var horizontal_only := false
@export var stop_at_end_point := true
@export var parallax_enabled := true

var parallax_layers: Array[Parallax2D] = []
var active_camera: Camera2D
var end_point: Marker2D
var parallax_started := false
var entry_camera_center := Vector2.ZERO
var has_previous_state := false
var previous_camera_center := Vector2.ZERO
var previous_root_position := Vector2.ZERO
var previous_root_scale := Vector2.ONE


func _ready() -> void:
	for node in find_children("*", "Parallax2D", true, false):
		var parallax := node as Parallax2D
		parallax.follow_viewport = false
		parallax.ignore_camera_scroll = true
		parallax.scroll_offset = Vector2.ZERO
		parallax_layers.append(parallax)

	end_point = get_node_or_null("SceneMarkers/EndPoint") as Marker2D
	active_camera = get_viewport().get_camera_2d()
	set_process(parallax_enabled and not parallax_layers.is_empty())


func _process(_delta: float) -> void:
	var viewport_camera := get_viewport().get_camera_2d()
	if viewport_camera != active_camera:
		active_camera = viewport_camera
		has_previous_state = false
	if not is_instance_valid(active_camera):
		return

	var camera_center := active_camera.get_screen_center_position()
	if (
		has_previous_state
		and camera_center.is_equal_approx(previous_camera_center)
		and global_position.is_equal_approx(previous_root_position)
		and global_scale.is_equal_approx(previous_root_scale)
	):
		return

	previous_camera_center = camera_center
	previous_root_position = global_position
	previous_root_scale = global_scale
	has_previous_state = true

	var local_camera_center := to_local(camera_center)
	if not parallax_started:
		var entry_position_x := camera_center.x
		var camera_parent := active_camera.get_parent() as Node2D
		if camera_parent != null:
			entry_position_x = camera_parent.global_position.x
		if entry_position_x < global_position.x:
			return
		parallax_started = true
		entry_camera_center = local_camera_center

	var camera_delta := local_camera_center - entry_camera_center
	camera_delta.x = maxf(camera_delta.x, 0.0)
	if stop_at_end_point and end_point != null:
		var maximum_delta_x := maxf(end_point.position.x - entry_camera_center.x, 0.0)
		camera_delta.x = minf(camera_delta.x, maximum_delta_x)
	if horizontal_only:
		camera_delta.y = 0.0
	for parallax in parallax_layers:
		parallax.scroll_offset = camera_delta * (Vector2.ONE - parallax.scroll_scale)
