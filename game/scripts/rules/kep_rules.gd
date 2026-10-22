class_name KepRules
extends RuleSet
## Kep: every side tosses one marble from behind the jalla toward the kep. After the last toss the
## round is scored from where the marbles rest: a marble in the kep scores 3; of the rest, the
## closest scores 2 and the next closest 1; ties share the higher score. A set number of rounds,
## and sides toss worst-first so the leader gets no edge.


func start(profile: RuleProfile, side_count: int) -> MatchState:
	var s := MatchState.new()
	s.side_count = side_count
	s.rounds = profile.rounds
	s.round_index = 0
	for i in side_count:
		s.totals.append(0)
	_begin_round(s)
	return s


func spawn_position(state: MatchState, profile: RuleProfile, snapshot: BoardSnapshot) -> Vector2:
	return TossLine.spawn(state.current_side(), state.side_count, profile, snapshot)


func evaluate(
	state: MatchState, profile: RuleProfile, snapshot: BoardSnapshot, report: ShotReport
) -> RuleResult:
	state.tossed.append(report.shooter_id)
	var result := RuleResult.new()
	result.shooter = report.shooter_id
	if not state.is_last_turn_of_round():
		state.turn_index += 1
		result.kind = &"toss"
		return result
	var scored := score_round(state.tossed, snapshot, profile)
	result.points = scored["points"]
	result.placing = scored["placing"]
	for side in result.points:
		state.totals[side] += result.points[side]
	state.round_index += 1
	if state.round_index >= state.rounds:
		result.kind = &"match"
	else:
		result.kind = &"round"
		_begin_round(state)
	return result


## Scores one round. `tossed` holds the marble ids; a marble's id equals its side index.
static func score_round(
	tossed: Array[int], snapshot: BoardSnapshot, profile: RuleProfile
) -> Dictionary:
	var kep := profile.holes[0]
	var points := {}
	var placing := {}
	var outside: Array[int] = []
	for id in tossed:
		var side := snapshot.side_of(id)
		if snapshot.is_inside(id, kep, profile.hole_radius):
			points[side] = profile.points_in_hole
			placing[side] = &"in_kep"
		else:
			outside.append(id)
	outside.sort_custom(
		func(a: int, b: int) -> bool:
			return (
				snapshot.position_of(a).distance_to(kep) < snapshot.position_of(b).distance_to(kep)
			)
	)
	var awards: Array[int] = [profile.points_closest, profile.points_second]
	var tie_epsilon := 0.02
	var place := -1
	var last_distance := 0.0
	for id in outside:
		var d := snapshot.position_of(id).distance_to(kep)
		# A marble tied with the one before it shares that marble's place and score.
		if place == -1 or absf(d - last_distance) > tie_epsilon:
			place += 1
		last_distance = d
		var side := snapshot.side_of(id)
		points[side] = awards[place] if place < awards.size() else 0
		placing[side] = [&"closest", &"second"][place] if place < 2 else &"none"
	for id in tossed:
		var side := snapshot.side_of(id)
		if not points.has(side):
			points[side] = 0
			placing[side] = &"none"
	return {"points": points, "placing": placing}


func aim_point(_state: MatchState, profile: RuleProfile, _side: int) -> Variant:
	return profile.holes[0]


func caption(state: MatchState, profile: RuleProfile) -> String:
	return "%s · round %d of %d" % [profile.title, state.round_index + 1, state.rounds]


func turn_text(_state: MatchState, owner: String) -> String:
	return "%s toss" % owner


func cue_text(result: RuleResult, profile: RuleProfile, snapshot: BoardSnapshot) -> String:
	var d := snapshot.position_of(result.shooter).distance_to(profile.holes[0])
	return "In the kep" if d <= profile.hole_radius else "%.1f m from the kep" % d


func _begin_round(state: MatchState) -> void:
	state.tossed = []
	state.turn_index = 0
	state.order = []
	if state.round_index == 0:
		for i in state.side_count:
			state.order.append(i)
		return
	# Worst first, so the leader tosses last.
	var worst_first: Array[int] = state.ranking()
	worst_first.reverse()
	state.order = worst_first
