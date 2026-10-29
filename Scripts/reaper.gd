class_name Reaper
extends Node3D

const BASE_MOVE_SPEED := 1.0
const ANGER_SPEED_MULTIPLIER := 0.5
const BASE_ROTATION_SPEED := 20.0
const ANGER_ROTATION_MULTIPLIER := 15.0
const STARTUP_TIME := 1.0
const JITTER_SCALE := 2
const SIGHT_COUNTDOWN_DEFAULT := 5

enum STATE { WANDERING, INVESTIGATING, CHASING }
@export var path_network: PathNetwork
@export var player: Player
@onready var shadow_light: OmniLight3D = $OmniLight3D
var check_timer: Timer
var follow_path: Array[Marker3D] = []
var last_path_marker: Marker3D = null
var next_path_marker: Marker3D = null
var target_location: Vector3 = Vector3.ZERO
var anger_level: int = 0
var jitter_value: int = 10
var jitter_count: int = 0
var sight_countdown: int = 5
var current_state: STATE = STATE.WANDERING
var b_player_in_sightcone: bool = false
var b_turning: bool = false
var b_in_room: bool = false
var b_killing: bool = false

func _ready() -> void:
	randomize()
	var startup_timer: Timer = Timer.new()
	add_child(startup_timer)
	startup_timer.timeout.connect(start)
	startup_timer.one_shot = true
	startup_timer.start(STARTUP_TIME)
	
	check_timer = Timer.new()
	add_child(check_timer)
	check_timer.timeout.connect(check_for_chase)
	check_timer.one_shot = false
	check_timer.autostart = false
	check_timer.wait_time = 1.0

func _physics_process(delta: float) -> void:
	if b_killing:
		return
	#print("Next Marker: ", next_path_marker)
	#print("Last Marker: ", last_path_marker)
	var move_speed: float = BASE_MOVE_SPEED + (anger_level * ANGER_SPEED_MULTIPLIER)
	var rotation_speed: float = deg_to_rad(BASE_ROTATION_SPEED + (anger_level * ANGER_ROTATION_MULTIPLIER))
	#var jitter := jitter_value
	#jitter_count += 1
	#if jitter_count >= jitter_value:
		#jitter_count = 0
		#jitter_value = randi_range(0, JITTER_SCALE * anger_level)
	if !next_path_marker and !last_path_marker:
		return
	elif !next_path_marker and last_path_marker:
		next_path_marker = last_path_marker
	var dir: Vector3 = (global_position.direction_to(next_path_marker.global_position)
	if !b_in_room else global_position.direction_to(target_location))
	dir.y = 0.0
	var target_rotation := atan2(-dir.x, -dir.z)
	rotation.y = rotate_toward(rotation.y, target_rotation, rotation_speed * delta)
	#print("Rotation: ", rotation.y, " ,", target_rotation)
	if absf(angle_difference(rotation.y, target_rotation)) < PI / 4:
		#print("Moving: ", global_position)
		#if jitter_count == 0:
		var step := move_speed * delta #* maxf(jitter, 1.0)
		var target_position := (next_path_marker.global_position if !b_in_room
		else target_location)
		if global_position.distance_to(target_position) < step:
			global_position = target_position
			if !b_in_room:
				if current_state == STATE.WANDERING:
					wander()
				else:
					last_path_marker = next_path_marker
					next_path_marker = follow_path.pop_front()
					check_entered_room()
					if !next_path_marker and !b_in_room:
						next_path_marker = last_path_marker
						current_state = STATE.WANDERING
			else:
				find_exit()
				current_state = STATE.WANDERING
		else:
			global_position += dir * step
		#else:
			#jitter_count -= 1

func wander() -> void:
	var current_marker: PathMarker = next_path_marker as PathMarker
	if !current_marker:
		var room_marker: RoomMarker = next_path_marker as RoomMarker
		if !room_marker || room_marker.path_connections.is_empty():
			return
		next_path_marker = room_marker.path_connections[0]
		last_path_marker = room_marker
		return
	var random_marker: PathMarker = null
	if last_path_marker:
		random_marker = current_marker.pick_random_connection([last_path_marker])
	if !random_marker:
		random_marker = current_marker.pick_random_connection([])
	last_path_marker = current_marker
	next_path_marker = random_marker
	#print("Last: ", last_path_marker.name)
	#print("Next: ", next_path_marker.name)

