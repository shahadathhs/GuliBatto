class_name GroundField
extends RefCounted
## The height of the ground: flat, with a smooth dish around each hole. The collision shape and
## the visible mesh are both sampled from this one function, so what you see is what rolls.


static func height(
	point: Vector2, holes: PackedVector2Array, dish_radius: float, depth: float
) -> float:
	var h := 0.0
	for hole in holes:
		var d := point.distance_to(hole)
		if d < dish_radius:
			h = minf(h, -depth * 0.5 * (1.0 + cos(PI * d / dish_radius)))
	return h


## The square patch around each hole that gets a heightmap; everywhere else the ground is a box.
## Each patch is wider than the dish so its edges are flat, and sized to a whole number of cells.
static func patch_rects(holes: PackedVector2Array, dish_radius: float, cell: float) -> Array[Rect2]:
	var half := ceilf((dish_radius + 0.1) / cell) * cell
	var rects: Array[Rect2] = []
	for hole in holes:
		rects.append(Rect2(hole - Vector2(half, half), Vector2(half, half) * 2.0))
	return rects


## The parts of the square [-half, half] on both axes that the patches do not cover, as rectangles
## that do not overlap. Together with the patches they tile the whole ground.
static func free_rects(half: float, patches: Array[Rect2]) -> Array[Rect2]:
	var eps := 0.0001
	var xs: Array[float] = [-half, half]
	for p in patches:
		xs.append(clampf(p.position.x, -half, half))
		xs.append(clampf(p.end.x, -half, half))
	xs.sort()
	var out: Array[Rect2] = []
	for i in xs.size() - 1:
		var x0 := xs[i]
		var x1 := xs[i + 1]
		if x1 - x0 < eps:
			continue
		var covered: Array[Vector2] = []
		for p in patches:
			if p.position.x < x1 - eps and p.end.x > x0 + eps:
				covered.append(
					Vector2(clampf(p.position.y, -half, half), clampf(p.end.y, -half, half))
				)
		covered.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
		var z := -half
		for c in covered:
			if c.x - z > eps:
				out.append(Rect2(x0, z, x1 - x0, c.x - z))
			z = maxf(z, c.y)
		if half - z > eps:
			out.append(Rect2(x0, z, x1 - x0, half - z))
	return out


## Number of height samples along an edge of a patch.
static func samples_along(length: float, cell: float) -> int:
	return int(round(length / cell)) + 1


## Heights over a rectangle, row-major, for a HeightMapShape3D centred on the rectangle.
static func sample_rect(
	rect: Rect2, cell: float, holes: PackedVector2Array, dish_radius: float, depth: float
) -> PackedFloat32Array:
	var nx := samples_along(rect.size.x, cell)
	var nz := samples_along(rect.size.y, cell)
	var data := PackedFloat32Array()
	data.resize(nx * nz)
	for row in nz:
		for col in nx:
			var p := rect.position + Vector2(col * cell, row * cell)
			data[row * nx + col] = height(p, holes, dish_radius, depth)
	return data
