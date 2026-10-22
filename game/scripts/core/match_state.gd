class_name MatchState
extends RefCounted
## What the match keeps between shots: scores, the round, and whose turn it is.

var side_count: int = 0
var round_index: int = 0
var rounds: int = 1
var totals: Array[int] = []
## Side indices in the order they take their turn this round.
var order: Array[int] = []
## Index into `order` of the side about to shoot.
var turn_index: int = 0
## Marble id each side tossed this round, in toss order.
var tossed: Array[int] = []


## The side about to shoot, or -1 when the match is over and nobody is.
func current_side() -> int:
	return order[turn_index] if turn_index < order.size() else -1


func is_last_turn_of_round() -> bool:
	return turn_index >= order.size() - 1


## Sides ranked best first by total, ties broken by side index.
func ranking() -> Array[int]:
	var sides: Array[int] = []
	for i in side_count:
		sides.append(i)
	sides.sort_custom(
		func(a: int, b: int) -> bool:
			return totals[a] > totals[b] or (totals[a] == totals[b] and a < b)
	)
	return sides
