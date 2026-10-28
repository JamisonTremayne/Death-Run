class_name GameUI
extends Control

@export var machine_label: Label

func update_machine_label(found: int, needed: int = 7) -> void:
	machine_label.text = str(found, " / ", needed)
