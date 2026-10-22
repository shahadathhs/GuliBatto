extends BattoTest
## Batto rules on hand-built boards, with no physics.


func test_the_opening_toss_orders_sides_closest_to_the_first_hole_first() -> void:
	var snap := _board(
		[h1 + Vector2(2.5 * r, 0.0), h1 + Vector2(1.5 * r, 0.0), h1 + Vector2(2.0 * r, 0.0)]
	)
	var last: RuleResult
	for side in 3:
		last = rules.evaluate(state, profile, snap, _report(side))
	assert_eq(state.order, [1, 2, 0] as Array[int])
	assert_eq(last.kind, &"turn")
	assert_eq(last.cue, &"order")
	assert_false(state.opening)


func test_a_toss_that_lands_in_the_first_hole_counts_as_closest_and_reaches_it() -> void:
	_open([h1 + Vector2(1.6 * r, 0.0), h1 + Vector2(0.05, 0.0), h1 + Vector2(0.9 * r, 0.0)])
	assert_eq(state.order[0], 1, "the marble in the hole goes first")
	assert_eq(state.progress[1], 1, "and has reached H1")
	assert_eq(state.progress[2], 1, "inside the radius counts too")
	assert_eq(state.progress[0], 0)


func test_an_opening_toss_goes_on_until_every_side_has_tossed() -> void:
	var snap := _board([far, far, far])
	var r := rules.evaluate(state, profile, snap, _report(0))
	assert_eq(r.kind, &"toss")
	assert_eq(state.current_side(), 1)
	assert_true(state.opening)


func test_touching_a_marble_during_the_opening_toss_changes_nothing() -> void:
	var snap := _board([far, far, far])
	rules.evaluate(state, profile, snap, _report(0, [1]))
	assert_eq(state.progress, [0, 0, 0] as Array[int])
	assert_false(state.turns.any(func(t: int) -> bool: return t > 0))


func test_reaching_the_next_hole_advances_and_earns_a_bonus_shot() -> void:
	_open([far, far + Vector2(0.5, 0.0), far + Vector2(1.0, 0.0)])
	var first := state.current_side()
	var spots := [far, far + Vector2(0.5, 0.0), far + Vector2(1.0, 0.0)]
	spots[first] = h1
	var r := _shoot(spots)
	assert_eq(state.progress[first], 1)
	assert_true(r.bonus)
	assert_eq(r.cue, &"reached")
	assert_eq(r.hole, 1)
	assert_eq(state.current_side(), first, "the same side shoots again")


func test_resting_in_a_hole_that_is_not_next_does_nothing() -> void:
	_open([far, far, far])
	var side := state.current_side()
	var spots := [far, far, far]
	spots[side] = h3
	var r := _shoot(spots)
	assert_eq(state.progress[side], 0)
	assert_false(r.bonus)
	assert_eq(r.cue, &"miss")
	assert_ne(state.current_side(), side, "the turn passes")


func test_a_marble_just_outside_the_hole_has_not_reached_it() -> void:
	_open([far, far, far])
	var side := state.current_side()
	var spots := [far, far, far]
	spots[side] = h1 + Vector2(profile.hole_radius + 0.05, 0.0)
	_shoot(spots)
	assert_eq(state.progress[side], 0)


func test_a_hit_earns_a_bonus_shot() -> void:
	_open([far, far + Vector2(0.5, 0.0), far + Vector2(1.0, 0.0)])
	var side := state.current_side()
	var rival := (side + 1) % 3
	var r := _shoot([far, far + Vector2(0.5, 0.0), far + Vector2(1.0, 0.0)], [rival])
	assert_true(r.bonus)
	assert_eq(r.cue, &"hit")
	assert_eq(state.current_side(), side)
	assert_eq(state.progress[side], 0, "a hit alone does not advance")


func test_a_hit_that_also_reaches_the_hole_earns_only_one_bonus_shot() -> void:
	_open([far, far, far])
	var side := state.current_side()
	var rival := (side + 1) % 3
	var spots := [far, far, far]
	spots[side] = h1
	var r := _shoot(spots, [rival])
	assert_eq(r.cue, &"hit_reached")
	assert_eq(state.bonus_chain, 1)
	assert_eq(state.progress[side], 1)


func test_bonus_shots_chain_up_to_the_cap_and_then_the_turn_passes() -> void:
	_open([far, far, far])
	var side := state.current_side()
	var rival := (side + 1) % 3
	for i in profile.bonus_cap:
		var r := _shoot([far, far, far], [rival])
		assert_true(r.bonus, "bonus shot %d" % (i + 1))
	var capped := _shoot([far, far, far], [rival])
	assert_false(capped.bonus)
	assert_true(capped.capped)
	assert_ne(state.current_side(), side)
	assert_eq(state.bonus_chain, 0, "the next turn starts a new chain")


