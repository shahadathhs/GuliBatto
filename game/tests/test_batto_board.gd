extends PhysicsTest
## The Batto board: a large rectangle, small marbles, holes ten or more marbles wide.

var profile: RuleProfile
var board: Board


func before_each() -> void:
	profile = RuleProfile.batto()
	board = Board.new(profile)
	add_child_autofree(board)
	await wait_physics_frames(3)


func _start() -> Vector2:
	return Vector2(0.0, profile.jalla_z + profile.marble_radius + 0.08)


func _inside_floor(p: Vector2) -> bool:
	return absf(p.x) < profile.arena_size.x and absf(p.y) < profile.arena_size.y


func test_the_marble_is_small_and_the_hole_is_four_marbles_wide_and_very_deep() -> void:
	assert_lt(profile.marble_radius, Tuning.MARBLE_RADIUS, "smaller than the Kep marble")
	assert_almost_eq(profile.hole_radius / profile.marble_radius, 4.0, 0.001, "four marbles wide")
	assert_gt(profile.dish_depth, profile.marble_radius * 4.0, "much deeper than a marble is wide")
	assert_true(profile.arena_rect)
	assert_gt(profile.arena_size.y, profile.arena_size.x, "longer than it is wide")
	assert_gte(profile.arena_size.x * 2.0, 9.0, "a big board")
	assert_gte(profile.arena_size.y * 2.0, 36.0, "a long board")


func test_the_holes_and_the_jalla_fit_on_the_floor_without_touching_each_other() -> void:
	for i in profile.holes.size():
		var h := profile.holes[i]
		assert_lt(absf(h.x) + profile.dish_radius, profile.arena_size.x, "hole %d inside" % i)
		assert_lt(absf(h.y) + profile.dish_radius, profile.arena_size.y, "hole %d inside" % i)
		assert_lt(h.y + profile.dish_radius, profile.jalla_z, "hole %d is beyond the jalla" % i)
		if i > 0:
			var gap := h.distance_to(profile.holes[i - 1])
			assert_gt(gap, profile.dish_radius * 2.0, "dishes %d and %d are apart" % [i, i - 1])
			assert_gt(gap, 12.0, "holes %d and %d are far apart" % [i, i - 1])


func test_the_floor_is_tiled_by_boxes_and_hole_patches_with_nothing_missing() -> void:
	var patches := GroundField.patch_rects(profile.holes, profile.dish_radius, Tuning.GROUND_CELL)
	var floor_rect := Rect2(-profile.arena_size, profile.arena_size * 2.0)
	var area := 0.0
	for rect in GroundField.free_rects(floor_rect, patches):
		area += rect.get_area()
	for rect in patches:
		area += rect.get_area()
	assert_almost_eq(area, floor_rect.get_area(), 0.01)


func test_a_full_power_shot_in_any_direction_stays_on_the_board() -> void:
	for i in 8:
		await board.reset([{"id": 0, "side": 0, "pos": _start()}])
		board.fire(ShotCommand.create(0, 0, Vector2.from_angle(TAU * i / 8.0), 1.0))
		await wait_for_signal(board.shot_resolved, 30.0)
		var m := board.marble(0)
		assert_true(_inside_floor(m.ground_position()), "direction %d stayed on the floor" % i)
		assert_lt(m.global_position.y, 0.5, "and did not leave the ground")


func test_a_full_power_shot_rolls_most_of_the_length_of_the_board() -> void:
	await board.reset([{"id": 0, "side": 0, "pos": Vector2(2.0, -18.0)}])
	board.fire(ShotCommand.create(0, 0, Vector2.DOWN, 1.0))
	await wait_for_signal(board.shot_resolved, 30.0)
	# From the far end toward the jalla end, with a wall to bounce off at the near end.
	var travelled := absf(board.marble(0).ground_position().y - (-18.0))
	gut.p("full power on the Batto board: rested %.1f m from where it started" % travelled)
	assert_gt(travelled, 8.0, "a full-power shot covers most of the board")


func test_a_gentle_toss_at_the_first_hole_comes_to_rest_in_it() -> void:
	var ai := BattoAI.new(9)
	var in_hole := 0
	for i in 8:
		await board.reset([{"id": 0, "side": 0, "pos": _start()}])
		board.fire(ai.choose_toss(0, 0, _start(), profile.holes[0], profile.shot_speed))
		await wait_for_signal(board.shot_resolved, 30.0)
		if board.snapshot().is_inside(0, profile.holes[0], profile.hole_radius):
			in_hole += 1
	gut.p("computer tosses at H1: %d of 8 rested in the hole" % in_hole)
	assert_gt(in_hole, 3, "a toss aimed at the hole usually lands in it")


func test_a_hard_shot_straight_over_the_hole_does_not_stay_in_it() -> void:
	await board.reset([{"id": 0, "side": 0, "pos": _start()}])
	board.fire(ShotCommand.create(0, 0, Vector2.UP, 1.0))
	await wait_for_signal(board.shot_resolved, 30.0)
	assert_false(board.snapshot().is_inside(0, profile.holes[0], profile.hole_radius))


func test_a_slow_marble_drops_into_the_hole_and_stays_there() -> void:
	var from := Vector2(0.0, profile.holes[0].y + 1.5)
	await board.reset([{"id": 0, "side": 0, "pos": from}])
	board.fire(ShotCommand.create(0, 0, Vector2.UP, 0.22))
	await wait_for_signal(board.shot_resolved, 30.0)
	var p := board.marble(0).ground_position()
	assert_lt(p.distance_to(profile.holes[0]), profile.hole_radius, "rests in the hole")
	assert_lt(board.marble(0).global_position.y, 0.0, "down in the pit, below the floor")


func test_which_powers_land_in_the_hole() -> void:
	# From the jalla straight at H1: record every power, so the capture window can be read.
	var landed: Array[String] = []
	var fast_in := false
	for power in [0.3, 0.4, 0.45, 0.5, 0.55, 0.6, 0.7, 0.8, 1.0]:
		await board.reset([{"id": 0, "side": 0, "pos": _start()}])
		board.fire(ShotCommand.create(0, 0, Vector2.UP, power))
		await wait_for_signal(board.shot_resolved, 30.0)
		var inside := board.snapshot().is_inside(0, profile.holes[0], profile.hole_radius)
		landed.append("%.2f:%s" % [power, "in" if inside else "out"])
		if power >= 1.0 and inside:
			fast_in = true
	gut.p("straight at H1 from the jalla: %s" % ", ".join(landed))
	assert_false(fast_in, "a shot that is too fast rolls over the hole")


func test_a_marble_can_be_set_down_at_the_edge_of_a_hole_and_then_shoots() -> void:
	await board.reset([{"id": 0, "side": 0, "pos": profile.holes[0]}])
	var edge := profile.holes[0] + Vector2(0.0, -(profile.dish_radius + 0.2))
	board.move_marble(0, edge)
	assert_false(
		board.fire(ShotCommand.create(0, 0, Vector2.UP, 0.5)), "refused while it is set down"
	)
	await wait_physics_frames(3)
	assert_lt(board.marble(0).ground_position().distance_to(edge), 0.02, "it is where it was put")
	assert_true(board.fire(ShotCommand.create(0, 0, Vector2.UP, 0.5)), "then it can shoot")
	await wait_for_signal(board.shot_resolved, 30.0)
