class_name GameUI
extends Control

@export var machine_label: Label
@export var escape_message: Label

func update_machine_label(found: int, needed: int = 7) -> void:
	machine_label.text = str(found, " / ", needed)

func show_escape_message() -> void:
	escape_message.visible = true
