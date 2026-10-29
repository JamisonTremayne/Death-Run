class_name ArcadeMachine
extends Interactable

const ARCADETEXTURE_01 = preload("uid://boq0g3bcfq8kd")
const ARCADETEXTURE_02 = preload("uid://c03i7hbrd6phu")
const ARCADETEXTURE_03 = preload("uid://bf7lbhlq4f17a")
const ARCADETEXTURE_04 = preload("uid://b5ncpmkg3hk4t")
const ARCADETEXTURE_05 = preload("uid://d3e6co7fnpqx2")

@onready var machine_mesh: MeshInstance3D = $"Machine Mesh"
@onready var screen_mesh: MeshInstance3D = $"Screen Mesh"
@onready var textures: Array[Texture] = [ARCADETEXTURE_01, ARCADETEXTURE_02, ARCADETEXTURE_03, ARCADETEXTURE_04, ARCADETEXTURE_05]
@onready var death_audio: AudioStreamPlayer3D = $"Death Audio"
@onready var ambient_audio: AudioStreamPlayer3D = $"Ambient Audio"
## This variable keeps track of the game on the machine in case the player pauses it and leaves.
var arcade_game: ArcadeGame = null 
var active: bool = true
var using: bool = false

signal machine_completed

func _ready() -> void:
	var machine_mat: StandardMaterial3D = machine_mesh.material_override.duplicate() as StandardMaterial3D
	var random_index: int = randi_range(0, textures.size() - 1)
	machine_mat.albedo_texture = textures[random_index]
	machine_mesh.material_override = machine_mat
	var random_color: Color = Color.from_hsv(randf(), randf_range(0.5, 1.0), randf_range(0.75, 1.0))
	var screen_mat: StandardMaterial3D = screen_mesh.material_override.duplicate() as StandardMaterial3D
	screen_mat.albedo_color = random_color
	screen_mat.emission = random_color
	screen_mesh.material_override = screen_mat
	
	machine_completed.connect(Global.game_manager._on_machine_completed)

func interact() -> void:
	if !active || using:
		return
	var player: Player = Global.game_manager.player
	player.b_canmove = false
	player.b_canlook = false
	using = true
	ambient_audio.stop()
	await _player_enter_animation()
	Global.game_manager.active_arcade = self
	if !arcade_game:
		arcade_game = Global.game_manager.start_arcade_game()
		arcade_game.game_exited.connect(leave_machine)
		arcade_game.game_complete.connect(complete)
		arcade_game.died.connect(arcade_die)
	else:
		arcade_game.resume_game()
	
func leave_machine() -> void:
	var player: Player = Global.game_manager.player
	await _player_exit_animation()
	player.b_canmove = true
	player.b_canlook = true
	using = false
	if active:
		ambient_audio.play()
	Global.game_manager.active_arcade = null

func _player_enter_animation() -> void:
	var player: Player = Global.game_manager.player
	# Move to machine animation
	var tween := create_tween()
	var forward_dir: Vector3 = global_transform.basis.x.normalized()
	forward_dir.y = 0.0
	var forward_pos: Vector3 = global_position + (forward_dir * 2.0)
	var _object_rot := atan2(-forward_dir.x, -forward_dir.z) + PI
	var target_rotation := player.head.rotation.y + angle_difference(player.head.rotation.y, _object_rot)
	tween.tween_property(player, "global_position", forward_pos, 0.2)
	tween.parallel().tween_property(player.head, "rotation:y", target_rotation, 0.2)
	tween.parallel().tween_property(player.camera, "rotation_degrees", Vector3.ZERO, 0.2)
	await tween.finished
	# Zoom in animation
	tween = create_tween()
	tween.tween_property(player.camera, "global_position", global_position + (forward_dir * 0.2) + player.CAMERA_DEFAULT_POS - Vector3(0, 0.2, 0), 1.2)
	tween.parallel().tween_property(player.camera, "rotation_degrees:x", -60, 1.2)
	await tween.finished
	return

func _player_exit_animation() -> void:
	var player: Player = Global.game_manager.player
	# Zoom out animation
	var tween := create_tween()
	var forward_dir: Vector3 = global_transform.basis.x.normalized()
	var forward_pos: Vector3 = global_position + (forward_dir * 2.0)
	tween.tween_property(player.camera, "global_position", forward_pos + player.CAMERA_DEFAULT_POS, 0.4)
	tween.parallel().tween_property(player.camera, "rotation_degrees:x", 0.0, 0.4)
	await tween.finished
	return


func complete() -> void:
	screen_mesh.visible = false
	active = false
	machine_completed.emit()

func arcade_die() -> void:
	if Global.game_manager:
		Global.game_manager.increment_anger()
	death_audio.play()
	Global.game_manager.make_noise(global_position, 10000000000.0)
