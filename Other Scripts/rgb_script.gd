extends Node

func shift_material(r, g, b, object : Object):
	var material : SpatialMaterial = SpatialMaterial.new()
	object.set_surface_material(0,material)#$MeshInstance error, not recognized
	material.albedo_color = Color(r,g,b)
