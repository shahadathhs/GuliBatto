class_name ShotReport
extends RefCounted
## What the shooter's marble touched during its own shot, in order of first contact.
## Contact callbacks only add to it; rules read it after the board settles.

var shooter_id: int = -1
var touched: Array[int] = []
## Guli Khela: the marble the shooter named as baad for this shot, or -1.
var baad_id: int = -1


func add_touch(marble_id: int) -> void:
	if marble_id == shooter_id or touched.has(marble_id):
		return
	touched.append(marble_id)


func touched_count() -> int:
	return touched.size()


func has_touched(marble_id: int) -> bool:
	return touched.has(marble_id)
