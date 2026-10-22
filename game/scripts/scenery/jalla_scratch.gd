class_name JallaScratch
extends Node3D
## The jalla: a line scratched into the dirt with a stick. Uneven in width and wander, with a ridge
## of loose earth along one side, instead of a ruled dashed line. Drawn on the ground at the
## profile's jalla Z.

const STEP := 0.14
const WIDTH := 0.07
const LIFT := 0.004
const RIDGE_WIDTH := 0.03


func _init(profile: RuleProfile, scheme: Palette.Scheme) -> void:
	if profile.mode_id == &"bench":
		return
	var radius := profile.arena_size.x
	var half := (
		radius * 0.9
		if profile.arena_rect
		else sqrt(maxf(radius * radius - profile.jalla_z * profile.jalla_z, 0.0)) * 0.9
	)
	var rng := RandomNumberGenerator.new()
	rng.seed = 23
	var groove := Palette.get_color(&"hole", scheme)
	groove.a = 0.7
	add_child(_ribbon(half, profile.jalla_z, WIDTH, 0.0, groove, rng))
	var ridge := Palette.get_color(&"bone", scheme)
	ridge.a = 0.45
	add_child(_ribbon(half, profile.jalla_z, RIDGE_WIDTH, -0.07, ridge, rng))


func _ribbon(
	half: float, z: float, width: float, side: float, colour: Color, rng: RandomNumberGenerator
) -> MeshInstance3D:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	var wander := 0.0
	var x := -half
	while x <= half:
		wander = clampf(wander + rng.randf_range(-0.012, 0.012), -0.03, 0.03)
		var w := width * rng.randf_range(0.7, 1.25)
		st.add_vertex(Vector3(x, LIFT, z + side + wander - w / 2.0))
		st.add_vertex(Vector3(x, LIFT, z + side + wander + w / 2.0))
		x += STEP
	var mesh := MeshInstance3D.new()
	mesh.mesh = st.commit()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = colour
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = material
	return mesh
