class_name BoardSnapshot
extends RefCounted
## Where every marble rests, taken once after the board settles. Rules read this and never
## the live nodes, so a test can build one by hand and check a result without physics.

var _marbles: Dictionary = {}


func add(marble_id: int, side: int, position: Vector2) -> void:
	_marbles[marble_id] = {"side": side, "position": position}


func has_marble(marble_id: int) -> bool:
	return _marbles.has(marble_id)


func count() -> int:
	return _marbles.size()


func ids() -> Array:
	return _marbles.keys()


func position_of(marble_id: int) -> Vector2:
	return _marbles[marble_id]["position"]


func side_of(marble_id: int) -> int:
	return _marbles[marble_id]["side"]


func distance_between(a: int, b: int) -> float:
	return position_of(a).distance_to(position_of(b))


## True when the marble's centre is inside the circle (a hole or the kep).
func is_inside(marble_id: int, centre: Vector2, radius: float) -> bool:
	return position_of(marble_id).distance_to(centre) <= radius + 0.0001
