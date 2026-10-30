extends ArcadeGame

@export var W: Sprite2D
@export var A: Sprite2D
@export var S: Sprite2D
@export var D: Sprite2D
@export var feedback_sound: AudioStreamPlayer
var pattern_timer: Timer
var normal_color: Color = Color("bbb66fff")
var good_color: Color = Color(0.98, 0.957, 0.637, 1.0)
var bad_color: Color = Color(0.98, 0.049, 0.049, 1.0)
var W_pitch := 0.5
var A_pitch := 0.8
var S_pitch := 1.1
var D_pitch := 1.4
var pattern: Array[int] = []
var next_note: int = -1
var b_player_turn: bool = false

func _ready() -> void:
	super._ready()
	pattern_timer = Timer.new()
	game_area.add_child(pattern_timer)
	pattern_timer.autostart = false
	pattern_timer.one_shot = true

func _unhandled_input(event: InputEvent) -> void:
	if !b_player_turn:
		return
	if event.is_action_pressed("move_forward"):
		try_hit(0)
	elif event.is_action_pressed("move_left"):
		try_hit(1)
	elif event.is_action_pressed("move_backward"):
		try_hit(2)
	elif event.is_action_pressed("move_right"):
		try_hit(3)

func start_game() -> void:
	countdown_timer.paused = true
	create_pattern()

func finish_game() -> void:
	_reset_game()
	super.finish_game()

func create_pattern() -> void:
	var pattern_amount := floori(difficulty * 0.78) + 1
	var pattern_timer_delay := 1.5 / (1.2 ** difficulty)
	pattern_timer.start(0.5)
	await pattern_timer.timeout
	for i in range(pattern_amount):
		var val: int = randi_range(0, 3)
		good_hit(val, pattern_timer_delay * 0.8)
		pattern.append(val)
		pattern_timer.start(pattern_timer_delay)
		await pattern_timer.timeout
	next_note = pattern.pop_front()
	b_player_turn = true
	countdown_timer.paused = false

func try_hit(value: int) -> void:
	if value != next_note:
		bad_hit(value)
		die()
	else:
		good_hit(value)
		if !pattern.is_empty():
			next_note = pattern.pop_front()
		else:
			finish_game()

func _reset_game() -> void:
	b_player_turn = false
	W.modulate = normal_color
	A.modulate = normal_color
	S.modulate = normal_color
	D.modulate = normal_color

func good_hit(value: int, time: float = 0.25) -> void:
	var sprite: Sprite2D = null
	var pitch: float
	match value:
		0:
			sprite = W
			pitch = W_pitch
		1:
			sprite = A
			pitch = A_pitch
		2:
			sprite = S
			pitch = S_pitch
		3: 
			sprite = D
			pitch = D_pitch
	sprite.modulate = good_color
	feedback_sound.pitch_scale = pitch
	feedback_sound.play(0.2)
	var timer := Timer.new()
	game_area.add_child(timer)
	timer.start(time)
	await timer.timeout
	sprite.modulate = normal_color
	timer.queue_free()

func bad_hit(value: int) -> void:
	var sprite: Sprite2D
	var pitch: float
	match value:
		0:
			sprite = W
			pitch = W_pitch
		1:
			sprite = A
			pitch = A_pitch
		2:
			sprite = S
			pitch = S_pitch
		3: 
			sprite = D
			pitch = D_pitch
	sprite.modulate = bad_color
	feedback_sound.pitch_scale = pitch / 2.17
	feedback_sound.play(0.2)
