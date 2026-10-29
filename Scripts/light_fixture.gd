extends AreaLight3D

const BASE_EMISSION_VALUE := 4.0
enum STATE { ON, OFF, FLICKERING }
@export var can_randomize: bool = true
@export var state: STATE = STATE.ON
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
var mat: StandardMaterial3D
var flicker_timer: Timer

func _ready() -> void:
	mat = mesh_instance.material_override.duplicate() as StandardMaterial3D
	mesh_instance.material_override = mat
	if can_randomize:
		var on_percent: float = 0.6
		var off_percent: float = 0.3
		if Global.difficulty == Global.DIFFICULTY.EASY:
			on_percent = 0.8
			off_percent = 0.15
		elif Global.difficulty == Global.DIFFICULTY.HARD:
			on_percent = 0.3
			off_percent = 0.5
		randomize_state(on_percent, off_percent)
	else:
		apply_state()

func randomize_state(on_percent: float = 0.6, off_percent: float = 0.3) -> void:
	if flicker_timer:
		flicker_timer.stop()
		flicker_timer.queue_free()
	var random_index = randf()
	if random_index < on_percent:
		state = STATE.ON
	elif random_index < on_percent + off_percent:
		state = STATE.OFF
	else:
		state = STATE.FLICKERING
	apply_state()

func apply_state() -> void:
	if state == STATE.ON:
		turn_on()
	elif state == STATE.OFF:
		turn_off()
	else:
		if !flicker_timer:
			flicker_timer = Timer.new()
			flicker_timer.autostart = false
			flicker_timer.one_shot = true
			add_child(flicker_timer)
			flicker()

func turn_on() -> void:
	light_energy = 1.0
	mat.emission_energy_multiplier = BASE_EMISSION_VALUE

func turn_off() -> void:
	light_energy = 0.0
	mat.emission_energy_multiplier = 0.0

func flicker() -> void:
	turn_on()
	var random_on_duration: float = randf_range(0.1, 3.0)
	flicker_timer.start(random_on_duration)
	await flicker_timer.timeout
	
	turn_off()
	var random_off_duration: float = randf_range(0.01, 0.3)
	flicker_timer.start(random_off_duration)
	await flicker_timer.timeout
	
	if state == STATE.FLICKERING:
		flicker()
