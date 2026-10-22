class_name BattoState
extends MatchState
## What a Batto match keeps: the opening toss, how far along the route each side is, who has
## finished and in what order, and how many bonus shots this turn has used.

## The hole indices the sides must reach, in order (copied from the profile).
var route: PackedInt32Array = PackedInt32Array()
## True while the sides are still tossing from the jalla to set the order.
var opening: bool = true
## Per side, the index into the route of the hole it must reach next.
var progress: Array[int] = []
## Per side, race turns taken (a bonus shot belongs to the same turn).
var turns: Array[int] = []
## Sides in the order they finished; the last entry is the side that lost.
var finished: Array[int] = []
## Bonus shots already taken in the current turn.
var bonus_chain: int = 0


func is_finished(side: int) -> bool:
	return finished.has(side)


## The hole index (0 to 2) a side must reach next; the last hole once it has finished.
func next_hole(side: int) -> int:
	return route[mini(progress[side], route.size() - 1)]
