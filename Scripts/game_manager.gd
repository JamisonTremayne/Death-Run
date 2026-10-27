extends Node

@export var debug_mode: bool = false
@export var reaper: Reaper
@export var player: Player

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

func increment_anger() -> void:
	reaper.anger_level += 1

## ONLY USED FOR DEBUG MODE
func decrement_anger() -> void:
	reaper.anger_level -= 1
