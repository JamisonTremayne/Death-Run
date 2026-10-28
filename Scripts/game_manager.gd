class_name GameManager
extends Node

const ARCADEMACHINE = preload("uid://cvdiuifwvqj2y")

@export var debug_mode: bool = false
@export var reaper: Reaper
@export var player: Player
@export var game_ui: GameUI
@export var arcade_spawn_points: Node3D
var machines_completed: int = 0
var machines_required: int = 14
var extra_machines: int = 1
var arcade_starting_difficulty: int = 3
var arcade_difficulty_scaling: int = 3

func _ready() -> void:
	Global.game_manager = self
	
	_spawn_machines()

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

## ONLY USED FOR DEBUG MODE
func decrement_anger() -> void:
	reaper.anger_level -= 1

func _on_machine_completed() -> void:
	machines_completed += 1
	game_ui.update_machine_label(machines_completed, machines_required)

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
