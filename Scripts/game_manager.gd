class_name GameManager
extends Node

const LOSE_SCREEN = preload("uid://b1upe8vgqyb8g")
const WIN_SCREEN = preload("uid://ct8gu07183cvu")
const ARCADEMACHINE = preload("uid://cvdiuifwvqj2y")
const ARCADE_BOMB_DODGE = preload("uid://44smhk5aro77")

@export var debug_mode: bool = false
@export var reaper: Reaper
@export var player: Player
@export var game_ui: GameUI
@export var arcade_spawn_points: Node3D
@export var minigame_layer: CanvasLayer
@export var exit_door: Node3D
var arcade_selection: Array[PackedScene] = [ARCADE_BOMB_DODGE]
var active_arcade: ArcadeMachine = null
var arcade_cycle_counter: int = 0
var machines_completed: int = 0
var machines_required: int = 1
var extra_machines: int = 14
var arcade_starting_difficulty: int = 3
var arcade_difficulty_scaling: int = 3

func _ready() -> void:
	Global.game_manager = self
	if !debug_mode:
		if Global.difficulty == Global.DIFFICULTY.EASY:
			machines_required = 5
			extra_machines = 2
			arcade_starting_difficulty = 2
			arcade_difficulty_scaling = 2
		elif Global.difficulty == Global.DIFFICULTY.NORMAL:
			machines_required = 7
			extra_machines = 1
			arcade_starting_difficulty = 3
			arcade_difficulty_scaling = 3
		else:
			machines_required = 10
			extra_machines = 0
			arcade_starting_difficulty = 4
			arcade_difficulty_scaling = 4
	_spawn_machines()
	game_ui.update_machine_label(machines_completed, machines_required)

## USEFUL CONTROLS FOR DEBUG MODE
func _unhandled_input(event: InputEvent) -> void:
	if !debug_mode:
		return
	if event.is_action_pressed("debug_increase_anger"):
		increment_anger()
	elif event.is_action_pressed("debug_decrease_anger"):
		decrement_anger()
	elif event.is_action_pressed("debug_reset"):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("debug_godmode"):
		player.b_godmode = !player.b_godmode
		if player.b_godmode:
			player.collision_mask = 0
		else:
			player.collision_mask = 1

func increment_anger() -> void:
	reaper.anger_level += 1
	print("Anger Increased -- Anger Level: ", reaper.anger_level)
	reaper.update_anger()

## ONLY USED FOR DEBUG MODE
func decrement_anger() -> void:
	reaper.anger_level -= 1
	reaper.update_anger()

func _on_machine_completed() -> void:
	machines_completed += 1
	game_ui.update_machine_label(machines_completed, machines_required)
	if machines_completed >= machines_required:
		exit_door.queue_free()
		game_ui.show_escape_message()
		reaper.anger_level *= 2 # Scary stuff right there

func _spawn_machines() -> void:
	var spawn_points: Array[Node] = arcade_spawn_points.get_children()
	for i in range(machines_required + extra_machines):
		var random_index: int = randi_range(0, spawn_points.size() - 1)
		var point: Marker3D = spawn_points[random_index] as Marker3D
		var arcade_machine: ArcadeMachine = ARCADEMACHINE.instantiate() as ArcadeMachine
		arcade_spawn_points.add_child(arcade_machine)
		arcade_machine.position = point.position
		arcade_machine.rotation = point.rotation
		spawn_points.remove_at(random_index)

func start_arcade_game() -> ArcadeGame:
	var chosen_arcade: ArcadeGame = arcade_selection[arcade_cycle_counter].instantiate() as ArcadeGame
	minigame_layer.add_child(chosen_arcade)
	
	arcade_cycle_counter += 1
	if arcade_cycle_counter >= arcade_selection.size():
		randomize()
		arcade_cycle_counter = 0
		arcade_selection.shuffle()
	
	return chosen_arcade

func make_noise(position: Vector3, magnitude: float) -> void:
	#print("Noise made at ", position, ".")
	var dist := position.distance_to(reaper.global_position)
	if dist <= magnitude:
		reaper.investigate(position)


func _on_escape_area_body_entered(body: Node3D) -> void:
	if body == player:
		get_tree().change_scene_to_file("res://Scenes/win_screen.tscn")
