class_name Field
extends Node3D
## The open field round the play area, seen from a crouch: dry ground with rows of stubble to the
## horizon, a low earth bund across the far side, and a far hazy line of palms and bamboo. Only
## an open field: no buildings, people, animals, patterns or writing. All colours are tokens.

const GROUND_SIZE := 900.0
const TREELINE_RADIUS := 70.0
const TREELINE_HEIGHT := 16.0
const BUND_GAP := 22.0
const TREE_WIDTH := 2048
const TREE_HEIGHT := 128

static var _trees: ImageTexture


func _init(profile: RuleProfile, scheme: Palette.Scheme) -> void:
	_add_ground(profile, scheme)
	_add_bund(profile, scheme)
	_add_treeline(scheme)


## The field's ground. It must not cover a hole: a deep pit (Batto's) goes far below the floor,
## so a rectangular board gets a frame of ground round it, and a round one a plane just under its
## shallow dish.
func _add_ground(profile: RuleProfile, scheme: Palette.Scheme) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Palette.get_color(&"earth", scheme)
	material.roughness = 1.0
	DirtTexture.apply(material, true)
	var everywhere := Rect2(-GROUND_SIZE / 2.0, -GROUND_SIZE / 2.0, GROUND_SIZE, GROUND_SIZE)
	if profile.arena_rect:
		var board := Rect2(-profile.arena_size, profile.arena_size * 2.0)
		# The board's own rim is 0.25 m wide; the frame begins just inside its outer edge.
		var cover: Array[Rect2] = [board.grow(0.22)]
		for rect in GroundField.free_rects(everywhere, cover):
			_add_plane(rect, -0.01, material)
	else:
		_add_plane(everywhere, -(profile.dish_depth + 0.01), material)


func _add_plane(rect: Rect2, y: float, material: StandardMaterial3D) -> void:
	var plane := PlaneMesh.new()
	plane.size = rect.size
	var mesh := MeshInstance3D.new()
	mesh.mesh = plane
	mesh.position = Vector3(rect.get_center().x, y, rect.get_center().y)
	mesh.material_override = material
	add_child(mesh)


## A low earth wall across the far side of the field, with a fringe of grass along its top.
func _add_bund(profile: RuleProfile, scheme: Palette.Scheme) -> void:
	var far := profile.arena_size.y if profile.arena_rect else profile.arena_size.x
	var z := -(far + BUND_GAP)
	var wall := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(GROUND_SIZE, 1.3, 5.0)
	wall.mesh = box
	wall.position = Vector3(0.0, 0.5, z)
	var material := StandardMaterial3D.new()
	material.albedo_color = Palette.get_color(&"earth_rim", scheme)
	material.roughness = 1.0
	DirtTexture.apply(material, true)
	wall.material_override = material
	add_child(wall)
	var grass := MeshInstance3D.new()
	var tuft := BoxMesh.new()
	tuft.size = Vector3(GROUND_SIZE, 0.22, 1.6)
	grass.mesh = tuft
	grass.position = Vector3(0.0, 1.26, z)
	var green := StandardMaterial3D.new()
	green.albedo_color = Palette.get_color(&"jade", scheme).darkened(0.25)
	green.roughness = 1.0
	grass.material_override = green
	add_child(grass)


func _add_treeline(scheme: Palette.Scheme) -> void:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = TREELINE_RADIUS
	cylinder.bottom_radius = TREELINE_RADIUS
	cylinder.height = TREELINE_HEIGHT
	cylinder.radial_segments = 64
	cylinder.cap_top = false
	cylinder.cap_bottom = false
	var mesh := MeshInstance3D.new()
	mesh.mesh = cylinder
	mesh.position = Vector3(0.0, TREELINE_HEIGHT / 2.0, 0.0)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_texture = trees()
	material.albedo_color = Palette.get_color(&"jade", scheme)
	material.cull_mode = BaseMaterial3D.CULL_FRONT
	# The haze of the sky comes from the silhouettes' own softness, not the fog.
	material.disable_fog = true
	# Nothing wraps round the top or bottom edge of the picture.
	material.texture_repeat = false
	mesh.material_override = material
	add_child(mesh)


## The silhouettes, as white with an alpha, tinted by the material: a hazy low band, clumps of
## bamboo and a few palms.
static func trees() -> ImageTexture:
	if _trees == null:
		_trees = ImageTexture.create_from_image(_paint_trees())
	return _trees


static func _paint_trees() -> Image:
	var alpha: Array[float] = []
	alpha.resize(TREE_WIDTH * TREE_HEIGHT)
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var hills := FastNoiseLite.new()
	hills.frequency = 0.02
	hills.seed = 9
	for x in TREE_WIDTH:
		var h := int(12.0 + 10.0 * (hills.get_noise_1d(x) + 1.0))
		for y in range(TREE_HEIGHT - h, TREE_HEIGHT):
			_stamp(alpha, x, y, 0.3)
	for n in 22:
		var cx := rng.randi_range(0, TREE_WIDTH - 1)
		var half := rng.randi_range(20, 46)
		var top := rng.randf_range(24.0, 44.0)
		for dx in range(-half, half + 1):
			var t := 1.0 - pow(absf(float(dx)) / half, 2.0)
			var h := int(top * pow(maxf(t, 0.0), 0.6) + rng.randf_range(-3.0, 3.0))
			for y in range(TREE_HEIGHT - h, TREE_HEIGHT):
				_stamp(alpha, cx + dx, y, 0.48)
	for n in 11:
		_palm(alpha, rng.randi_range(0, TREE_WIDTH - 1), rng)
	var image := Image.create(TREE_WIDTH, TREE_HEIGHT, false, Image.FORMAT_RGBA8)
	for y in TREE_HEIGHT:
		for x in TREE_WIDTH:
			var pixel := Palette.get_color(&"highlight", Palette.Scheme.LIGHT)
			pixel.a = alpha[y * TREE_WIDTH + x]
			image.set_pixel(x, y, pixel)
	return image


static func _stamp(alpha: Array[float], x: int, y: int, a: float) -> void:
	if y < 0 or y >= TREE_HEIGHT:
		return
	var i := y * TREE_WIDTH + posmod(x, TREE_WIDTH)
	alpha[i] = maxf(alpha[i], a)


static func _disc(alpha: Array[float], cx: float, cy: float, r: float, a: float) -> void:
	for dy in range(int(-r) - 1, int(r) + 2):
		for dx in range(int(-r) - 1, int(r) + 2):
			if Vector2(dx, dy).length() <= r:
				_stamp(alpha, int(cx) + dx, int(cy) + dy, a)


## A palm: a leaning trunk and a crown of drooping fronds.
static func _palm(alpha: Array[float], x: int, rng: RandomNumberGenerator) -> void:
	var top := Vector2(x + rng.randf_range(-6.0, 6.0), TREE_HEIGHT - rng.randf_range(78.0, 104.0))
	var foot := Vector2(x, TREE_HEIGHT)
	for i in 60:
		var t := float(i) / 59.0
		var p := foot.lerp(top, t) + Vector2(sin(t * PI) * 3.0, 0.0)
		_disc(alpha, p.x, p.y, 2.2, 0.62)
	for frond in 7:
		var side := -1.0 + 2.0 * float(frond) / 6.0
		for i in 26:
			var t := float(i) / 25.0
			var p := (
				top
				+ Vector2(side * 26.0 * t, -9.0 * sin(t * PI) + 11.0 * t * t * (0.4 + absf(side)))
			)
			_disc(alpha, p.x, p.y, 2.0 - 0.8 * t, 0.62)
