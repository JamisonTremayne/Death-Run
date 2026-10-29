class_name PathMarker
extends Marker3D

@export var connections: Array[PathMarker] = []
@export var room_connections: Array[RoomMarker] = []

func pick_random_connection(exclude: Array[Marker3D]) -> PathMarker:
	var valid_markers: Array[PathMarker] = connections.duplicate(false)
	for marker in connections:
		if marker in exclude:
			valid_markers.erase(marker)
	
	if valid_markers.size() == 0:
		return null
	
	var random_index := randi_range(0, valid_markers.size() - 1)
	return valid_markers[random_index]
