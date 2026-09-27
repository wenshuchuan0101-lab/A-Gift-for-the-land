extends CharacterBody3D

@export var walk_speed: float = 5.5
@export var sprint_speed: float = 9.5
@export var mouse_sensitivity: float = 0.0025
@export var gravity: float = 20.0

@onready var camera: Camera3D = $Head/Camera3D
@onready var head: Node3D = $Head
var pitch := 0.0
var start_transform: Transform3D
var controls_enabled := true

func _ready() -> void:
	start_transform = global_transform
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and controls_enabled:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clampf(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-82.0), deg_to_rad(82.0))
		head.rotation.x = pitch
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if not controls_enabled:
		velocity = Vector3.ZERO
		return
	var axis := Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	var local := Vector3(axis.x, 0.0, -axis.y)
	var direction := (global_transform.basis * local).normalized()
	var speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	velocity.x = move_toward(velocity.x, direction.x * speed, speed * 8.0 * delta)
	velocity.z = move_toward(velocity.z, direction.z * speed, speed * 8.0 * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.2
	move_and_slide()

func reset_to_start() -> void:
	global_transform = start_transform
	velocity = Vector3.ZERO
	pitch = 0.0
	head.rotation = Vector3.ZERO
	reset_physics_interpolation()

func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	if not enabled:
		velocity = Vector3.ZERO

