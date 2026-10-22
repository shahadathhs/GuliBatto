class_name HoleWear
extends Node3D
## Crumbs of earth round the rim of each hole, where the edge has worn and fallen in.

const CRUMBS := 36


func _init(profile: RuleProfile, scheme: Palette.Scheme) -> void:
	if profile.holes.is_empty():
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	var crumb := SphereMesh.new()
	crumb.radius = profile.marble_radius * 0.22
	crumb.height = crumb.radius * 1.2
	multi.mesh = crumb
	multi.instance_count = CRUMBS * profile.holes.size()
	var n := 0
	for hole in profile.holes:
		for i in CRUMBS:
			var a := rng.randf() * TAU
			var r := profile.dish_radius * rng.randf_range(0.9, 1.3)
			var at := Vector3(hole.x + cos(a) * r, 0.004, hole.y + sin(a) * r)
			var scale := rng.randf_range(0.6, 1.5)
			multi.set_instance_transform(
				n, Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * scale), at)
			)
			n += 1
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = multi
	var material := StandardMaterial3D.new()
	material.albedo_color = Palette.get_color(&"earth_rim", scheme)
	material.roughness = 1.0
	instance.material_override = material
	add_child(instance)
