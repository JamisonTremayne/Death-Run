@tool
extends StaticBody3D

@export var dimensions: Vector2 = Vector2.ONE:
	set(_dimensions):
		dimensions = _dimensions
		if Engine.is_editor_hint() and is_inside_tree():
			_update_dimensions()
@export var b_top: bool = false:
	set(_b):
		b_top = _b
		if Engine.is_editor_hint() and is_inside_tree():
			_update_top()

@export var mesh_instance: MeshInstance3D
@export var collision: CollisionShape3D

func _ready() -> void:
	_update_dimensions()
	_update_top()

func _update_dimensions() -> void:
	var mesh: PlaneMesh = mesh_instance.mesh.duplicate() as PlaneMesh
	mesh.size = dimensions
	var shape: BoxShape3D = collision.shape.duplicate() as BoxShape3D
	shape.size.x = dimensions.x
	shape.size.z = dimensions.y
	var mat: StandardMaterial3D = mesh_instance.material_override.duplicate() as StandardMaterial3D
	mat.uv1_scale.x = dimensions.x
	mat.uv1_scale.y = dimensions.y
	
	mesh_instance.mesh = mesh
	collision.shape = shape
	mesh_instance.material_override = mat

func _update_top() -> void:
	rotation.x = PI if b_top else 0.0
