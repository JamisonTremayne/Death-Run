class_name PathNetwork
extends Node3D

@export var starting_markers: Array[PathMarker] = []
@export var path_markers: Node3D
@export var room_markers: Node3D
var astar : AStar3D = AStar3D.new()
var marker_to_id: Dictionary[Marker3D, int] = {}
var id_to_marker: Dictionary[int, Marker3D] = {}

func _ready() -> void:
	build_network()

func add_marker(marker: Marker3D) -> void:
	var id := marker_to_id.size()
	marker_to_id[marker] = id
	id_to_marker[id] = marker
	astar.add_point(id, marker.global_position)

func connect_markers(a: Marker3D, b: Marker3D) -> void:
	var a_id: int = marker_to_id[a]
	var b_id: int = marker_to_id[b]
	if not astar.are_points_connected(a_id, b_id):
		astar.connect_points(a_id, b_id)

func get_random_starting_marker() -> PathMarker:
	var random_index: int = randi_range(0, starting_markers.size() - 1)
	return starting_markers[random_index]

func build_network() -> void:
	var path_marker_array := path_markers.get_children()
	var room_marker_array := room_markers.get_children()
	for marker in path_marker_array:
		#print("Pathmarkers: ", marker.name)
		var pathmarker: PathMarker = marker as PathMarker
		add_marker(pathmarker)
	for marker in room_marker_array:
		#print("Roommarkers: ", marker.name)
		var roommarker: RoomMarker = marker as RoomMarker
		add_marker(roommarker)
	for marker in path_marker_array:
		var pathmarker: PathMarker = marker as PathMarker
		for connection in pathmarker.connections:
			#print("Connecting pathmarkers: ", pathmarker.name, " to ", connection.name)
			connect_markers(pathmarker, connection)
		for room_connection in pathmarker.room_connections:
			#print("Connecting pathmarkers to roommarkers: ", pathmarker.name, " to ", room_connection.name)
			connect_markers(pathmarker, room_connection)
	for marker in room_marker_array:
		var roommarker: RoomMarker = marker as RoomMarker
		for path_connection in roommarker.path_connections:
			#print("Connecting roommarkers to pathmarkers: ", roommarker.name, " to ", path_connection.name)
			connect_markers(roommarker, path_connection)
		for room_connection in roommarker.room_connections:
			#print("Connecting roommarkers: ", roommarker.name, " to ", room_connection.name)
			connect_markers(roommarker, room_connection)
		for room_marker in roommarker.room_area.room_markers:
			if room_marker != roommarker:
				#print("Connecting inter roommarkers: ", roommarker.name, " to ", room_marker.name)
				connect_markers(roommarker, room_marker)

func get_room_at_position(pos: Vector3) -> RoomArea:
	var query := PhysicsPointQueryParameters3D.new()
	query.position = pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 8
	
	var space := get_world_3d().direct_space_state
	var results := space.intersect_point(query, 32)

	for result in results:
		var area := result["collider"] as RoomArea
		if area != null:
			return area
	return null

func get_path_length(path: PackedInt64Array) -> float:
	var length := 0.0
	for i in range(1, path.size()):
		var a: Vector3 = astar.get_point_position(path[i - 1])
		var b: Vector3 = astar.get_point_position(path[i])
		length += a.distance_to(b)
	return length

func find_best_room_entrance(start_marker: Marker3D, target_room: RoomArea, noise_position: Vector3) -> Array[Marker3D]:
	if !start_marker or !target_room:
		return []
	var start_id: int = marker_to_id[start_marker]
	var best_path := PackedInt64Array()
	var best_cost := INF
	
	for entrance in target_room.room_markers:
		var entrance_id: int = marker_to_id[entrance]
		var path := astar.get_id_path(start_id, entrance_id)
		if path.is_empty():
			continue
		var cost := get_path_length(path)
		cost += entrance.global_position.distance_to(noise_position)
		if cost < best_cost:
			best_cost = cost
			best_path = path
	
	var marker_path: Array[Marker3D] = []
	for id in best_path:
		marker_path.append(id_to_marker[id])
	return marker_path

func find_hallway_target(start_marker: Marker3D, target_marker: Marker3D) -> Array[Marker3D]:
	var path := astar.get_id_path(marker_to_id[start_marker], marker_to_id[target_marker])
	var marker_path: Array[Marker3D] = []
	for id in path:
		marker_path.append(id_to_marker[id])
	return marker_path

func get_closest_marker(point: Vector3) -> Marker3D:
	var closest_id := astar.get_closest_point(point)
	return id_to_marker[closest_id]
