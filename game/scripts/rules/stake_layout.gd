class_name StakeLayout
extends RefCounted
## Where the stake and the fines are set down round the kep: spread at random (from a seeded
## generator, so a test can repeat it) over a ring, never closer together than `spacing`.


static func scatter(
	count: int,
	centre: Vector2,
	profile: RuleProfile,
	rng: RandomNumberGenerator,
	taken: Array[Vector2]
) -> Array[Vector2]:
	var placed: Array[Vector2] = []
	var all: Array[Vector2] = taken.duplicate()
	for i in count:
		var spot := _find(centre, profile, rng, all)
		placed.append(spot)
		all.append(spot)
	return placed


static func _find(
	centre: Vector2, profile: RuleProfile, rng: RandomNumberGenerator, all: Array[Vector2]
) -> Vector2:
	var inner := profile.scatter_inner
	var outer := profile.scatter_outer
	var gap := profile.scatter_spacing
	for attempt in 300:
		# Looser after many tries, so a crowded ring still fills.
		if attempt == 150:
			gap *= 0.8
		var r := sqrt(lerpf(inner * inner, outer * outer, rng.randf()))
		var spot := centre + Vector2.from_angle(rng.randf() * TAU) * r
		if _is_clear(spot, all, gap):
			return spot
	# The ring is full: step outward until there is room.
	var radius := outer
	while radius < Tuning.ARENA_RADIUS - 0.4:
		radius += 0.1
		for turn in 24:
			var spot := centre + Vector2.from_angle(TAU * float(turn) / 24.0) * radius
			if _is_clear(spot, all, gap):
				return spot
	return centre + Vector2.from_angle(rng.randf() * TAU) * outer


static func _is_clear(spot: Vector2, all: Array[Vector2], gap: float) -> bool:
	for other in all:
		if spot.distance_to(other) < gap:
			return false
	return true
