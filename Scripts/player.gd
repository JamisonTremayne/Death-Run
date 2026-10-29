class_name Player
extends CharacterBody3D

const SPEED := 3.0
const SPRINT_SPEED := 5.0
const SPRINT_STAMINA_DRAIN := 20.0
const MAX_STAMINA := 100.0
const STAMINA_REGEN_DELAY := 2.0
const STAMINA_REGEN := 10.0
const JUMP_VELOCITY := 4.5
const SENSITIVITY := 0.008
const CAMERA_PITCH_MAX := 75.0
const CAMERA_PITCH_MIN := -75.0
const CAMERA_DEFAULT_POS := Vector3(0.0, 1.646, 0.0)

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var stamina_bar: ProgressBar = $"Player UI/Stamina Bar"
@onready var interaction_indicators: Control = $"Player UI/Interaction Indicators"
@onready var footsteps_audio: AudioStreamPlayer3D = $"Footsteps Audio"
var current_interactable : Interactable = null
var stamina_regen_timer : Timer
var current_stamina : float = MAX_STAMINA
var b_sprinting : bool = false
var b_regening_stamina : bool = false

var b_godmode: bool = false
var b_immortal: bool = false
var b_canmove: bool = true
var b_canlook: bool = true

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	stamina_regen_timer = Timer.new()
	add_child(stamina_regen_timer)
	stamina_regen_timer.wait_time = STAMINA_REGEN_DELAY
	stamina_regen_timer.one_shot = true
	stamina_regen_timer.autostart = false
	stamina_regen_timer.timeout.connect(start_regen)
	
	stamina_bar.max_value = MAX_STAMINA
	stamina_bar.value = current_stamina

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and b_canlook:
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotation.x = clampf(camera.rotation.x, deg_to_rad(CAMERA_PITCH_MIN), deg_to_rad(CAMERA_PITCH_MAX))
	elif event.is_action_pressed("sprint") and b_canmove:
		try_start_sprint()
	elif event.is_action_released("sprint"):
		stop_sprint()
	elif event.is_action_pressed("interact") and b_canmove:
		#print("interacting: ", current_interactable)
		if current_interactable:
			current_interactable.interact()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed := SPRINT_SPEED if b_sprinting else SPEED
	if b_godmode:
		speed *= 10.0
		var flight_dir := Input.get_axis("godmode_down", "godmode_up")
		velocity.y = flight_dir * speed
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if !footsteps_audio.playing:
			footsteps_audio.play()
		if b_sprinting:
			Global.game_manager.make_noise(global_position, 12.5)
		else:
			Global.game_manager.make_noise(global_position, 2.0)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		footsteps_audio.stop()
	
	if b_sprinting:
		current_stamina -= SPRINT_STAMINA_DRAIN * delta
		stamina_bar.value = current_stamina
		if current_stamina <= 0:
			stop_sprint()
	
	if b_regening_stamina:
		current_stamina = clampf(current_stamina + (STAMINA_REGEN * delta), 0.0, MAX_STAMINA)
		stamina_bar.value = current_stamina
		if current_stamina == MAX_STAMINA:
			b_regening_stamina = false
	
	if b_canmove:
		move_and_slide()

func try_start_sprint() -> void:
	if current_stamina > 0:
		b_sprinting = true
		b_regening_stamina = false
		stamina_regen_timer.stop()

func stop_sprint() -> void:
	b_sprinting = false
	stamina_regen_timer.start()

func start_regen() -> void:
	b_regening_stamina = true

func _on_interaction_area_body_entered(body: Node3D) -> void:
	var interactable: Interactable = body as Interactable
	#print("Found interactable: ", interactable)
	if !interactable:
		return
	current_interactable = interactable
	_update_indicator()

func _on_interaction_area_body_exited(body: Node3D) -> void:
	var interactable: Interactable = body as Interactable
	if interactable == current_interactable:
		current_interactable = null
	_update_indicator()

func _update_indicator() -> void:
	if current_interactable:
		interaction_indicators.visible = true
	else:
		interaction_indicators.visible = false
