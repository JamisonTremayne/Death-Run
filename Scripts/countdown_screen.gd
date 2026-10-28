class_name CountdownScreen
extends Control

@export var info_label: Label
@export var time_label: Label

func set_info_label(text: String) -> void:
	info_label.text = text

func set_time_label(value: int, include_seconds: bool = true) -> void:
	var text := str(value)
	if include_seconds:
		text = str(text, "s")
	time_label.text = text
