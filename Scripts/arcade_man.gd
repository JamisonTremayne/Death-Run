class_name ArcadeMan
extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -280.0
@export var sprite: AnimatedSprite2D
@export var run_audio: AudioStreamPlayer
@export var jump_audio: AudioStreamPlayer
@export var flying: bool = false
var speed_mult: float = 1.0

func _physics_process(delta: float) -> void:
	if !flying:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			if jump_audio:
				jump_audio.play()

		# Get the input direction and handle the movement/deceleration.
		var direction := Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * SPEED * speed_mult
			sprite.animation = "move"
			if run_audio and !run_audio.playing:
				run_audio.play()
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			sprite.animation = "idle"
			if run_audio:
				run_audio.stop()
		if direction > 0:
			sprite.flip_h = false
		elif direction < 0:
			sprite.flip_h = true
	else:
		var direction := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if direction:
			velocity = direction * SPEED * speed_mult
			sprite.animation = "move"
			if run_audio and !run_audio.playing:
				run_audio.play()
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.y = move_toward(velocity.y, 0, SPEED)
			sprite.animation = "idle"
			if run_audio:
				run_audio.stop()
		if direction.x > 0:
			sprite.flip_h = false
		elif direction.x < 0:
			sprite.flip_h = true
	
	move_and_slide()
