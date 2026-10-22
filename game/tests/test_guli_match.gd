extends GuliTest
## How a Guli Khela match ends, how sides are ranked, and Quick Dan.


func test_a_side_that_can_still_pay_the_stake_stays_in() -> void:
	_scatter()
	state.totals[2] = 5
	_throw([state.ground[0]], state.ground[1])
	assert_false(state.out[2], "5 marbles pay the stake of 3")
	assert_eq(state.totals[2], 2, "and are left with 2")


func test_a_side_with_less_than_the_stake_is_out_at_the_start_of_the_next_dan() -> void:
	_scatter()
	state.totals[2] = 2
	var r := _throw([state.ground[0]], state.ground[1])
	assert_true(state.out[2])
	assert_eq(state.exit_order, [2] as Array[int])
	assert_eq(r.kind, &"round", "two sides are still playing")
	assert_eq(state.order, [0, 1] as Array[int], "the dan is for the sides still in")


func test_the_match_ends_when_one_side_is_left() -> void:
	_new_match(RuleProfile.guli(), 2)
	_toss([0.1, 1.0])
	state.totals[0] = 1
	var r := _throw([state.ground[0]], state.ground[1])
	assert_eq(r.kind, &"match")
	assert_eq(rules.ranking(state), [1, 0] as Array[int])


func test_the_dan_limit_ends_the_match_and_the_most_marbles_wins() -> void:
	var p := RuleProfile.guli()
	p.dan_limit = 2
	_new_match(p, 3)
	_scatter()
	var first := _throw([state.ground[0]], state.ground[1])
	assert_eq(first.kind, &"round")
	_toss([0.1, 1.0, 2.0])
	var second := _throw([state.ground[0]], state.ground[1])
	assert_eq(second.kind, &"match")
	assert_eq(rules.ranking(state)[0], 1, "side 1 won both dans")


func test_quick_dan_is_one_dan() -> void:
	_new_match(RuleProfile.quick_dan(), 3)
	_scatter()
	var r := _throw([state.ground[0]], state.ground[1])
	assert_eq(r.kind, &"match", "the match ends when the dan is won")
	assert_eq(rules.ranking(state)[0], 1)


func test_quick_dan_ends_even_when_the_scatterer_wins_by_default() -> void:
	_new_match(RuleProfile.quick_dan(), 3)
	_scatter()
	var last: RuleResult
	for attempt in 6:
		last = _throw([], state.ground[0])
	assert_eq(last.kind, &"match")
	assert_eq(rules.ranking(state)[0], 0)


func test_giving_up_ends_the_match_and_puts_that_side_last() -> void:
	_scatter()
	var r := rules.surrender(state, 0)
	assert_eq(r.kind, &"match")
	assert_eq(rules.ranking(state).back(), 0)
	assert_true(rules.is_out(state, 0))
	assert_eq(rules.final_text(state, 0), "GAVE UP")


func test_sides_are_ranked_by_purse_then_by_when_they_went_out() -> void:
	state.totals = [9, 4, 6] as Array[int]
	assert_eq(rules.ranking(state), [0, 2, 1] as Array[int], "by purse")
	state.out[1] = true
	state.exit_order.append(1)
	assert_eq(rules.ranking(state), [0, 2, 1] as Array[int], "out sides come after")
	state.out[2] = true
	state.exit_order.append(2)
	assert_eq(rules.ranking(state), [0, 2, 1] as Array[int], "the later out is better")


func test_equal_purses_rank_by_side_order() -> void:
	state.totals = [5, 5, 5] as Array[int]
	assert_eq(rules.ranking(state), [0, 1, 2] as Array[int])


func test_the_words_shown_follow_the_state() -> void:
	assert_eq(rules.caption(state, profile), "Guli Khela · dan 1 · opening toss")
	assert_eq(rules.turn_text(state, true), "Your toss")
	assert_eq(rules.standings(state), ["7", "7", "7"] as Array[String])
	_scatter()
	assert_eq(rules.caption(state, profile), "Guli Khela · dan 1 · pass 1 of 3")
	assert_eq(rules.turn_text(state, false), "Their throw")
	state.out[2] = true
	assert_eq(rules.standings(state)[2], "OUT")
	assert_eq(rules.final_text(state, 0), "7 MARBLES")
	assert_eq(rules.round_caption(state), "DAN 0")
	assert_eq(rules.total_word(), "purse")


func test_quick_dan_names_itself_without_a_dan_number() -> void:
	_new_match(RuleProfile.quick_dan(), 3)
	assert_eq(rules.caption(state, profile), "Quick Dan · opening toss")
