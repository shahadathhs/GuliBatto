extends BattoTest
## A marble that rests in a hole is shot from the edge of the hole.


func test_a_marble_in_a_hole_is_shot_from_the_edge_facing_its_next_hole() -> void:
	_open([far, far, far])
	state.progress[0] = 1
	var snap := _board([h1, far, far])
	var start: Variant = rules.shot_start(state, profile, snap, 0)
	assert_not_null(start, "it is lifted out of the hole")
	var spot := start as Vector2
	var gap := spot.distance_to(h1)
	assert_almost_eq(gap, profile.dish_radius + profile.marble_radius + 0.03, 0.001, "at the lip")
	assert_gt(gap, profile.hole_radius, "outside the hole")
	assert_lt(spot.distance_to(h2), h1.distance_to(h2), "on the side facing H2")


func test_a_marble_outside_every_hole_shoots_from_where_it_lies() -> void:
	_open([far, far, far])
	assert_null(rules.shot_start(state, profile, _board([far, far, far]), 0))


func test_nobody_is_lifted_during_the_opening_toss() -> void:
	assert_null(rules.shot_start(state, profile, _board([h1, far, far]), 0))


func test_the_edge_spot_moves_round_the_hole_when_another_marble_is_in_the_way() -> void:
	_open([far, far, far])
	state.progress[0] = 1
	var clear := rules.shot_start(state, profile, _board([h1, far, far]), 0) as Vector2
	var blocked := rules.shot_start(state, profile, _board([h1, clear, far]), 0) as Vector2
	assert_gt(blocked.distance_to(clear), profile.marble_radius * 2.0, "not on top of the other")
	assert_almost_eq(blocked.distance_to(h1), clear.distance_to(h1), 0.001, "still at the lip")
