class_name GuliRules
extends RuleSet
## Guli Khela. Every side still in pays the stake into a dan and tosses once from behind the jalla
## toward the kep; the closest side is the scatterer, and the stake is set down round the kep.
## Then, in passes, every other side gets one attempt: it names a baad marble and throws. Touching
## exactly one other marble, and not the baad, wins the dan and every marble on the ground. Touching
## the baad or two or more costs a fine of one marble from the purse, and touching nothing is a
## miss. After the passes limit with no winner the scatterer wins. A side that cannot pay the
## stake is out; the match ends with one side left, at the dan limit (most marbles wins), or when a
## side gives up. Quick Dan is the same rules with a dan limit of one.


func start(profile: RuleProfile, side_count: int) -> MatchState:
	var s := GuliState.new()
	s.side_count = side_count
	s.rounds = profile.dan_limit
	s.stake = profile.stake
	s.passes_limit = profile.passes
	s.dan_limit = profile.dan_limit
	s.kep = profile.holes[0]
	for i in side_count:
		s.totals.append(profile.purse)
		s.out.append(false)
	_begin_dan(s)
	return s


func seed_state(state: MatchState, seed_value: int) -> void:
	var s := state as GuliState
	if seed_value != 0:
		s.rng.seed = seed_value
	else:
		s.rng.randomize()


func make_ai(seed_value: int) -> TossAI:
	return GuliAI.new(seed_value)


func spawn_position(state: MatchState, profile: RuleProfile, snapshot: BoardSnapshot) -> Vector2:
	return TossLine.spawn(state.current_side(), state.side_count, profile, snapshot)


func aim_point(state: MatchState, _profile: RuleProfile, _side: int) -> Variant:
	return (state as GuliState).kep


func needs_baad(state: MatchState) -> bool:
	return (state as GuliState).stage == GuliState.Stage.PASSES


func baad_choices(state: MatchState, snapshot: BoardSnapshot) -> Array[int]:
	var out: Array[int] = []
	for id in (state as GuliState).ground:
		if snapshot.has_marble(id):
			out.append(id)
	return out


func is_out(state: MatchState, side: int) -> bool:
	var s := state as GuliState
	return side >= 0 and (s.out[side] or side == s.surrendered)


func can_surrender() -> bool:
	return true


func surrender(state: MatchState, side: int) -> RuleResult:
	(state as GuliState).surrendered = side
	var result := RuleResult.new()
	result.kind = &"match"
	result.shooter = side
	return result


func evaluate(
	state: MatchState, profile: RuleProfile, snapshot: BoardSnapshot, report: ShotReport
) -> RuleResult:
	var s := state as GuliState
	var result := RuleResult.new()
	result.shooter = report.shooter_id
	if s.stage == GuliState.Stage.OPENING:
		return _opening_toss(s, profile, snapshot, result)
	return _attempt(s, profile, snapshot, report, result)


## Sides best first: those still in by purse, then those put out (the later out, the better),
## and a side that gave up last.
func ranking(state: MatchState) -> Array[int]:
	var s := state as GuliState
	var sides: Array[int] = []
	for side in s.side_count:
		sides.append(side)
	sides.sort_custom(
		func(a: int, b: int) -> bool:
			var ga := _group(s, a)
			var gb := _group(s, b)
			if ga != gb:
				return ga < gb
			if ga == 1:
				return s.exit_order.find(a) > s.exit_order.find(b)
			return s.totals[a] > s.totals[b] or (s.totals[a] == s.totals[b] and a < b)
	)
	return sides


func caption(state: MatchState, profile: RuleProfile) -> String:
	return GuliText.caption(state as GuliState, profile)


func round_caption(state: MatchState) -> String:
	return "DAN %d" % (state as GuliState).dan_index


func total_word() -> String:
	return "purse"


func turn_text(state: MatchState, is_human: bool) -> String:
	return GuliText.turn_text(state as GuliState, is_human)


func standings(state: MatchState) -> Array[String]:
	return GuliText.standings(state as GuliState)


func cue_text(result: RuleResult, profile: RuleProfile, snapshot: BoardSnapshot) -> String:
	return GuliText.cue_text(result, profile, snapshot)


func final_text(state: MatchState, side: int) -> String:
	return GuliText.final_text(state as GuliState, side)


func _group(s: GuliState, side: int) -> int:
	if side == s.surrendered:
		return 2
	return 1 if s.out[side] else 0


