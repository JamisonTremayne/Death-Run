class_name Reaper
extends Node3D

const BASE_MOVE_SPEED := 1.0
const ANGER_SPEED_MULTIPLIER := 0.5
const BASE_ROTATION_SPEED := 20.0
const ANGER_ROTATION_MULTIPLIER := 15.0
const STARTUP_TIME := 1.0
const JITTER_SCALE := 2

enum STATE { WANDERING, INVESTIGATING, CHASING }
@export var path_network: PathNetwork
@export var player: Player
var last_path_marker: PathMarker = null
var next_path_marker: PathMarker = null
var anger_level: int = 0
var jitter_value: int = 10
var jitter_count: int = 0
var current_state: STATE = STATE.WANDERING
var b_turning: bool = false

func _ready() -> void:
	randomize()
	var startup_timer: Timer = Timer.new()
	add_child(startup_timer)
	startup_timer.timeout.connect(start)
	startup_timer.one_shot = true
	startup_timer.start(STARTUP_TIME)

func _physics_process(delta: float) -> void:
	#print("Next Marker: ", next_path_marker)
	#print("Last Marker: ", last_path_marker)
	var move_speed: float = BASE_MOVE_SPEED + (anger_level * ANGER_SPEED_MULTIPLIER)
	var rotation_speed: float = deg_to_rad(BASE_ROTATION_SPEED + (anger_level * ANGER_ROTATION_MULTIPLIER))
	#var jitter := jitter_value
	#jitter_count += 1
	#if jitter_count >= jitter_value:
		#jitter_count = 0
		#jitter_value = randi_range(0, JITTER_SCALE * anger_level)
	if current_state == STATE.WANDERING:
		if !next_path_marker and !last_path_marker:
			return
		elif !next_path_marker and last_path_marker:
			next_path_marker = last_path_marker
		var dir: Vector3 = global_position.direction_to(next_path_marker.global_position)
		dir.y = 0.0
		var target_rotation := atan2(-dir.x, -dir.z)
		rotation.y = rotate_toward(rotation.y, target_rotation, rotation_speed * delta)
		#print("Rotation: ", rotation.y, " ,", target_rotation)
		if absf(angle_difference(rotation.y, target_rotation)) < PI / 4:
			#print("Moving: ", global_position)
			#if jitter_count == 0:
			var step := move_speed * delta #* maxf(jitter, 1.0)
			if global_position.distance_to(next_path_marker.global_position) < step:
				global_position = next_path_marker.global_position
				wander()
			else:
				global_position += dir * step
		#else:
			#jitter_count -= 1

func wander() -> void:
	var current_marker: PathMarker = next_path_marker
	var random_marker: PathMarker = null
	if last_path_marker:
		random_marker = current_marker.pick_random_connection([last_path_marker])
	if !random_marker:
		random_marker = current_marker.pick_random_connection([])
	last_path_marker = current_marker
	next_path_marker = random_marker
	#print("Last: ", last_path_marker.name)
	#print("Next: ", next_path_marker.name)

func start() -> void:
	var starting_marker := path_network.get_random_starting_marker()
	global_position = starting_marker.global_position
	last_path_marker = starting_marker
	next_path_marker = starting_marker
	wander()
