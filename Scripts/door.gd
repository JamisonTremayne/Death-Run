class_name Door
extends Interactable

@export var door_open_timer: Timer
@export var open_sound: AudioStream
@export var close_sound: AudioStream
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var audio: AudioStreamPlayer3D = $Audio
var b_open : bool = false

func interact() -> void:
	#print("Opening door")
	if b_open: 
		return
		
	rotate_y(PI / 2)
	collision.disabled = true
	b_open = true
	door_open_timer.start()
	audio.stream = open_sound
	audio.play()
	Global.game_manager.make_noise(global_position, 25.0)

func _on_door_open_timer_timeout() -> void:
	rotate_y(-PI / 2)
	collision.disabled = false
	b_open = false
	audio.stop()
	audio.stream = close_sound
	audio.play()
