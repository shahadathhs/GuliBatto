class_name BattoRules
extends RuleSet
## Batto: a race along three holes and back (the profile's route). Every side tosses once from the
## jalla toward the first hole; the closest goes first. Then each side shoots its own marble from
## where it lies, or from the edge of the hole when it rests in one. A shot that ends with the
## marble in the hole it must reach next advances it, and a hit on a rival or a hole reached earns
## one more shot (a chain of bonus shots is capped). A side that rests in the last hole has
## finished and leaves the board. The match ends when one side is left, and that side is last.
## After the turn cap the race is stopped and the sides are ranked by how far they got.

## Gap between the edge of a hole's dish and the marble set down beside it.
const RIM_GAP := 0.03


func start(profile: RuleProfile, side_count: int) -> MatchState:
	var s := BattoState.new()
	s.side_count = side_count
	s.rounds = 1
	s.route = profile.route
	for i in side_count:
		s.order.append(i)
		s.totals.append(0)
		s.progress.append(0)
		s.turns.append(0)
	return s


func spawn_position(state: MatchState, profile: RuleProfile, snapshot: BoardSnapshot) -> Vector2:
	return TossLine.spawn(state.current_side(), state.side_count, profile, snapshot)


func evaluate(
	state: MatchState, profile: RuleProfile, snapshot: BoardSnapshot, report: ShotReport
) -> RuleResult:
	var s := state as BattoState
	if s.opening:
		return _evaluate_toss(s, profile, snapshot, report)
	return _evaluate_shot(s, profile, snapshot, report)


## A marble resting in a hole is lifted to the edge of the hole, on the side facing the hole it is
## heading for, and shot from there.
func shot_start(
	state: MatchState, profile: RuleProfile, snapshot: BoardSnapshot, side: int
) -> Variant:
	var s := state as BattoState
	if s.opening:
		return null
	for hole in profile.holes:
		if snapshot.is_inside(side, hole, profile.hole_radius):
			return _rim_point(s, profile, snapshot, side, hole)
	return null


func aim_point(state: MatchState, profile: RuleProfile, side: int) -> Variant:
	var s := state as BattoState
	return profile.holes[profile.route[0] if s.opening else s.next_hole(side)]


func ranking(state: MatchState) -> Array[int]:
	return (state as BattoState).finished.duplicate()


func make_ai(seed_value: int) -> TossAI:
	return BattoAI.new(seed_value)


func caption(state: MatchState, profile: RuleProfile) -> String:
	var s := state as BattoState
	return "%s · %s" % [profile.title, "opening toss" if s.opening else "the race"]


func turn_text(state: MatchState, is_human: bool) -> String:
	var s := state as BattoState
	if s.opening:
		return "Your toss" if is_human else "Their toss"
	if s.bonus_chain > 0:
		return "Your bonus shot" if is_human else "Their bonus shot"
	return "Your shot" if is_human else "Their shot"


## The hole each side must reach next ("H2"), or its place once it has finished.
func standings(state: MatchState) -> Array[String]:
	var s := state as BattoState
	var out: Array[String] = []
	for side in s.side_count:
		if s.is_finished(side):
			out.append(["1ST", "2ND", "3RD", "4TH"][s.finished.find(side)])
		else:
			out.append("H%d" % (s.next_hole(side) + 1))
	return out


func cue_text(result: RuleResult, profile: RuleProfile, snapshot: BoardSnapshot) -> String:
	var text := "Missed"
	match result.cue:
		&"toss":
			var first := profile.holes[profile.route[0]]
			var d := snapshot.position_of(result.shooter).distance_to(first)
			text = "In H1" if d <= profile.hole_radius else "%.1f m from H1" % d
		&"order":
			text = "Closest goes first"
		&"hit":
			text = _with_bonus("Hit", result)
		&"reached":
			text = _with_bonus("In H%d" % result.hole, result)
		&"hit_reached":
			text = _with_bonus("Hit and in H%d" % result.hole, result)
		&"finished":
			text = "Finished"
	return text


func final_text(state: MatchState, side: int) -> String:
	var s := state as BattoState
	if s.progress[side] >= s.route.size():
		return "FINISHED"
	return "ON THE ROUTE AT H%d" % (s.next_hole(side) + 1)


func _rim_point(
	s: BattoState, profile: RuleProfile, snapshot: BoardSnapshot, side: int, hole: Vector2
) -> Vector2:
	var toward := profile.holes[s.next_hole(side)] - hole
	var facing := toward.normalized() if toward.length() > 0.01 else Vector2.UP
	var distance := profile.dish_radius + profile.marble_radius + RIM_GAP
	var spot := hole + facing * distance
	# Turn around the hole until the spot is clear of every other marble and on the floor.
	for step in 12:
		var sign := 1.0 if step % 2 == 0 else -1.0
		var turn: float = ceil(step / 2.0) * deg_to_rad(30.0) * sign
		spot = hole + facing.rotated(turn) * distance
		if _spot_is_clear(profile, snapshot, side, spot):
			break
	return spot


