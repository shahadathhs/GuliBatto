class_name DirtTexture
extends RefCounted
## Grain for the ground, painted once in greys and laid over the earth colour of the ground mesh,
## so the earth tokens stay the only colours. `ground` is bare dirt (grain, pebbles, scratches);
## `field` is the same with rows of stubble, for the open field round the play area.

const SIZE := 256
## One tile covers this many metres, in world space.
const TILE_METRES := 2.0
const ROW_METRES := 0.25

static var _ground: ImageTexture
static var _field: ImageTexture


static func ground() -> ImageTexture:
	if _ground == null:
		_ground = ImageTexture.create_from_image(_paint(false))
	return _ground


static func field() -> ImageTexture:
	if _field == null:
		_field = ImageTexture.create_from_image(_paint(true))
	return _field


## Lays the grain over a ground material in world space, so it does not stretch with the mesh.
static func apply(material: StandardMaterial3D, rows: bool = false) -> void:
	material.albedo_texture = field() if rows else ground()
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3.ONE / TILE_METRES
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC


static func _paint(rows: bool) -> Image:
	var broad := FastNoiseLite.new()
	broad.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	broad.frequency = 0.012
	broad.seed = 3
	var grain := FastNoiseLite.new()
	grain.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	grain.frequency = 0.35
	grain.seed = 5
	var big := broad.get_seamless_image(SIZE, SIZE)
	var fine := grain.get_seamless_image(SIZE, SIZE)
	var level: Array[float] = []
	level.resize(SIZE * SIZE)
	for y in SIZE:
		for x in SIZE:
			var b := big.get_pixel(x, y).r - 0.5
			var g := fine.get_pixel(x, y).r - 0.5
			level[y * SIZE + x] = 0.82 + 0.24 * b + 0.16 * g
	var rng := RandomNumberGenerator.new()
	rng.seed = 41
	if rows:
		_rows(level, rng)
	else:
		_pebbles(level, rng)
		_scratches(level, rng)
	var white := Palette.get_color(&"highlight", Palette.Scheme.LIGHT)
	var image := Image.create(SIZE, SIZE, true, Image.FORMAT_RGB8)
	for y in SIZE:
		for x in SIZE:
			image.set_pixel(x, y, white.darkened(1.0 - clampf(level[y * SIZE + x], 0.35, 1.0)))
	image.generate_mipmaps()
	return image


static func _add(level: Array[float], x: int, y: int, amount: float) -> void:
	var i := posmod(y, SIZE) * SIZE + posmod(x, SIZE)
	level[i] += amount


## Small stones: a light face with a dark side, spread over the tile.
static func _pebbles(level: Array[float], rng: RandomNumberGenerator) -> void:
	for n in 70:
		var cx := rng.randi_range(0, SIZE - 1)
		var cy := rng.randi_range(0, SIZE - 1)
		var r := rng.randf_range(1.0, 2.6)
		for dy in range(-4, 5):
			for dx in range(-4, 5):
				var d := Vector2(dx, dy).length()
				if d <= r:
					_add(level, cx + dx, cy + dy, 0.14 * (1.0 - d / (r + 0.5)))
				var s := Vector2(dx - 1.5, dy - 1.5).length()
				if s <= r and d > r * 0.6:
					_add(level, cx + dx, cy + dy, -0.1)


## Fine scratches where something has dragged over the dirt.
static func _scratches(level: Array[float], rng: RandomNumberGenerator) -> void:
	for n in 14:
		var p := Vector2(rng.randf() * SIZE, rng.randf() * SIZE)
		var dir := Vector2.from_angle(rng.randf() * TAU)
		for step in rng.randi_range(10, 34):
			_add(level, int(p.x), int(p.y), -0.08)
			p += dir
			dir = dir.rotated(rng.randf_range(-0.15, 0.15))


## Rows of stubble: a faint, broken furrow every `ROW_METRES`, wandering a little, with short light
## stalks along it. Uneven on purpose, so it reads as a field and not as floorboards.
static func _rows(level: Array[float], rng: RandomNumberGenerator) -> void:
	var step := int(SIZE * ROW_METRES / TILE_METRES)
	for row in SIZE / step:
		var x := row * step
		var y := 0
		while y < SIZE:
			var run := rng.randi_range(18, 70)
			var gap := rng.randi_range(6, 26)
			for k in run:
				var wander := int(round(1.6 * sin(float(y + k) * 0.07 + float(row))))
				_add(level, x + wander, y + k, -0.1)
				_add(level, x + wander + 1, y + k, -0.04)
			y += run + gap
		for stalk in 46:
			var sy := rng.randi_range(0, SIZE - 1)
			for h in rng.randi_range(2, 6):
				_add(level, x + rng.randi_range(-3, 3), sy + h, 0.13)
	_pebbles(level, rng)
