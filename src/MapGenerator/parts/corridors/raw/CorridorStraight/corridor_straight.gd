extends Node3D

const distortion_strength = 0.06

func _ready() -> void:
	deform_mesh()

func deform_mesh():
	var mesh: ArrayMesh = $Cylinder.mesh
	var arrays = mesh.surface_get_arrays(0)
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var normals = arrays[Mesh.ARRAY_NORMAL]

	var offsets = {}

	var precision = 100000.0  # 5 decimal places

	for i in range(vertices.size()):
		var vertex = vertices[i]
		# Quantize the vertex to 5 decimals to group duplicates
		var key = Vector3(
			round(vertex.x * precision) / precision,
			round(vertex.y * precision) / precision,
			round(vertex.z * precision) / precision
		)

		if not offsets.has(key):
			var normal = normals[i]
			var offset_magnitude = randf_range(-distortion_strength, distortion_strength)
			offsets[key] = normal * offset_magnitude

		vertices[i] += offsets[key]

	arrays[Mesh.ARRAY_VERTEX] = vertices
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
