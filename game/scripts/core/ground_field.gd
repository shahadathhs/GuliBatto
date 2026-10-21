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


## Heights on a square grid centred on the origin, row-major, for a HeightMapShape3D.
static func sample_grid(
	half_extent: float, cell: float, holes: PackedVector2Array, dish_radius: float, depth: float
) -> PackedFloat32Array:
	var n := int(round(half_extent * 2.0 / cell)) + 1
	var data := PackedFloat32Array()
	data.resize(n * n)
	for row in n:
		for col in n:
			var p := Vector2(-half_extent + col * cell, -half_extent + row * cell)
			data[row * n + col] = height(p, holes, dish_radius, depth)
	return data


static func grid_size(half_extent: float, cell: float) -> int:
	return int(round(half_extent * 2.0 / cell)) + 1