## Puts out sides that cannot pay the stake, then starts a dan if the match goes on: the stake is
## paid and the sides are ready to toss. False when the match is over.
func _begin_dan(s: GuliState) -> bool:
	for side in s.side_count:
		if not s.out[side] and side != s.surrendered and s.totals[side] < s.stake:
			s.out[side] = true
			s.exit_order.append(side)
	var active := s.active_sides()
	if active.size() <= 1 or s.dan_index >= s.dan_limit:
		return false
	s.dan_before = s.totals.duplicate()
	for side in active:
		s.totals[side] -= s.stake
	s.pot = active.size() * s.stake
	s.stage = GuliState.Stage.OPENING
	s.order = active
	s.turn_index = 0
	s.tossed = []
	s.ground = []
	s.pass_index = 0
	s.scatterer = -1
	return true


func _opening_toss(
	s: GuliState, profile: RuleProfile, snapshot: BoardSnapshot, result: RuleResult
) -> RuleResult:
	s.tossed.append(result.shooter)
	if not s.is_last_turn_of_round():
		s.turn_index += 1
		return result
	var order: Array[int] = []
	for id in s.tossed:
		order.append(snapshot.side_of(id))
	# A marble in the kep counts as closest, then the nearest, ties kept in toss order.
	order.sort_custom(
		func(a: int, b: int) -> bool:
			var ia := snapshot.is_inside(a, s.kep, profile.hole_radius)
			var ib := snapshot.is_inside(b, s.kep, profile.hole_radius)
			if ia != ib:
				return ia
			return (
				snapshot.position_of(a).distance_to(s.kep)
				< snapshot.position_of(b).distance_to(s.kep)
			)
	)
	s.scatterer = order[0]
	s.order = order.slice(1)
	s.turn_index = 0
	s.stage = GuliState.Stage.PASSES
	# The tossed marbles go back to their owners and the stake is set down in their place.
	result.remove_marbles.append_array(s.tossed)
	var spots := StakeLayout.scatter(s.pot, s.kep, profile, s.rng, [] as Array[Vector2])
	for spot in spots:
		_add_to_ground(s, result, spot)
	result.kind = &"turn"
	result.cue = &"scatter"
	result.shooter = s.scatterer
	return result


func _attempt(
	s: GuliState,
	profile: RuleProfile,
	snapshot: BoardSnapshot,
	report: ShotReport,
	result: RuleResult
) -> RuleResult:
	var side := s.current_side()
	var touched: Array[int] = []
	for id in report.touched:
		if s.ground.has(id):
			touched.append(id)
	var baad_hit := touched.has(report.baad_id)
	result.kind = &"turn"
	result.shooter = side
	# The thrown marble goes back to its owner after the cue.
	result.remove_marbles.append(side)
	if touched.size() == 1 and not baad_hit:
		return _win(s, side, result, &"dan_won")
	if baad_hit or touched.size() >= 2:
		result.cue = &"fine_baad" if baad_hit else &"fine_many"
		_charge_fine(s, profile, snapshot, side, result)
	else:
		result.cue = &"miss"
	s.turn_index += 1
	if s.turn_index >= s.order.size():
		s.turn_index = 0
		s.pass_index += 1
		if s.pass_index >= s.passes_limit:
			return _win(s, s.scatterer, result, &"held")
	return result


## A fine is one marble from the side's purse, set down round the kep. An empty purse pays nothing.
func _charge_fine(
	s: GuliState, profile: RuleProfile, snapshot: BoardSnapshot, side: int, result: RuleResult
) -> void:
	if s.totals[side] <= 0:
		result.fine_paid = false
		return
	s.totals[side] -= 1
	s.pot += 1
	var taken: Array[Vector2] = []
	for id in s.ground:
		if snapshot.has_marble(id):
			taken.append(snapshot.position_of(id))
	for placed in result.place_marbles:
		taken.append(placed["pos"])
	var spot := StakeLayout.scatter(1, s.kep, profile, s.rng, taken)[0]
	_add_to_ground(s, result, spot)


## The winner takes everything on the ground. Then the next dan is begun, or the match ends.
func _win(s: GuliState, winner: int, result: RuleResult, cue: StringName) -> RuleResult:
	s.totals[winner] += s.pot
	s.pot = 0
	s.dan_index += 1
	s.round_index = s.dan_index
	result.cue = cue
	result.winner = winner
	for side in s.order_this_dan():
		result.points[side] = s.totals[side] - s.dan_before[side]
		result.placing[side] = &"won" if side == winner else &"none"
	result.totals = s.totals.duplicate()
	result.kind = &"round" if _begin_dan(s) else &"match"
	return result


func _add_to_ground(s: GuliState, result: RuleResult, spot: Vector2) -> void:
	var id := s.new_ground_id()
	s.ground.append(id)
	result.place_marbles.append({"id": id, "side": SideStyle.NEUTRAL, "pos": spot})
