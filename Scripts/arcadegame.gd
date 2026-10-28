class_name ArcadeGame
extends Node2D

const MAX_ITERATIONS := 3
@export var countdown_screen: CountdownScreen
@export var timer_display: TimerDisplay
@export var minigame_time: int = 10
@export var b_timer_die: bool = false
var countdown_timer: Timer
var alt_timer: Timer
var difficulty: int = 2
var time_left: int = 5
var iteration: int = 0
var b_in_countdown_screen: bool = true
var b_can_quit: bool = false

signal game_complete
signal game_exited

func _ready() -> void:
	if Global.game_manager:
		difficulty = Global.game_manager.arcade_starting_difficulty
	countdown_timer = Timer.new()
	add_child(countdown_timer)
	countdown_timer.autostart = true
	countdown_timer.one_shot = false
	countdown_timer.wait_time = 1.0
	countdown_timer.timeout.connect(_on_countdown_timer_timeout)
	countdown_timer.start()
	alt_timer = Timer.new()
	add_child(alt_timer)
	alt_timer.autostart = false
	alt_timer.one_shot = true

func _input(event: InputEvent) -> void:
	if b_can_quit and event.is_action_pressed("quit"):
		pause_game()

# This function should be overwritten for each minigame
func start_game() -> void:
	pass

func finish_game() -> void:
	iteration += 1
	if iteration >= MAX_ITERATIONS:
		game_completed()
	else:
		if Global.game_manager:
			difficulty += Global.game_manager.arcade_difficulty_scaling
		_start_countdown()

func pause_game() -> void:
	countdown_timer.paused = true
	visible = false
	game_exited.emit()
	process_mode = Node.PROCESS_MODE_DISABLED

func resume_game() -> void:
	visible = true
	alt_timer.start(1.5)
	await alt_timer.timeout
	countdown_timer.paused = false

func game_completed() -> void:
	game_complete.emit()
	game_exited.emit()
	queue_free()

func die() -> void:
	if Global.game_manager:
		Global.game_manager.increment_anger()
	modulate = Color.RED
	alt_timer.start(2.5)
	await alt_timer.timeout
	modulate = Color.WHITE
	finish_game()

func _on_countdown_timer_timeout() -> void:
	time_left -= 1
	if b_in_countdown_screen:
		countdown_screen.set_time_label(time_left)
		if time_left == 0:
			countdown_screen.visible = false
			b_in_countdown_screen = false
			countdown_timer.wait_time = 1.0
			time_left = minigame_time
			timer_display.set_time_label(time_left)
			start_game()
	else:
		timer_display.set_time_label(time_left)
		if time_left == 0:
			if b_timer_die:
				die()
			else:
				finish_game()

func _start_countdown() -> void:
	b_in_countdown_screen = true
	countdown_screen.visible = true
	time_left = 3
	countdown_screen.set_time_label(time_left)
	countdown_timer.wait_time = 0.5
	countdown_timer.start()
