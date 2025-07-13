extends Item


func _on_used(body: Variant) -> void:
	print(body.name + " used item: " + self.name)

	var mesh_instance := $MeshInstance3D
	var material: Material = mesh_instance.get_surface_override_material(0)

	if material == null:
		var base_material: Material = mesh_instance.mesh.surface_get_material(0)
		material = base_material.duplicate()
		mesh_instance.set_surface_override_material(0, material)

	if material is not StandardMaterial3D:
		printerr("StandardMaterial3D expected to change color in this demo")
	
	var std_mat := material as StandardMaterial3D
	var current_color := std_mat.albedo_color

	var hsv = Vector3(current_color.h, current_color.s, current_color.v)
	hsv.x = (hsv.x + 0.1)
	if (hsv.x > 1.0):
		hsv.x = 0
	std_mat.albedo_color = Color.from_hsv(hsv.x, hsv.y, hsv.z)
