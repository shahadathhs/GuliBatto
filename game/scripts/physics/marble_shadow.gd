class_name MarbleShadow
extends Node3D
## A soft shadow under a marble, so it sits on the ground instead of floating above it. It follows
## the marble's position, not its spin, and lies just above the ground under it.

const LIFT := 0.004
## The shadow is a little longer than the marble is wide, and falls away from the light.
const SPREAD := 1.7
const OFFSET := Vector2(0.28, 0.2)

static var _mask: ImageTexture

var marble: Marble


func _init(target: Marble, scheme: Palette.Scheme) -> void:
	marble = target
	var quad := QuadMesh.new()
	var side := target.radius * 2.0 * SPREAD
	quad.size = Vector2(side, side)
	var mesh := MeshInstance3D.new()
	mesh.mesh = quad
	mesh.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_texture = mask()
	material.albedo_color = Palette.get_color(&"shadow", scheme)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = material
	add_child(mesh)


func _process(_delta: float) -> void:
	if is_instance_valid(marble):
		var p := marble.global_position
		global_position = Vector3(
			p.x + OFFSET.x * marble.radius,
			p.y - marble.radius + LIFT,
			p.z + OFFSET.y * marble.radius
		)


## A round mask that is solid in the middle and fades to nothing at the edge.
static func mask() -> ImageTexture:
	if _mask == null:
		var size := 64
		var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
		for y in size:
			for x in size:
				var d := Vector2(x + 0.5, y + 0.5).distance_to(Vector2(size, size) / 2.0)
				var t := clampf(1.0 - d / (size / 2.0), 0.0, 1.0)
				var pixel := Palette.get_color(&"highlight", Palette.Scheme.LIGHT)
				pixel.a = smoothstep(0.0, 0.7, t)
				image.set_pixel(x, y, pixel)
		_mask = ImageTexture.create_from_image(image)
	return _mask
