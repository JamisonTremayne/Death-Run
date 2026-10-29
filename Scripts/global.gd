extends Node

enum DIFFICULTY { EASY, NORMAL, HARD }
var game_manager: GameManager
var difficulty: DIFFICULTY = DIFFICULTY.NORMAL

var arcade_messages: Array[String] = [
	"Keep going!",
	"Don't die!",
	"It can hear you die",
	"You got this!",
	"It only gets harder",
	"Prepare yourself!",
	"Hopefully you'll get lucky",
	"What's the point?",
	"Don't let it hear you"
]

func get_random_message() -> String:
	return arcade_messages.pick_random()
