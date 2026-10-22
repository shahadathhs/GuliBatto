class_name GuliState
extends MatchState
## What a Guli Khela match keeps. `totals` holds each side's purse. A dan starts with every side
## still in paying the stake, then an opening toss (the closest side is the scatterer), then
## passes in which every other side gets one attempt.

enum Stage { OPENING, PASSES }

const FIRST_GROUND_ID := 100

var stage: Stage = Stage.OPENING
## Sides that have been put out (they could not pay the stake), in the order they went.
var out: Array[bool] = []
var exit_order: Array[int] = []
var surrendered: int = -1
var stake: int = 3
var passes_limit: int = 3
var dan_limit: int = 20
var dan_index: int = 0
var pass_index: int = 0
var scatterer: int = -1
var kep: Vector2 = Vector2.ZERO
## Marbles in play: the stake plus every fine, and where they are by id.
var pot: int = 0
var ground: Array[int] = []
var next_ground_id: int = FIRST_GROUND_ID
## Each side's purse before it paid this dan's stake, for the result screen.
var dan_before: Array[int] = []
var rng: RandomNumberGenerator = RandomNumberGenerator.new()


func active_sides() -> Array[int]:
	var sides: Array[int] = []
	for side in side_count:
		if not out[side] and side != surrendered:
			sides.append(side)
	return sides


## The sides that played this dan: those that paid its stake.
func order_this_dan() -> Array[int]:
	var sides: Array[int] = []
	for side in dan_before.size():
		if dan_before[side] >= stake and side != surrendered:
			sides.append(side)
	return sides


func new_ground_id() -> int:
	next_ground_id += 1
	return next_ground_id - 1
