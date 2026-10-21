class_name Arena
extends Node3D
## A round arena built from a RuleProfile: ground with a smooth dish at each hole, a visible rim,
## a ring of thick wall segments so a marble cannot tunnel out, and the jalla line to stand
## behind. The ground shape and the ground mesh are both sampled from GroundField.

const WALL_SEGMENTS := 36
const RIM_SEGMENTS := 96
const RING_STEP := 0.05
const GROUND_THICKNESS := 0.5

var profile: RuleProfile
var scheme: Palette.Scheme = Palette.Scheme.LIGHT


func _init(
	rule_profile: RuleProfile = null, colour_scheme: Palette.Scheme = Palette.Scheme.LIGHT
) -> void:
	profile = rule_profile if rule_profile != null else RuleProfile.bench()
	scheme = colour_scheme


func _ready() -> void:
	_build_ground_collision()
	_build_ground_mesh()
	_build_rim()
	_build_walls()
	_build_jalla()


## The ground is plain boxes, plus a small heightmap patch around each hole for the dish. A box
## is cheap and exact; a heightmap is only used where the ground is not flat.
func _build_ground_collision() -> void:
	var half := Tuning.ARENA_RADIUS + Tuning.WALL_THICKNESS + 0.1
	var patches := GroundField.patch_rects(profile.holes, profile.dish_radius, Tuning.GROUND_CELL)
	for rect in GroundField.free_rects(half, patches):
		_add_ground_box(rect)
	for rect in patches:
		_add_ground_patch(rect)


func _add_ground_box(rect: Rect2) -> void:
	var body := StaticBody3D.new()
	body.physics_material_override = _material(Tuning.MARBLE_FRICTION, 0.0)
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	# A hair of overlap so no seam can catch a marble.
	box.size = Vector3(rect.size.x + 0.02, GROUND_THICKNESS, rect.size.y + 0.02)
	collider.shape = box
	body.add_child(collider)
	body.position = Vector3(rect.get_center().x, -GROUND_THICKNESS / 2.0, rect.get_center().y)
	add_child(body)


func _add_ground_patch(rect: Rect2) -> void:
	var shape := HeightMapShape3D.new()
	shape.map_width = GroundField.samples_along(rect.size.x, Tuning.GROUND_CELL)
	shape.map_depth = GroundField.samples_along(rect.size.y, Tuning.GROUND_CELL)
	shape.map_data = GroundField.sample_rect(
		rect, Tuning.GROUND_CELL, profile.holes, profile.dish_radius, profile.dish_depth
	)
	var body := StaticBody3D.new()
	body.physics_material_override = _material(Tuning.MARBLE_FRICTION, 0.0)
	var collider := CollisionShape3D.new()
	collider.shape = shape
	body.add_child(collider)
	body.position = Vector3(rect.get_center().x, 0.0, rect.get_center().y)
	body.scale = Vector3(Tuning.GROUND_CELL, 1.0, Tuning.GROUND_CELL)
	add_child(body)


## A disc mesh in rings, so the dish is smooth and the edge is round.
func _build_ground_mesh() -> void:
	var rings := int(Tuning.ARENA_RADIUS / RING_STEP)
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var earth := Palette.get_color(&"earth", scheme)
	var hole_colour := Palette.get_color(&"hole", scheme)
	for ring in rings:
		for seg in RIM_SEGMENTS:
			var a0 := TAU * float(seg) / RIM_SEGMENTS
			var a1 := TAU * float(seg + 1) / RIM_SEGMENTS
			var r0 := ring * RING_STEP
			var r1 := (ring + 1) * RING_STEP
			var quad := [
				Vector2.from_angle(a0) * r0,
				Vector2.from_angle(a1) * r0,
				Vector2.from_angle(a1) * r1,
				Vector2.from_angle(a0) * r1
			]
			for idx in [0, 2, 1, 0, 3, 2]:
				var p: Vector2 = quad[idx]
				var h := GroundField.height(
					p, profile.holes, profile.dish_radius, profile.dish_depth
				)
				var depth_t := clampf(-h / maxf(profile.dish_depth, 0.001), 0.0, 1.0)
				st.set_color(earth.lerp(hole_colour, pow(depth_t, 0.4)))
				st.add_vertex(Vector3(p.x, h, p.y))
	st.generate_normals()
	var mesh := MeshInstance3D.new()
	mesh.mesh = st.commit()
	var m := StandardMaterial3D.new()
	m.vertex_color_use_as_albedo = true
	m.roughness = 1.0
	mesh.material_override = m
	add_child(mesh)


## A low visible edge, so the player can see where the boundary is. The collision is the walls.
func _build_rim() -> void:
	var mesh := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = Tuning.ARENA_RADIUS - 0.05
	torus.outer_radius = Tuning.ARENA_RADIUS + 0.2
	mesh.mesh = torus
	mesh.material_override = _colour_material(&"earth_rim")
	mesh.position = Vector3(0.0, 0.04, 0.0)
	add_child(mesh)


func _build_walls() -> void:
	var middle_radius := Tuning.ARENA_RADIUS + Tuning.WALL_THICKNESS / 2.0
	var chord := 2.0 * middle_radius * tan(PI / WALL_SEGMENTS) + 0.1
	for i in WALL_SEGMENTS:
		var angle := TAU * float(i) / WALL_SEGMENTS
		var body := StaticBody3D.new()
		body.physics_material_override = _material(0.1, Tuning.WALL_BOUNCE)
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(Tuning.WALL_THICKNESS, Tuning.WALL_HEIGHT, chord)
		shape.shape = box
		body.add_child(shape)
		body.position = Vector3(
			cos(angle) * middle_radius, Tuning.WALL_HEIGHT / 2.0, sin(angle) * middle_radius
		)
		body.rotation.y = -angle
		add_child(body)


## The jalla: a dashed line across the arena at the profile's Z, drawn on the ground.
func _build_jalla() -> void:
	if profile.mode_id == &"bench":
		return
	var half_width := (
		sqrt(
			maxf(Tuning.ARENA_RADIUS * Tuning.ARENA_RADIUS - profile.jalla_z * profile.jalla_z, 0.0)
		)
		* 0.9
	)
	var dash := 0.28
	var gap := 0.18
	var x := -half_width
	while x < half_width:
		var mesh := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(minf(dash, half_width - x), 0.01, 0.06)
		mesh.mesh = box
		mesh.material_override = _colour_material(&"ink")
		mesh.position = Vector3(x + box.size.x / 2.0, 0.006, profile.jalla_z)
		add_child(mesh)
		x += dash + gap


func _material(friction: float, bounce: float) -> PhysicsMaterial:
	var m := PhysicsMaterial.new()
	m.friction = friction
	m.bounce = bounce
	return m


func _colour_material(token: StringName) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = Palette.get_color(token, scheme)
	m.roughness = 1.0
	return m
