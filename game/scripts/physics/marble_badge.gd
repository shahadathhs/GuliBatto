class_name MarbleBadge
extends Node3D
## The mark on top of a marble (ring, dot, bar or triangle). It follows the marble's position but
## not its spin, so the mark stays readable while the marble rolls.

var marble: Marble


func _init(target: Marble, side: int, scheme: Palette.Scheme) -> void:
	marble = target
	var r := target.radius
	var mesh := MeshInstance3D.new()
	match SideStyle.mark(side):
		SideStyle.Mark.RING:
			var t := TorusMesh.new()
			t.inner_radius = r * 0.32
			t.outer_radius = r * 0.5
			mesh.mesh = t
		SideStyle.Mark.DOT:
			var c := CylinderMesh.new()
			c.top_radius = r * 0.24
			c.bottom_radius = r * 0.24
			c.height = 0.01
			mesh.mesh = c
		SideStyle.Mark.BAR:
			var b := BoxMesh.new()
			b.size = Vector3(r * 1.0, 0.01, r * 0.24)
			mesh.mesh = b
		SideStyle.Mark.TRIANGLE:
			var tri := CylinderMesh.new()
			tri.top_radius = r * 0.32
			tri.bottom_radius = r * 0.32
			tri.height = 0.01
			tri.radial_segments = 3
			mesh.mesh = tri
	var m := StandardMaterial3D.new()
	m.albedo_color = SideStyle.on_colour(side, scheme)
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material_override = m
	add_child(mesh)


func _process(_delta: float) -> void:
	if is_instance_valid(marble):
		global_position = marble.global_position + Vector3(0.0, marble.radius + 0.01, 0.0)
