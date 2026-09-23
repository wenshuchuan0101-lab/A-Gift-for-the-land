extends CharacterBody2D

signal item_received(item_type: StringName)

const DEFEND_MOVE_MULTIPLIER := 0.5
const DEFEND_WIND_MULTIPLIER := 0.3
const RESPAWN_SETTLE_FRAMES := 2
const RUN_ANIMATION_SPEED_MULTIPLIER := 1.5
const JUMP_ANIMATION_FPS := 48.0

@export var move_speed: float = 220.0
@export var jump_velocity: float = -420.0

@onready var anchor_visual: Polygon2D = $AnchorVisual
@onready var animated_sprite: AnimatedSprite2D = $Visual

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var external_force := Vector2.ZERO
var current_checkpoint: Vector2
var has_cloak := false
var has_spear := false
var is_defending := false
var is_anchored := false
var respawn_settle_frames := 0
var previous_direction := 0.0
var current_direction := 0.0
var jump_animation_ready := false


func _ready() -> void:
	current_checkpoint = global_position
	animated_sprite.animation_finished.connect(_on_animation_finished)
	_setup_jump_animation()
	animated_sprite.play(&"idle")


func _setup_jump_animation() -> void:
	if animated_sprite.sprite_frames.has_animation(&"jump"):
		jump_animation_ready = true
		return
	var frames := SpriteFrames.new()
	var files := DirAccess.get_files_at("res://art/player_runtime/jump")
	files.sort()
	for file_name in files:
		if file_name.to_lower().ends_with(".png"):
			var texture := load("res://art/player_runtime/jump/" + file_name) as Texture2D
			if texture != null:
				frames.add_frame(&"default", texture)
	if frames.get_frame_count(&"default") == 0:
		return
	frames.set_animation_speed(&"default", JUMP_ANIMATION_FPS)
	frames.set_animation_loop(&"default", false)
	var jump_frames := frames.get_frame_count(&"default")
	animated_sprite.sprite_frames.add_animation(&"jump")
	for index in jump_frames:
		animated_sprite.sprite_frames.add_frame(&"jump", frames.get_frame_texture(&"default", index))
		animated_sprite.sprite_frames.set_animation_speed(&"jump", JUMP_ANIMATION_FPS)
	animated_sprite.sprite_frames.set_animation_loop(&"jump", false)
	jump_animation_ready = true


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("respawn_test"):
		respawn()
		return

	if respawn_settle_frames > 0:
		velocity = Vector2.ZERO
		external_force = Vector2.ZERO
		move_and_slide()
		respawn_settle_frames -= 1
		return

	if not has_spear and is_anchored:
		_set_anchored(false)
	if has_spear and Input.is_action_just_pressed("anchor"):
		_set_anchored(not is_anchored)

	is_defending = has_cloak and not is_anchored and Input.is_action_pressed("defend")
	var direction := Input.get_axis("move_left", "move_right")
	current_direction = direction
	var current_move_speed := move_speed
	if is_anchored:
		current_move_speed = 0.0
	elif is_defending:
		current_move_speed *= DEFEND_MOVE_MULTIPLIER
	velocity.x = direction * current_move_speed

	if not is_anchored and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		if jump_animation_ready:
			animated_sprite.speed_scale = 1.0
			animated_sprite.play(&"jump")

	if not is_on_floor():
		velocity.y += gravity * delta

	velocity += external_force
	move_and_slide()
	external_force = Vector2.ZERO
	if is_on_floor():
		_update_animation(direction)
	elif jump_animation_ready and animated_sprite.animation != &"jump":
		animated_sprite.play(&"jump")


func add_external_force(force: Vector2) -> void:
	if is_anchored or respawn_settle_frames > 0:
		return
	external_force += force


func get_wind_resistance() -> float:
	if is_anchored:
		return 0.0
	if is_defending:
		return DEFEND_WIND_MULTIPLIER
	return 1.0


func set_control_enabled(enabled: bool) -> void:
	velocity = Vector2.ZERO
	external_force = Vector2.ZERO
	set_physics_process(enabled)


func set_checkpoint(pos: Vector2) -> void:
	current_checkpoint = pos


func respawn() -> void:
	global_position = current_checkpoint
	velocity = Vector2.ZERO
	external_force = Vector2.ZERO
	is_defending = false
	_set_anchored(false)
	respawn_settle_frames = RESPAWN_SETTLE_FRAMES
	previous_direction = 0.0
	current_direction = 0.0
	animated_sprite.speed_scale = 1.0
	animated_sprite.play(&"idle")
	set_physics_process(true)
	reset_physics_interpolation()


func _set_anchored(anchored: bool) -> void:
	is_anchored = anchored
	anchor_visual.visible = anchored
	if anchored:
		velocity = Vector2.ZERO
		external_force = Vector2.ZERO


func receive_item(item_type: StringName) -> void:
	match item_type:
		&"cloak":
			if has_cloak:
				return
			has_cloak = true
		&"spear":
			if has_spear:
				return
			has_spear = true
		_:
			return
	item_received.emit(item_type)


func _update_animation(direction: float) -> void:
	var moving := not is_zero_approx(direction)
	var was_moving := not is_zero_approx(previous_direction)
	if moving:
		animated_sprite.flip_h = direction < 0.0
		if not was_moving:
			animated_sprite.speed_scale = 1.0
			animated_sprite.play(&"start")
		elif animated_sprite.animation != &"start" and animated_sprite.animation != &"run":
			animated_sprite.speed_scale = 1.0
			animated_sprite.play(&"start")
		elif animated_sprite.animation == &"run":
			animated_sprite.speed_scale = clampf(absf(velocity.x) / maxf(move_speed, 0.001), 0.1, 1.5) * RUN_ANIMATION_SPEED_MULTIPLIER
	elif was_moving:
		animated_sprite.speed_scale = 1.0
		animated_sprite.play(&"stop")
	elif animated_sprite.animation != &"idle" and animated_sprite.animation != &"stop":
		animated_sprite.speed_scale = 1.0
		animated_sprite.play(&"idle")
	previous_direction = direction


func _on_animation_finished() -> void:
	if animated_sprite.animation == &"start":
		if not is_zero_approx(current_direction):
			animated_sprite.speed_scale = clampf(absf(velocity.x) / maxf(move_speed, 0.001), 0.1, 1.5) * RUN_ANIMATION_SPEED_MULTIPLIER
			animated_sprite.play(&"run")
		else:
			animated_sprite.speed_scale = 1.0
			animated_sprite.play(&"idle")
	elif animated_sprite.animation == &"stop":
		animated_sprite.play(&"idle")
