extends GuliTest
## Guli Khela's rules: the stake, the scatter, the baad, fines, winning a dan, passes, the end.


func test_a_dan_starts_with_every_side_paying_the_stake() -> void:
	assert_eq(state.totals, [7, 7, 7] as Array[int], "10 in the purse, 3 into the dan")
	assert_eq(state.pot, 9)
	assert_eq(state.order, [0, 1, 2] as Array[int])
	assert_eq(state.stage, GuliState.Stage.OPENING)


func test_the_opening_toss_names_the_closest_side_the_scatterer() -> void:
	var r := _toss([1.2, 0.4, 0.8])
	assert_eq(state.scatterer, 1)
	assert_eq(state.order, [2, 0] as Array[int], "the others attempt, nearest first")
	assert_eq(r.cue, &"scatter")
	assert_eq(state.stage, GuliState.Stage.PASSES)


func test_a_marble_in_the_kep_counts_as_closest() -> void:
	_toss([0.9, 0.2, 0.05])
	assert_eq(state.scatterer, 2)


func test_a_toss_that_is_not_the_last_just_passes_the_turn() -> void:
	var snap := BoardSnapshot.new()
	snap.add(0, 0, kep + Vector2(1.0, 0.0))
	var r := rules.evaluate(state, profile, snap, _report(0))
	assert_eq(r.kind, &"toss")
	assert_eq(state.current_side(), 1)


func test_the_stake_is_scattered_round_the_kep_and_the_tosses_go_home() -> void:
	var r := _scatter()
	assert_eq(r.place_marbles.size(), 9, "every marble of the stake")
	assert_eq(r.remove_marbles, [0, 1, 2] as Array[int], "the thrown marbles go back")
	var ids: Array[int] = []
	for placed in r.place_marbles:
		ids.append(placed["id"])
		assert_eq(placed["side"], SideStyle.NEUTRAL, "stake marbles belong to nobody")
		var d: float = (placed["pos"] as Vector2).distance_to(kep)
		assert_gte(d, profile.scatter_inner - 0.001, "outside the kep")
		assert_lte(d, profile.scatter_outer + 0.001, "inside the ring")
	assert_eq(ids.size(), 9)
	assert_gte(ids.min(), GuliState.FIRST_GROUND_ID, "ids are clear of the sides'")
	assert_eq(state.ground.size(), 9)


func test_no_two_stake_marbles_overlap() -> void:
	var r := _scatter()
	for i in r.place_marbles.size():
		for j in range(i + 1, r.place_marbles.size()):
			var a: Vector2 = r.place_marbles[i]["pos"]
			var b: Vector2 = r.place_marbles[j]["pos"]
			assert_gt(
				a.distance_to(b), Tuning.MARBLE_RADIUS * 2.0 + 0.05, "marbles %d and %d" % [i, j]
			)


func test_the_same_seed_scatters_the_same_way() -> void:
	var first := _scatter()
	_new_match(RuleProfile.guli(), 3)
	var second := _scatter()
	for i in first.place_marbles.size():
		assert_eq(first.place_marbles[i]["pos"], second.place_marbles[i]["pos"])


func test_a_baad_is_needed_only_once_the_attempts_begin() -> void:
	assert_false(rules.needs_baad(state))
	_scatter()
	assert_true(rules.needs_baad(state))
	assert_eq(rules.baad_choices(state, _snapshot(1)).size(), 9)


func test_touching_exactly_one_marble_that_is_not_the_baad_wins_the_dan() -> void:
	_scatter()
	var r := _throw([state.ground[0]], state.ground[1])
	assert_eq(r.cue, &"dan_won")
	assert_eq(r.winner, 1, "the first attempting side")
	assert_eq(r.kind, &"round", "the match goes on")
	assert_eq(r.points[1], 6, "7 + 9 on the ground, from 10")
	assert_eq(r.points[0], -3, "the scatterer lost its stake")
	assert_eq(r.points[2], -3)
	assert_eq(r.placing[1], &"won")
	assert_eq(state.dan_index, 1)


func test_the_result_shows_the_purses_before_the_next_stake_is_paid() -> void:
	_scatter()
	var r := _throw([state.ground[0]], state.ground[1])
	assert_eq(r.totals, [7, 16, 7] as Array[int], "as the dan finished")
	assert_eq(state.totals, [4, 13, 4] as Array[int], "the next stake is already in")


func test_a_new_dan_follows_with_the_stake_paid_again() -> void:
	_scatter()
	_throw([state.ground[0]], state.ground[1])
	assert_eq(state.totals, [4, 13, 4] as Array[int], "winner 16 - 3, the others 7 - 3")
	assert_eq(state.pot, 9)
	assert_eq(state.stage, GuliState.Stage.OPENING)
	assert_eq(state.ground.size(), 0, "the ground is empty again")