func investigate(noise_location: Vector3, is_player: bool = false) -> void:
	if current_state == STATE.CHASING and !is_player:
		return
	if current_state == STATE.WANDERING:
		current_state = STATE.INVESTIGATING
	target_location = noise_location
	#print("Noise heard at ", target_location, ". Investigating noise")
	target_location.y = 0
	var room: RoomArea = path_network.get_room_at_position(noise_location)
	if room:
		follow_path = path_network.find_best_room_entrance(next_path_marker, room, noise_location)
	else:
		if next_path_marker:
			follow_path = path_network.find_hallway_target(next_path_marker, path_network.get_closest_marker(noise_location))
	next_path_marker = follow_path.pop_front()

func check_entered_room() -> void:
	var room_marker: RoomMarker = last_path_marker as RoomMarker
	if room_marker and follow_path.is_empty():
		b_in_room = true

func find_exit() -> void:
	var room: RoomArea = path_network.get_room_at_position(global_position)
	if !room:
		next_path_marker = path_network.get_closest_marker(global_position)
		b_in_room = false
		return
	for exit in room.room_markers:
		if !exit.path_connections.is_empty():
			next_path_marker = exit
			b_in_room = false
			return

func start() -> void:
	var starting_marker := path_network.get_random_starting_marker()
	global_position = starting_marker.global_position
	last_path_marker = starting_marker
	next_path_marker = starting_marker
	wander()

func update_anger() -> void:
	shadow_light.omni_range = 3.0 + (2.0 * anger_level)
	shadow_light.light_energy = 0.5 + (0.5 * anger_level)
	shadow_light.light_size = 0.25 * anger_level

func check_for_chase() -> void:
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(global_position, player.global_position + Vector3.UP * 1.0)
	query.collision_mask = 1 | 16
	var raycast := space_state.intersect_ray(query)
	if !raycast.is_empty() and raycast.collider == player:
		#print("Player in sight")
		current_state = STATE.CHASING
		sight_countdown = SIGHT_COUNTDOWN_DEFAULT
	elif current_state == STATE.CHASING:
		sight_countdown -= 1
		#print("Countdown: ", sight_countdown)
		if sight_countdown <= 0:
			#print("Player now out of sight")
			if !follow_path.is_empty():
				current_state = STATE.INVESTIGATING
			else:
				current_state = STATE.WANDERING
			if !b_player_in_sightcone:
				check_timer.stop()
	if current_state == STATE.CHASING:
		#print("CHASING")
		investigate(player.global_position, true)
	

func _on_sight_cone_body_entered(body: Node3D) -> void:
	if body == player:
		#print("Player in sightcone")
		b_player_in_sightcone = true
		check_timer.start()

func _on_sight_cone_body_exited(body: Node3D) -> void:
	if body == player:
		#print("Player out of sightcone")
		b_player_in_sightcone = false


func _on_death_zone_body_entered(body: Node3D) -> void:
	if body == player:
		b_killing = true
		if Global.game_manager.active_arcade:
			await Global.game_manager.active_arcade.leave_machine()
		player.b_canlook = false
		player.b_canmove = false
		var tween := create_tween()
		var forward_dir: Vector3 = -global_transform.basis.z.normalized()
		forward_dir.y = 0.0
		var forward_pos: Vector3 = global_position + (forward_dir * 2.0) + Vector3.UP * 2.0
		var _object_rot := atan2(-forward_dir.x, -forward_dir.z) + PI
		var target_rotation := player.head.rotation.y + angle_difference(player.head.rotation.y, _object_rot)
		tween.tween_property(player, "global_position", forward_pos, 0.2)
		tween.parallel().tween_property(player.head, "rotation:y", target_rotation, 0.2)
		tween.parallel().tween_property(player.camera, "rotation_degrees", Vector3.ZERO, 0.2)
		tween.tween_property(player.camera, "fov", 179, 0.5)
		await tween.finished
		
		get_tree().change_scene_to_file("res://Scenes/lose_screen.tscn")
