@tool
extends StaticBody3D

@export var dimensions: Vector3 = Vector3.ONE:
	set(_dimensions):
		dimensions = _dimensions
		if Engine.is_editor_hint() and is_inside_tree():
			_update_dimensions()

@export var mesh_instance: MeshInstance3D
@export var collision: CollisionShape3D

func _ready() -> void:
	_update_dimensions()

func _update_dimensions() -> void:
	var mesh: BoxMesh = mesh_instance.mesh.duplicate() as BoxMesh
	mesh.size = dimensions
	var shape: BoxShape3D = collision.shape.duplicate() as BoxShape3D
	shape.size = dimensions
	var mat: StandardMaterial3D = mesh_instance.material_override.duplicate() as StandardMaterial3D
	mat.uv1_scale = dimensions * 2
	
	mesh_instance.mesh = mesh
	collision.shape = shape
	mesh_instance.material_override = mat
