extends GutTest
## The ground height function and the physical kep: slow shots drop in, hard shots skip over.

var board: Board


func before_each() -> void:
	board = Board.new(RuleProfile.kep())
	add_child_autofree(board)
	await wait_physics_frames(4)


func _toss(power: float, from_x: float = 0.0) -> float:
	var start := Vector2(from_x, Tuning.JALLA_Z)
	await board.reset([{"id": 0, "side": 0, "pos": start}])
	board.fire(ShotCommand.create(0, 0, (Tuning.KEP_POSITION - start).normalized(), power))
	await wait_for_signal(board.shot_resolved, 20.0)
	return board.marble(0).ground_position().distance_to(Tuning.KEP_POSITION)


func test_the_ground_is_flat_away_from_holes_and_deepest_at_the_centre() -> void:
	var holes := PackedVector2Array([Vector2(1.0, 1.0)])
	assert_eq(GroundField.height(Vector2(-2.0, 0.5), holes, 0.45, 0.04), 0.0)
	assert_almost_eq(GroundField.height(Vector2(1.0, 1.0), holes, 0.45, 0.04), -0.04, 0.0001)
	var half := GroundField.height(Vector2(1.225, 1.0), holes, 0.45, 0.04)
	assert_between(half, -0.04, 0.0, "between the rim and the centre")
	assert_eq(
		GroundField.height(Vector2(1.45, 1.0), holes, 0.45, 0.04), 0.0, "level again at the rim"
	)


func test_the_grid_has_one_height_per_point() -> void:
	var data := GroundField.sample_grid(1.0, 0.5, PackedVector2Array(), 0.45, 0.04)
	assert_eq(data.size(), GroundField.grid_size(1.0, 0.5) * GroundField.grid_size(1.0, 0.5))


func test_a_well_aimed_shot_of_the_right_power_drops_into_the_kep_and_stays() -> void:
	var d: float = await _toss(0.6)
	assert_lt(d, Tuning.KEP_RADIUS, "rests inside the kep")
	assert_lt(board.marble(0).global_position.y, Tuning.MARBLE_RADIUS, "sunk into the dish")


func test_a_hard_shot_rolls_through_and_skips_the_kep() -> void:
	var d: float = await _toss(0.95)
	assert_gt(d, 0.8, "ends well past the kep")


func test_a_weak_shot_stops_short() -> void:
	var d: float = await _toss(0.35)
	assert_gt(d, Tuning.KEP_RADIUS, "does not reach the kep")


func test_the_dish_does_not_pull_a_shot_that_passes_beside_it() -> void:
	await board.reset([{"id": 0, "side": 0, "pos": Vector2(1.2, Tuning.JALLA_Z)}])
	board.fire(ShotCommand.create(0, 0, Vector2.UP, 0.6))
	await wait_for_signal(board.shot_resolved, 20.0)
	var p := board.marble(0).ground_position()
	assert_almost_eq(p.x, 1.2, 0.1, "kept its line, 0.9 m from the kep")
	assert_gt(p.distance_to(Tuning.KEP_POSITION), Tuning.DISH_RADIUS, "not captured")


func test_a_straight_roll_across_flat_ground_does_not_drift() -> void:
	var flat := Board.new(RuleProfile.bench())
	add_child_autofree(flat)
	await wait_physics_frames(4)
	await flat.reset([{"id": 0, "side": 0, "pos": Vector2(-1.5, 0.0)}])
	flat.fire(ShotCommand.create(0, 0, Vector2.RIGHT, 0.4))
	await wait_for_signal(flat.shot_resolved, 20.0)
	assert_lt(absf(flat.marble(0).ground_position().y), 0.05, "stayed on its line")
