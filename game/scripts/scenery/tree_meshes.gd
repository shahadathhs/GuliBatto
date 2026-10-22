class_name TreeMeshes
extends RefCounted
## Real 3D trees for the field, each one unit tall and scaled when placed: a palm (a leaning
## trunk and a crown of drooping fronds) and a bamboo clump (curved canes with leaf tufts). Built
## from a few rings and strips, lit and shadowed by the sun like everything else. Colours are
## tokens.

const TRUNK_RINGS := 9
const TRUNK_SIDES := 6
const FRONDS := 9
const FROND_SEGMENTS := 6
const CANES := 8


## A palm: surface 0 is the trunk, surface 1 the fronds.
static func palm(scheme: Palette.Scheme) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var trunk := SurfaceTool.new()
	trunk.begin(Mesh.PRIMITIVE_TRIANGLES)
	var lean := 0.08
	_sweep(trunk, Vector3.ZERO, Vector3(lean, 1.0, 0.02), 0.032, 0.02, TRUNK_RINGS)
	trunk.generate_normals()
	trunk.commit(mesh)
	mesh.surface_set_material(0, _material(&"earth_rim", scheme, 0.45, true))
	var top := Vector3(lean, 1.0, 0.02)
	var fronds := SurfaceTool.new()
	fronds.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in FRONDS:
		_frond(fronds, top, TAU * float(i) / FRONDS + 0.3, 0.46 + 0.06 * float(i % 3))
	fronds.generate_normals()
	fronds.commit(mesh)
	mesh.surface_set_material(1, _material(&"jade", scheme, 0.0, false))
	return mesh


## A clump of bamboo: surface 0 the canes, surface 1 the leaf tufts at their tips.
static func bamboo(scheme: Palette.Scheme) -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var canes := SurfaceTool.new()
	canes.begin(Mesh.PRIMITIVE_TRIANGLES)
	var leaves := SurfaceTool.new()
	leaves.begin(Mesh.PRIMITIVE_TRIANGLES)
	var rng := RandomNumberGenerator.new()
	rng.seed = 17
	for i in CANES:
		var a := TAU * float(i) / CANES + rng.randf() * 0.4
		var base := Vector3(cos(a), 0.0, sin(a)) * rng.randf_range(0.02, 0.07)
		var tip := Vector3(cos(a), 0.0, sin(a)) * rng.randf_range(0.13, 0.26)
		tip.y = rng.randf_range(0.8, 1.0)
		_sweep(canes, base, tip, 0.012, 0.006, 6)
		for k in 3:
			_frond(leaves, tip, a + float(k) * 2.1, 0.16)
	canes.generate_normals()
	canes.commit(mesh)
	mesh.surface_set_material(0, _material(&"jade", scheme, 0.3, true))
	leaves.generate_normals()
	leaves.commit(mesh)
	mesh.surface_set_material(1, _material(&"jade", scheme, 0.0, false))
	return mesh


## A tube from `from` to `to`, narrowing, bowed outward a little.
static func _sweep(
	st: SurfaceTool, from: Vector3, to: Vector3, r0: float, r1: float, rings: int
) -> void:
	var points: Array[Vector3] = []
	var bow := Vector3(to.x - from.x, 0.0, to.z - from.z)
	for i in rings:
		var t := float(i) / (rings - 1)
		points.append(from.lerp(to, t) + bow * sin(t * PI) * 0.12)
	for i in rings - 1:
		var radius_a := lerpf(r0, r1, float(i) / (rings - 1))
		var radius_b := lerpf(r0, r1, float(i + 1) / (rings - 1))
		for s in TRUNK_SIDES:
			var a0 := TAU * float(s) / TRUNK_SIDES
			var a1 := TAU * float(s + 1) / TRUNK_SIDES
			var p00 := points[i] + Vector3(cos(a0), 0.0, sin(a0)) * radius_a
			var p01 := points[i] + Vector3(cos(a1), 0.0, sin(a1)) * radius_a
			var p10 := points[i + 1] + Vector3(cos(a0), 0.0, sin(a0)) * radius_b
			var p11 := points[i + 1] + Vector3(cos(a1), 0.0, sin(a1)) * radius_b
			for v in [p00, p10, p01, p01, p10, p11]:
				st.add_vertex(v)


## A drooping leaf: a narrow strip that arcs out from `root` and bends down, seen from both sides.
static func _frond(st: SurfaceTool, root: Vector3, angle: float, length: float) -> void:
	var out := Vector3(cos(angle), 0.0, sin(angle))
	var side := Vector3(-out.z, 0.0, out.x)
	var previous_left := root
	var previous_right := root
	for i in range(1, FROND_SEGMENTS + 1):
		var t := float(i) / FROND_SEGMENTS
		var centre := (
			root
			+ out * length * t
			+ Vector3(0.0, length * (0.28 * sin(t * PI * 0.8) - 0.36 * t * t), 0.0)
		)
		var half := length * 0.11 * sin(minf(t * PI * 0.9 + 0.3, PI))
		var left := centre + side * half
		var right := centre - side * half
		for v in [previous_left, previous_right, left, left, previous_right, right]:
			st.add_vertex(v)
		for v in [previous_left, left, previous_right, left, right, previous_right]:
			st.add_vertex(v)
		previous_left = left
		previous_right = right


static func _material(
	token: StringName, scheme: Palette.Scheme, darken: float, rough: bool
) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Palette.get_color(token, scheme).darkened(darken)
	m.roughness = 1.0
	m.cull_mode = BaseMaterial3D.CULL_DISABLED if not rough else BaseMaterial3D.CULL_BACK
	return m
