class_name TimerDisplay
extends Control

@export var time_label: Label

func set_time_label(value: int, include_seconds: bool = true) -> void:
	var text := str(value)
	if include_seconds:
		text = str(text, "s")
	time_label.text = text
