class_name AimVisual
extends Node3D
## What the player sees while aiming, drawn flat on the ground: a solid arrow in the shot direction
## whose length grows with power, a dashed pull line back to the finger, and a ring under the
## marble whose turn it is. It draws only; it never decides anything.

const Y := 0.03
## A short arrow: it says which way, not how far, so a shot still has to be judged by eye.
const SHAFT_WIDTH := 0.05
const HEAD_LENGTH := 0.22
const HEAD_WIDTH := 0.2
const MIN_LENGTH := 0.35
const MAX_LENGTH := 1.0

var _mesh: ImmediateMesh = ImmediateMesh.new()
var _ring: MeshInstance3D
var _scheme: Palette.Scheme
var _marble_radius: float


func _init(
	scheme: Palette.Scheme = Palette.Scheme.LIGHT, marble_radius: float = Tuning.MARBLE_RADIUS
) -> void:
	_scheme = scheme
	_marble_radius = marble_radius
	var lines := MeshInstance3D.new()
	lines.mesh = _mesh
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.vertex_color_use_as_albedo = true
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	lines.material_override = m
	add_child(lines)
	_ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = _marble_radius * 1.5
	torus.outer_radius = _marble_radius * 1.75
	_ring.mesh = torus
	var rm := StandardMaterial3D.new()
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rm.albedo_color = Palette.get_color(&"ink", scheme)
	_ring.material_override = rm
	_ring.visible = false
	add_child(_ring)


func show_ring(ground_position: Vector2) -> void:
	_ring.visible = true
	_ring.position = Vector3(ground_position.x, 0.04, ground_position.y)


func hide_ring() -> void:
	_ring.visible = false


func clear() -> void:
	_mesh.clear_surfaces()


## from: the marble. direction: unit vector the shot will go. pointer: where the finger is, on the
## ground. power: 0..1.
func show_aim(from: Vector2, direction: Vector2, power: float, pointer: Vector2) -> void:
	_mesh.clear_surfaces()
	_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	var ink := Palette.get_color(&"ink", _scheme)
	var glaze := Palette.get_color(&"glaze", _scheme)
	_dashed(from, pointer, ink)
	var length := lerpf(MIN_LENGTH, MAX_LENGTH, power)
	var start := from + direction * (_marble_radius + 0.05)
	var neck := from + direction * length
	_quad(start, neck, SHAFT_WIDTH, glaze)
	var side := Vector2(-direction.y, direction.x)
	var tip := neck + direction * HEAD_LENGTH
	_tri(neck + side * HEAD_WIDTH / 2.0, neck - side * HEAD_WIDTH / 2.0, tip, glaze)
	_mesh.surface_end()


func _dashed(a: Vector2, b: Vector2, colour: Color) -> void:
	var total := a.distance_to(b)
	if total < 0.05:
		return
	var dir := (b - a) / total
	var d := _marble_radius + 0.1
	while d < total:
		var end := minf(d + 0.12, total)
		_quad(a + dir * d, a + dir * end, 0.035, colour)
		d += 0.22


func _quad(a: Vector2, b: Vector2, width: float, colour: Color) -> void:
	var dir := (b - a).normalized()
	var side := Vector2(-dir.y, dir.x) * width / 2.0
	_tri(a + side, a - side, b + side, colour)
	_tri(a - side, b - side, b + side, colour)


func _tri(a: Vector2, b: Vector2, c: Vector2, colour: Color) -> void:
	for p in [a, b, c]:
		_mesh.surface_set_color(colour)
		_mesh.surface_add_vertex(Vector3(p.x, Y, p.y))
