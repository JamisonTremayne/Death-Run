class_name PathNetwork
extends Node3D

@export var starting_markers: Array[PathMarker] = []

func get_random_starting_marker() -> PathMarker:
	var random_index: int = randi_range(0, starting_markers.size() - 1)
	return starting_markers[random_index]
