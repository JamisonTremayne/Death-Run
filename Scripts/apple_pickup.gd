class_name Apple
extends Node2D

@onready var lifetime_timer: Timer = $"Lifetime Timer"
var lifetime: float = 100.0
signal apple_picked_up

func _ready() -> void:
	lifetime_timer.start(lifetime)

func _on_area_2d_body_entered(body: Node2D) -> void:
	var arcademan: ArcadeMan = body as ArcadeMan
	if arcademan:
		apple_picked_up.emit()
		queue_free()

func _on_lifetime_timer_timeout() -> void:
	queue_free()
