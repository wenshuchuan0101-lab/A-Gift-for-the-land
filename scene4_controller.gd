extends Node3D

@export_category("Chase")
@export var chase_start_delay: float = 0.8
@export var chase_speed: float = 4.2
@export var pressure: float = 1.0
@export_category("Atmosphere")
@export var dusk_to_night_duration: float = 120.0
@export_range(0.0, 0.08, 0.001) var fog_intensity: float = 0.018
@export_category("Player")
@export var player_walk_speed: float = 5.5
@export var player_sprint_speed: float = 9.5
@export_category("Wind Boundary")
@export var wind_force: float = 18.0
@export var wind_clear_half_width: float = 10.0
@export var wind_zone_outer_x: float = 21.0

@onready var player: CharacterBody3D = $Player
@onready var pursuer: CharacterBody3D = $Pursuer
@onready var environment: WorldEnvironment = $Lighting/WorldEnvironment
@onready var sun: DirectionalLight3D = $Lighting/Sun
@onready var status_label: Label = $HUD/Status
@onready var progress_bar: ProgressBar = $HUD/Progress
@onready var start_trigger: Area3D = $Triggers/ChaseStart
@onready var exit_trigger: Area3D = $Exit/ExitTrigger
var chase_started := false
var target_caught := false
var finished := false
var elapsed := 0.0

func _ready() -> void:
	player.walk_speed = player_walk_speed
	player.sprint_speed = player_sprint_speed
	pursuer.run_speed = chase_speed * pressure
	pursuer.player_caught_target.connect(_on_player_caught_target)
	start_trigger.body_entered.connect(_on_start_trigger_body_entered)
	exit_trigger.body_entered.connect(_on_exit_body_entered)
	status_label.text = "黄昏入口 · 发现前方红光后追上去 · WASD / Shift"
	progress_bar.value = 0.0
	_update_atmosphere(0.0)

func _process(_delta: float) -> void:
	if finished:
		return
	elapsed += _delta
	var progress := clampf(-player.global_position.z / 480.0, 0.0, 1.0)
	progress_bar.value = progress * 100.0
	_update_atmosphere(maxf(progress, clampf(elapsed / maxf(dusk_to_night_duration, 0.1), 0.0, 1.0)))
	_apply_edge_wind()
	if chase_started and not target_caught:
		status_label.text = "追逐中 · 怪物在前方，穿过石林追上它" if progress < 0.88 else "夜晚冲刺 · 追上红光并抵达出口"

func _apply_edge_wind() -> void:
	var x := player.global_position.x
	var magnitude := 0.0
	var direction := 0.0
	if absf(x) > wind_clear_half_width:
		magnitude = clampf((absf(x) - wind_clear_half_width) / maxf(wind_zone_outer_x - wind_clear_half_width, 0.1), 0.0, 1.0)
		direction = -signf(x)
	player.velocity.x += direction * magnitude * wind_force * get_process_delta_time()

func _on_start_trigger_body_entered(body: Node3D) -> void:
	if body != player or chase_started or finished:
		return
	chase_started = true
	status_label.text = "追逐开始 · 怪物在前方，别让它消失"
	await get_tree().create_timer(chase_start_delay).timeout
	if chase_started and not finished:
		pursuer.start_chase()

func _on_player_caught_target() -> void:
	if finished:
		return
	target_caught = true
	status_label.text = "追上了追逐者 · 继续向夜晚出口前进"

func _on_exit_body_entered(body: Node3D) -> void:
	if body != player or finished:
		return
	finished = true
	chase_started = false
	pursuer.stop_chase()
	pursuer.visible = false
	player.set_controls_enabled(false)
	status_label.text = "已抵达雅丹出口 · 第四场景完成"
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _update_atmosphere(progress: float) -> void:
	var env := environment.environment
	var night_progress := smoothstep(0.18, 0.96, progress)
	var dusk := Color("#e7a06d")
	var twilight := Color("#7b5874")
	var night := Color("#081225")
	var sky_color := dusk.lerp(twilight, smoothstep(0.08, 0.48, progress)).lerp(night, night_progress)
	env.background_color = sky_color
	env.ambient_light_color = Color("#ffd0a1").lerp(Color("#7896d0"), night_progress)
	env.ambient_light_energy = lerpf(1.15, 0.5, night_progress)
	env.fog_enabled = true
	env.fog_light_color = Color("#d79b7b").lerp(Color("#233456"), night_progress)
	env.fog_density = lerpf(fog_intensity * 0.25, fog_intensity, night_progress)
	sun.light_color = Color("#ffd2a5").lerp(Color("#6d86c4"), night_progress)
	sun.light_energy = lerpf(1.5, 0.2, night_progress)
	sun.rotation_degrees = Vector3(-34.0 - progress * 18.0, -38.0 + progress * 20.0, 0.0)