func _spot_is_clear(
	profile: RuleProfile, snapshot: BoardSnapshot, side: int, spot: Vector2
) -> bool:
	var margin := profile.marble_radius * 2.0
	if absf(spot.x) > profile.arena_size.x - margin or absf(spot.y) > profile.arena_size.y - margin:
		return false
	for id in snapshot.ids():
		if id != side and snapshot.position_of(id).distance_to(spot) < margin + 0.05:
			return false
	return true


func _evaluate_toss(
	s: BattoState, profile: RuleProfile, snapshot: BoardSnapshot, report: ShotReport
) -> RuleResult:
	var result := RuleResult.new()
	result.shooter = report.shooter_id
	s.tossed.append(report.shooter_id)
	if not s.is_last_turn_of_round():
		s.turn_index += 1
		return result
	var first := profile.holes[profile.route[0]]
	var order: Array[int] = []
	for id in s.tossed:
		order.append(snapshot.side_of(id))
	# A marble in the hole counts as closest, then the nearest one, with ties kept in toss order.
	order.sort_custom(
		func(a: int, b: int) -> bool:
			var ia := snapshot.is_inside(a, first, profile.hole_radius)
			var ib := snapshot.is_inside(b, first, profile.hole_radius)
			if ia != ib:
				return ia
			return (
				snapshot.position_of(a).distance_to(first)
				< snapshot.position_of(b).distance_to(first)
			)
	)
	for side in order:
		# A toss that comes to rest in the first hole has reached it.
		if snapshot.is_inside(side, first, profile.hole_radius):
			s.progress[side] = 1
	s.order = order
	s.turn_index = 0
	s.opening = false
	result.kind = &"turn"
	result.cue = &"order"
	return result


func _evaluate_shot(
	s: BattoState, profile: RuleProfile, snapshot: BoardSnapshot, report: ShotReport
) -> RuleResult:
	var side := s.current_side()
	var result := RuleResult.new()
	result.kind = &"turn"
	result.shooter = side
	var hit := report.touched_count() > 0
	var target := profile.holes[profile.route[s.progress[side]]]
	var reached := snapshot.is_inside(side, target, profile.hole_radius)
	if reached:
		result.hole = profile.route[s.progress[side]] + 1
		s.progress[side] += 1
	var done := reached and s.progress[side] >= profile.route.size()
	if done:
		s.finished.append(side)
		result.finished_side = side
		# A side that finishes leaves the board, once the cue has been shown.
		result.remove_marbles.append(side)
	result.cue = _cue_for(hit, reached, done)
	if (hit or reached) and not done:
		if s.bonus_chain < profile.bonus_cap:
			s.bonus_chain += 1
			result.bonus = true
			return result
		result.capped = true
	_pass_turn(s, profile, snapshot, result)
	return result


func _pass_turn(
	s: BattoState, profile: RuleProfile, snapshot: BoardSnapshot, result: RuleResult
) -> void:
	var at := s.turn_index
	s.bonus_chain = 0
	if result.finished_side >= 0:
		s.order.remove_at(at)
		s.turn_index = at % maxi(s.order.size(), 1)
	else:
		s.turns[s.order[at]] += 1
		s.turn_index = (at + 1) % s.order.size()
	if s.order.size() <= 1:
		s.finished.append_array(s.order)
		s.order = []
		result.kind = &"match"
		return
	if s.order.all(func(side: int) -> bool: return s.turns[side] >= profile.turn_cap):
		_stop_race(s, profile, snapshot)
		result.kind = &"match"


## The race ran out of turns: the sides still on the route rank by progress, then by how close
## their marble is to the hole it must reach next.
func _stop_race(s: BattoState, profile: RuleProfile, snapshot: BoardSnapshot) -> void:
	var rest: Array[int] = s.order.duplicate()
	rest.sort_custom(
		func(a: int, b: int) -> bool:
			if s.progress[a] != s.progress[b]:
				return s.progress[a] > s.progress[b]
			return (
				_distance_to_target(s, profile, snapshot, a)
				< _distance_to_target(s, profile, snapshot, b)
			)
	)
	s.finished.append_array(rest)
	s.order = []


func _distance_to_target(
	s: BattoState, profile: RuleProfile, snapshot: BoardSnapshot, side: int
) -> float:
	var hole := profile.holes[profile.route[s.progress[side]]]
	return snapshot.position_of(side).distance_to(hole)


func _cue_for(hit: bool, reached: bool, done: bool) -> StringName:
	if done:
		return &"finished"
	if hit and reached:
		return &"hit_reached"
	if reached:
		return &"reached"
	return &"hit" if hit else &"miss"


func _with_bonus(text: String, result: RuleResult) -> String:
	if result.bonus:
		return "%s. Another shot" % text
	return "%s. No more bonus shots" % text if result.capped else text
