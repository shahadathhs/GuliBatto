class_name TossLine
extends RefCounted
## Where a side stands to toss from behind the jalla: spread across the line by side, nudged
## sideways if an earlier toss came to rest on the spot. Kep and Batto share it.

const SPREAD := 0.7
const CLEARANCE := 0.45


static func spawn(
	side: int, side_count: int, profile: RuleProfile, snapshot: BoardSnapshot
) -> Vector2:
	var z := profile.jalla_z + profile.marble_radius + 0.08
	var x := (float(side) - float(side_count - 1) / 2.0) * SPREAD
	for attempt in 6:
		var clear := true
		for id in snapshot.ids():
			if snapshot.position_of(id).distance_to(Vector2(x, z)) < CLEARANCE:
				clear = false
		if clear:
			break
		x += CLEARANCE
	return Vector2(x, z)
