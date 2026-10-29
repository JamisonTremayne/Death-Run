extends Control

const MAIN_MENU = preload("uid://clil80mjt55s8")

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_packed(MAIN_MENU)