func test_a_miss_passes_the_turn_round_the_order_and_counts_the_turn() -> void:
	_open([far, far, far])
	var order := state.order.duplicate()
	for i in 4:
		_shoot([far, far, far])
	assert_eq(state.current_side(), order[1], "after four shots of three sides")
	assert_eq(state.turns[order[0]], 2)
	assert_eq(state.turns[order[1]], 1)


func test_the_route_goes_out_along_the_holes_and_back() -> void:
	assert_eq(profile.route, PackedInt32Array([0, 1, 2, 1, 0]))
	_open([far, far, far])
	var side := state.current_side()
	var holes := [h1, h2, h3, h2, h1]
	for leg in 3:
		var spots := [far, far, far]
		spots[side] = holes[leg]
		_shoot(spots)
		assert_eq(state.progress[side], leg + 1, "leg %d" % (leg + 1))
		assert_eq(state.current_side(), side, "each hole gives another shot")
	var spots4 := [far, far, far]
	spots4[side] = holes[3]
	var r := _shoot(spots4)
	assert_eq(state.progress[side], 4, "the fourth leg still counts")
	assert_true(r.capped, "but the chain of bonus shots is capped at three")
	assert_ne(state.current_side(), side)


func test_reaching_the_last_hole_finishes_the_side_with_no_bonus_shot() -> void:
	_open([far, far, far])
	var side := state.current_side()
	state.progress[side] = profile.route.size() - 1
	var spots := [far, far, far]
	spots[side] = h1
	var r := _shoot(spots)
	assert_eq(r.cue, &"finished")
	assert_false(r.bonus)
	assert_eq(r.finished_side, side)
	assert_eq(state.finished, [side] as Array[int])
	assert_false(state.order.has(side), "it leaves the order")
	assert_eq(r.kind, &"turn", "two sides are still racing")


func test_the_match_ends_when_one_side_is_left_and_that_side_is_last() -> void:
	_open([far, far, far])
	var winner := state.current_side()
	state.progress[winner] = profile.route.size() - 1
	var spots := [far, far, far]
	spots[winner] = h1
	_shoot(spots)
	var second := state.current_side()
	state.progress[second] = profile.route.size() - 1
	var spots2 := [far, far, far]
	spots2[second] = h1
	var r := _shoot(spots2)
	assert_eq(r.kind, &"match")
	var third := 3 - winner - second
	assert_eq(rules.ranking(state), [winner, second, third] as Array[int])


func test_a_two_side_match_ends_as_soon_as_one_side_finishes() -> void:
	var p := RuleProfile.batto()
	p.side_count = 2
	var s := rules.start(p, 2) as BattoState
	var snap := _board([far, far])
	rules.evaluate(s, p, snap, _report(0))
	rules.evaluate(s, p, snap, _report(1))
	var side := s.current_side()
	s.progress[side] = p.route.size() - 1
	var spots := [far, far]
	spots[side] = h1
	var r := rules.evaluate(s, p, _board(spots), _report(side))
	assert_eq(r.kind, &"match")
	assert_eq(rules.ranking(s), [side, 1 - side] as Array[int])


func test_the_turn_cap_stops_the_race_and_ranks_by_progress_then_distance() -> void:
	profile.turn_cap = 2
	state = rules.start(profile, 3) as BattoState
	_open([far, far, far])
	var a := state.order[0]
	var b := state.order[1]
	var c := state.order[2]
	state.progress[a] = 2
	state.progress[b] = 1
	state.progress[c] = 1
	var spots := [far, far, far]
	spots[b] = h2 + Vector2(2.0 * r, 0.0)
	spots[c] = h2 + Vector2(1.5 * r, 0.0)
	var last: RuleResult
	for i in 6:
		last = _shoot(spots)
	assert_eq(last.kind, &"match")
	assert_eq(rules.ranking(state), [a, c, b] as Array[int], "progress, then nearer to the hole")


func test_the_text_the_screens_show_follows_the_state() -> void:
	assert_eq(rules.caption(state, profile), "Batto · opening toss")
	assert_eq(rules.turn_text(state, true), "Your toss")
	assert_eq(rules.standings(state), ["H1", "H1", "H1"] as Array[String])
	_open([far, far, far])
	assert_eq(rules.caption(state, profile), "Batto · the race")
	var side := state.current_side()
	var rival := (side + 1) % 3
	var r := _shoot([far, far, far], [rival])
	assert_eq(rules.turn_text(state, false), "Their bonus shot")
	assert_eq(rules.cue_text(r, profile, _board([far, far, far])), "Hit. Another shot")
