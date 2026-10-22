class_name FieldObjects
extends Node3D
## What stands in the open field, as real meshes: clumps of palms and bamboo, low earth bunds
## between the plots, and tufts of grass near the play area. They give the ground depth and
## things to move past when the camera follows a marble, and they cast shadows.

const RING_NEAR := 36.0
const RING_FAR := 92.0
const CLUMPS := 9
const TUFTS := 260


func _init(profile: RuleProfile, scheme: Palette.Scheme) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 29
	var far := profile.arena_size.y if profile.arena_rect else profile.arena_size.x
	_add_trees(scheme, rng)
	_add_bunds(far, scheme)
	_add_tufts(profile, scheme, rng)


func _add_trees(scheme: Palette.Scheme, rng: RandomNumberGenerator) -> void:
	var palms: Array[Transform3D] = []
	var bamboo: Array[Transform3D] = []
	for c in CLUMPS:
		var angle := TAU * float(c) / CLUMPS + rng.randf_range(-0.2, 0.2)
		var centre := Vector2.from_angle(angle) * rng.randf_range(RING_NEAR, RING_FAR)
		for n in rng.randi_range(2, 5):
			var at := centre + Vector2(rng.randf_range(-7.0, 7.0), rng.randf_range(-7.0, 7.0))
			var height := rng.randf_range(9.0, 13.0)
			var basis := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * height)
			palms.append(Transform3D(basis, Vector3(at.x, 0.0, at.y)))
		var thicket := centre + Vector2.from_angle(angle + 1.0) * rng.randf_range(6.0, 12.0)
		var tall := rng.randf_range(7.0, 10.0)
		var turn := Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * tall)
		bamboo.append(Transform3D(turn, Vector3(thicket.x, 0.0, thicket.y)))
	add_child(_instances(TreeMeshes.palm(scheme), palms))
	add_child(_instances(TreeMeshes.bamboo(scheme), bamboo))


## Low earth walls between the plots: across the field behind the play area and along its sides.
func _add_bunds(far: float, scheme: Palette.Scheme) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Palette.get_color(&"earth_rim", scheme)
	material.roughness = 1.0
	DirtTexture.apply(material, true)
	var green := StandardMaterial3D.new()
	green.albedo_color = Palette.get_color(&"jade", scheme).darkened(0.3)
	green.roughness = 1.0
	for spec in [
		[Vector3(0.0, 0.0, -(far + 52.0)), Vector3(260.0, 0.7, 3.4)],
		[Vector3(0.0, 0.0, far + 60.0), Vector3(260.0, 0.6, 3.0)],
		[Vector3(-(far + 34.0), 0.0, 0.0), Vector3(3.2, 0.6, 260.0)],
		[Vector3(far + 46.0, 0.0, 0.0), Vector3(3.2, 0.7, 260.0)],
	]:
		var at: Vector3 = spec[0]
		var size: Vector3 = spec[1]
		var mound := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = size
		mound.mesh = box
		mound.position = at + Vector3(0.0, size.y / 2.0 - 0.05, 0.0)
		mound.material_override = material
		add_child(mound)
		var grass := MeshInstance3D.new()
		var strip := BoxMesh.new()
		strip.size = Vector3(
			size.x * 0.98 if size.x > size.z else size.x * 0.5,
			0.12,
			size.z * 0.5 if size.x > size.z else size.z * 0.98
		)
		grass.mesh = strip
		grass.position = at + Vector3(0.0, size.y - 0.02, 0.0)
		grass.material_override = green
		add_child(grass)


## Small grass tufts scattered from just outside the play area outward, thicker near it.
func _add_tufts(profile: RuleProfile, scheme: Palette.Scheme, rng: RandomNumberGenerator) -> void:
	var half := (
		profile.arena_size
		if profile.arena_rect
		else Vector2(profile.arena_size.x, profile.arena_size.x)
	)
	var tufts: Array[Transform3D] = []
	var guard := 0
	while tufts.size() < TUFTS and guard < TUFTS * 8:
		guard += 1
		var spread := rng.randf_range(0.6, 1.0)
		var p := (
			Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0))
			* (half + Vector2.ONE * 26.0 * spread * spread)
		)
		if absf(p.x) < half.x + 0.7 and absf(p.y) < half.y + 0.7:
			continue
		# Not behind the line, where the camera stands: a tuft there would fill the screen.
		if p.y > half.y - 0.5 and absf(p.x) < 9.0:
			continue
		var s := rng.randf_range(0.7, 1.6)
		tufts.append(
			Transform3D(
				Basis(Vector3.UP, rng.randf() * TAU).scaled(Vector3.ONE * s), Vector3(p.x, 0.0, p.y)
			)
		)
	var blade := CylinderMesh.new()
	blade.top_radius = 0.0
	blade.bottom_radius = 0.07
	blade.height = 0.28
	blade.radial_segments = 4
	blade.rings = 1
	var material := StandardMaterial3D.new()
	material.albedo_color = Palette.get_color(&"jade", scheme).darkened(0.2)
	material.roughness = 1.0
	blade.material = material
	add_child(_instances(blade, tufts))


func _instances(mesh: Mesh, transforms: Array[Transform3D]) -> MultiMeshInstance3D:
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.mesh = mesh
	multi.instance_count = transforms.size()
	for i in transforms.size():
		multi.set_instance_transform(i, transforms[i])
	var node := MultiMeshInstance3D.new()
	node.multimesh = multi
	return node
