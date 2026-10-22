class_name BaadMarker
extends Node3D
## A cross above the marble named as baad, the one a throw must not touch. Drawn flat and
## unshaded in a dark token so it reads on the bone-coloured stake in both themes, and it is a
## shape, not only a colour. It follows the marble and draws only; it decides nothing.

var _marble: Marble
var _lift: float = 0.4


func _init(scheme: Palette.Scheme, marble_radius: float) -> void:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Palette.get_color(&"hole", scheme)
	for turn in [PI / 4.0, -PI / 4.0]:
		var bar := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = Vector3(marble_radius * 2.6, 0.02, marble_radius * 0.5)
		bar.mesh = box
		bar.material_override = material
		bar.rotation.y = turn
		add_child(bar)
	_lift = marble_radius * 2.0 + 0.04
	visible = false


func show_on(marble: Marble) -> void:
	_marble = marble
	visible = marble != null
	_follow()


func clear() -> void:
	_marble = null
	visible = false


func _process(_delta: float) -> void:
	_follow()


func _follow() -> void:
	if _marble != null and is_instance_valid(_marble):
		global_position = _marble.global_position + Vector3(0.0, _lift, 0.0)
	elif visible:
		visible = false
