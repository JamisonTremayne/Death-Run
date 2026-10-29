class_name ArcadeGame
extends Control

const MAX_ITERATIONS := 3
@export var countdown_screen: CountdownScreen
@export var timer_display: TimerDisplay
@export var game_area: Node2D
@export var description: String = "What is going on?"
@export var minigame_time: int = 10
@export var b_timer_die: bool = false
@export var timer_sound: AudioStreamPlayer
@export var death_sound: AudioStreamPlayer
var countdown_timer: Timer
var alt_timer: Timer
var difficulty: int = 3
var difficulty_scaling: int = 3
var time_left: int = 5
## Saves how much time was left when a game was paused
var saved_time: int = 0
var iteration: int = 0
var b_in_countdown_screen: bool = true
var b_can_quit: bool = true
var b_game_paused: bool = false

signal game_complete
signal game_exited
signal died

func _ready() -> void:
	if Global.game_manager:
		difficulty = Global.game_manager.arcade_starting_difficulty
		difficulty_scaling = Global.game_manager.arcade_difficulty_scaling
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
	countdown_screen.set_info_label(description)

func _input(event: InputEvent) -> void:
	if b_can_quit and event.is_action_pressed("quit"):
		pause_game()

# This function should be overwritten for each minigame
func start_game() -> void:
	pass

func finish_game() -> void:
	game_area.call_deferred("set_process_mode", ProcessMode.PROCESS_MODE_DISABLED)
	iteration += 1
	if iteration >= MAX_ITERATIONS:
		game_completed()
	else:
		difficulty += difficulty_scaling
		_start_countdown()

func pause_game() -> void:
	b_can_quit = false
	countdown_timer.paused = true
	alt_timer.stop()
	if b_in_countdown_screen:
		saved_time = 0
	else:
		saved_time = time_left
		b_game_paused = true
	visible = false
	game_exited.emit()
	game_area.call_deferred("set_process_mode", ProcessMode.PROCESS_MODE_DISABLED)

func resume_game() -> void:
	b_can_quit = true
	visible = true
	countdown_timer.paused = false
	_start_countdown(true)
	
func game_completed() -> void:
	game_complete.emit()
	game_exited.emit()
	queue_free()

func die() -> void:
	died.emit()
	if death_sound:
		death_sound.play()
	b_can_quit = false
	countdown_timer.stop()
	game_area.modulate = Color.RED
	game_area.call_deferred("set_process_mode", ProcessMode.PROCESS_MODE_DISABLED)
	alt_timer.start(2.5)
	await alt_timer.timeout
	b_can_quit = true
	finish_game()

func _on_countdown_timer_timeout() -> void:
	time_left -= 1
	if timer_sound:
		timer_sound.play()
	if b_in_countdown_screen:
		countdown_screen.set_time_label(time_left)
		if time_left == 0:
			countdown_screen.visible = false
			b_in_countdown_screen = false
			countdown_timer.wait_time = 1.0
			time_left = minigame_time if !b_game_paused else saved_time
			timer_display.set_time_label(time_left)
			game_area.call_deferred("set_process_mode", ProcessMode.PROCESS_MODE_PAUSABLE)
			game_area.modulate = Color.WHITE
			if !b_game_paused:
				randomize()
				start_game()
			else:
				b_game_paused = false
				saved_time = 0
	else:
		timer_display.set_time_label(time_left)
		if time_left == 0:
			if b_timer_die:
				die()
			else:
				finish_game()

func _start_countdown(start_screen: bool = false) -> void:
	b_in_countdown_screen = true
	countdown_screen.visible = true
	if start_screen:
		time_left = 5
		countdown_timer.wait_time = 1.0
		countdown_screen.set_info_label(description)
	else:
		time_left = 3
		countdown_timer.wait_time = 0.5
		countdown_screen.set_info_label(Global.get_random_message())
	countdown_screen.set_time_label(time_left)
	countdown_timer.start()
