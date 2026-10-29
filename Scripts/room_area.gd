@tool
class_name RoomArea
extends Area3D

@export var room_markers: Array[RoomMarker] = []
@export var area_size: Vector3 = Vector3(13.0, 12.0, 10.0):
	set(_area):
		area_size = _area
		if Engine.is_editor_hint():
			_update_area_size()
@export var collision: CollisionShape3D

func _ready() -> void:
	_update_area_size()

func _update_area_size() -> void:
	if collision:
		var shape: BoxShape3D = collision.shape.duplicate() as BoxShape3D
		shape.size = area_size
		collision.shape = shape
