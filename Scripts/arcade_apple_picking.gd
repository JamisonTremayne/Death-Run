extends ArcadeGame

const BOMB = preload("uid://c2ye0hwq8qbqn")
const APPLE_PICKUP = preload("uid://cnkceykar1u38")
const SPAWN_Y := Vector2(-75, 75)
const SPAWN_X := Vector2(-145, 145)
@export var arcademan: ArcadeMan
@export var pickup_container: Node2D
@export var fruit_label: Label
@export var pickup_sound: AudioStreamPlayer
var spawn_timer: Timer
var fruit_required: int = 5
var apple_count: int = 0

func _ready() -> void:
	super._ready()
	spawn_timer = Timer.new()
	spawn_timer.autostart = false
	spawn_timer.one_shot = true
	game_area.add_child(spawn_timer)
	spawn_timer.timeout.connect(_spawn_fruit_or_bomb)

func start_game() -> void:
	fruit_required = roundi(difficulty * 1.5)
	fruit_label.visible = true
	arcademan.speed_mult = 1.0 + (0.05 * difficulty)
	_update_fruit_label()
	arcademan.position = Vector2(0.0, 0.0)
	arcademan.velocity = Vector2.ZERO
	spawn_timer.start(0.5)

func finish_game() -> void:
	_reset_game()
	super.finish_game()

func _reset_game() -> void:
	fruit_label.visible = false
	apple_count = 0
	var items := pickup_container.get_children()
	for item in items:
		item.queue_free()
	spawn_timer.stop()

func _increase_apple_count() -> void:
	apple_count += 1
	_update_fruit_label()
	pickup_sound.play()
	if apple_count >= fruit_required:
		finish_game()

func _update_fruit_label() -> void:
	fruit_label.text = str(apple_count, "/", fruit_required)

func _spawn_fruit_or_bomb() -> void:
	var apple_chance := 0.8 - (difficulty * 0.01)
	var is_apple := randf() < apple_chance
	var spawnable: Node2D
	if is_apple:
		spawnable = APPLE_PICKUP.instantiate()
		var apple: Apple = spawnable as Apple
		apple.apple_picked_up.connect(_increase_apple_count)
	else:
		spawnable = BOMB.instantiate()
		var bomb: Bomb = spawnable as Bomb
		bomb.b_moves = false
		bomb.bomb_hit.connect(die)
	spawnable.lifetime = 3.0 - (difficulty * 0.1)
	pickup_container.add_child(spawnable)
	var random_x := randf_range(SPAWN_X.x, SPAWN_X.y)
	var random_y := randf_range(SPAWN_Y.x, SPAWN_Y.y)
	var random_pos := Vector2(random_x, random_y)
	var dist := random_pos.distance_to(arcademan.position)
	if dist < 75.0:
		var dir := arcademan.position.direction_to(random_pos)
		random_pos += dist * dir * randf_range(1.0, 1.5)
	spawnable.position = random_pos
	var spawntime := randf_range(2.0, 4.0) * (1.0 / difficulty)
	spawn_timer.start(spawntime)
