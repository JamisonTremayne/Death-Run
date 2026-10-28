class_name Bomb
extends Node2D

var direction: Vector2 = Vector2.DOWN
var velocity: float = 100.0
var acceleration: float = 10.0
signal bomb_hit

func _physics_process(delta: float) -> void:
	velocity += acceleration * delta
	position += direction * velocity * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	var arcademan: ArcadeMan = body as ArcadeMan
	if arcademan:
		bomb_hit.emit()
