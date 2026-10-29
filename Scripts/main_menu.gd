extends Node3D

const LEVEL = preload("uid://5ncjop0qs11p")

@export var main_menu: Control
@export var htp_menu: Control
@export var play_menu: Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_play_button_pressed() -> void:
	main_menu.visible = false
	play_menu.visible = true

func _on_htp_button_pressed() -> void:
	main_menu.visible = false
	htp_menu.visible = true

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_easy_mode_pressed() -> void:
	Global.difficulty = Global.DIFFICULTY.EASY
	get_tree().change_scene_to_packed(LEVEL)

func _on_normal_mode_pressed() -> void:
	Global.difficulty = Global.DIFFICULTY.NORMAL
	get_tree().change_scene_to_packed(LEVEL)

func _on_hard_mode_pressed() -> void:
	Global.difficulty = Global.DIFFICULTY.HARD
	get_tree().change_scene_to_packed(LEVEL)

func _on_back_button_pressed() -> void:
	main_menu.visible = true
	htp_menu.visible = false
	play_menu.visible = false
