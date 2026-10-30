extends AudioStreamPlayer

const DREAD_SINKSIN = preload("uid://djj8pnw1wvogb")
const IT_APPROACHES = preload("uid://dpktekprfivmy")
const YOUCANFEELIT = preload("uid://cwciotthljcwp")

var timer: Timer
var possible_sounds: Array[AudioStream] = [DREAD_SINKSIN, IT_APPROACHES, YOUCANFEELIT]

func _ready() -> void:
	timer = Timer.new()
	add_child(timer)
	timer.autostart = false
	timer.one_shot = true
	timer.start(10.0)
	timer.timeout.connect(play_random_noise)

func play_random_noise() -> void:
	var random_sound: AudioStream = possible_sounds.pick_random() as AudioStream
	stream = random_sound
	play()
	timer.start(randf_range(18.0, 60.0))
