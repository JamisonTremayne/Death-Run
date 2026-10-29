class_name Bomb
extends Node2D

@onready var lifetime_timer: Timer = $"Lifetime Timer"
var direction: Vector2 = Vector2.DOWN
var velocity: float = 100.0
var acceleration: float = 10.0
var lifetime: float = 100.0
var b_moves: bool = true
signal bomb_hit

func _ready() -> void:
	lifetime_timer.start(lifetime)

func _physics_process(delta: float) -> void:
	if b_moves:
		velocity += acceleration * delta
		position += direction * velocity * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	var arcademan: ArcadeMan = body as ArcadeMan
	if arcademan:
		bomb_hit.emit()

func _on_lifetime_timer_timeout() -> void:
	queue_free()
