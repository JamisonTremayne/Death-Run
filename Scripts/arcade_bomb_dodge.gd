extends ArcadeGame

const BOMB = preload("uid://c2ye0hwq8qbqn")
const SPAWN_Y := -120.0
const SPAWN_X := Vector2(-155, 155)
const BASE_BOMB_SPEED := 100.0
const BASE_BOMB_ACCELERATION := 10.0
@export var arcademan: ArcadeMan
@export var bomb_container: Node2D
var spawn_timer: Timer

func _ready() -> void:
	super._ready()
	spawn_timer = Timer.new()
	spawn_timer.autostart = false
	spawn_timer.one_shot = true
	game_area.add_child(spawn_timer)
	spawn_timer.timeout.connect(_spawn_bomb)

func start_game() -> void:
	arcademan.position = Vector2(0.0, 49.0)
	arcademan.velocity = Vector2.ZERO
	spawn_timer.start(1.0)

func finish_game() -> void:
	game_area.process_mode = Node.PROCESS_MODE_PAUSABLE
	_reset_game()
	super.finish_game()

func _spawn_bomb() -> void:
	var random_x := randf_range(SPAWN_X.x, SPAWN_X.y)
	var random_pos := Vector2(random_x, SPAWN_Y)
	var speed_variation := 10.0 * difficulty
	var speed_val := BASE_BOMB_SPEED + (12.0 * difficulty)
	var random_speed := randf_range(speed_val - (speed_variation / 2.0), speed_val + (speed_variation / 2.0))
	var random_acceleration := random_speed * (BASE_BOMB_ACCELERATION / BASE_BOMB_SPEED)
	var bomb: Bomb = BOMB.instantiate() as Bomb
	bomb.position = random_pos
	bomb.velocity = random_speed
	bomb.acceleration = random_acceleration
	bomb_container.add_child(bomb)
	bomb.bomb_hit.connect(die)
	
	var min_time := 1.0 / (1.5 ** difficulty)
	var max_time := 2.5 / (1.35 ** difficulty)
	var random_time := randf_range(min_time, max_time)
	spawn_timer.start(random_time)

func _reset_game() -> void:
	var bombs := bomb_container.get_children()
	for bomb in bombs:
		bomb.queue_free()
	spawn_timer.stop()
