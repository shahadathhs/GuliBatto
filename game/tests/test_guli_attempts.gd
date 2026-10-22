extends GuliTest
## What an attempt can do after the dan is set up: a fine, a miss, another pass, the scatterer
## keeping the ground.


func test_touching_the_baad_alone_costs_a_fine_and_ends_the_attempt() -> void:
	_scatter()
	var baad := state.ground[1]
	var r := _throw([baad], baad)
	assert_eq(r.cue, &"fine_baad")
	assert_eq(state.totals[1], 6, "one marble from the purse")
	assert_eq(state.pot, 10)
	assert_eq(r.place_marbles.size(), 1, "the fine is set down")
	assert_eq(state.ground.size(), 10)
	assert_eq(r.remove_marbles, [1] as Array[int], "the throw goes home")
	assert_eq(state.current_side(), 2, "the next side attempts")
	assert_ne(r.kind, &"round")


func test_touching_two_marbles_costs_a_fine() -> void:
	_scatter()
	var r := _throw([state.ground[0], state.ground[2]], state.ground[1])
	assert_eq(r.cue, &"fine_many")
	assert_eq(state.totals[1], 6)


func test_touching_the_baad_and_another_is_a_fine_not_a_win() -> void:
	_scatter()
	var r := _throw([state.ground[0], state.ground[1]], state.ground[1])
	assert_eq(r.cue, &"fine_baad")


func test_touching_nothing_is_a_miss_with_no_fine() -> void:
	_scatter()
	var r := _throw([], state.ground[1])
	assert_eq(r.cue, &"miss")
	assert_eq(state.totals[1], 7)
	assert_eq(r.place_marbles.size(), 0)
	assert_eq(state.current_side(), 2)


func test_a_marble_that_is_not_on_the_ground_is_not_a_touch() -> void:
	_scatter()
	var r := _throw([2], state.ground[1])
	assert_eq(r.cue, &"miss", "a thrown marble is not stake")


func test_a_side_with_an_empty_purse_pays_no_fine() -> void:
	_scatter()
	state.totals[1] = 0
	var r := _throw([state.ground[0], state.ground[2]], state.ground[1])
	assert_false(r.fine_paid)
	assert_eq(state.totals[1], 0)
	assert_eq(state.pot, 9, "nothing was added")
	assert_eq(r.place_marbles.size(), 0)


func test_every_side_failing_starts_another_pass_on_the_same_ground() -> void:
	_scatter()
	_throw([], state.ground[0])
	_throw([], state.ground[0])
	assert_eq(state.pass_index, 1)
	assert_eq(state.current_side(), 1, "the first attempting side again")
	assert_eq(state.ground.size(), 9, "the same ground")


func test_after_three_passes_with_no_winner_the_scatterer_keeps_the_ground() -> void:
	_scatter()
	var last: RuleResult
	for attempt in 6:
		last = _throw([], state.ground[0])
	assert_eq(last.cue, &"held")
	assert_eq(last.winner, 0, "the scatterer")
	assert_eq(last.points[0], 6, "10 - 3 + 9")
	assert_eq(state.dan_index, 1)


func test_in_a_two_side_match_the_other_side_has_three_attempts() -> void:
	_new_match(RuleProfile.guli(), 2)
	_toss([0.1, 1.0])
	assert_eq(state.order, [1] as Array[int])
	_throw([], state.ground[0])
	_throw([], state.ground[0])
	var last := _throw([], state.ground[0])
	assert_eq(last.cue, &"held", "three attempts, then the scatterer wins")
	assert_eq(last.winner, 0)


func test_fines_make_the_ground_bigger_for_the_next_attempt() -> void:
	_scatter()
	_throw([state.ground[0], state.ground[1]], state.ground[1])
	assert_eq(rules.baad_choices(state, _snapshot(2)).size(), 10, "the fine can be named too")
