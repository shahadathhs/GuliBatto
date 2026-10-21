extends GutTest
## Real physics, broad outcomes with margins: the Milestone 1 cases from the implementation plan.
## `make game-test` runs Godot with --fixed-fps, which drops real-time pacing but keeps the
## physics step, so these run fast. Do not use Engine.time_scale: it changes the physics.

var bench: Board


func before_each() -> void:
	bench = Board.new()
	add_child_autofree(bench)
	await wait_physics_frames(4)


func _layout(entries: Array) -> void:
	await bench.reset(entries)


func _entry(id: int, side: int, pos: Vector2) -> Dictionary:
	return {"id": id, "side": side, "pos": pos}


func _shoot(id: int, direction: Vector2, power: float) -> void:
	assert_true(
		bench.fire(ShotCommand.create(0, id, direction.normalized(), power)), "shot accepted"
	)
	await wait_for_signal(bench.shot_resolved, 30.0)


func _moved(id: int, from: Vector2) -> float:
	return bench.marble(id).ground_position().distance_to(from)


func test_a_straight_roll_goes_straight_and_stops_without_the_timeout() -> void:
	var start := Vector2(-1.5, 0.0)
	await _layout([_entry(0, 0, start)])
	await _shoot(0, Vector2.RIGHT, 0.4)
	var end := bench.marble(0).ground_position()
	assert_gt(end.x - start.x, 1.0, "rolled forward")
	assert_lt(absf(end.y - start.y), 0.05, "stayed on its line")
	assert_false(bench.detector.timed_out, "settled by itself")
	assert_lt(bench.detector.elapsed, Tuning.SETTLE_TIMEOUT)


func test_distance_grows_with_power() -> void:
	var last := 0.0
	for power in [0.2, 0.4, 0.6]:
		await _layout([_entry(0, 0, Vector2(-2.0, 0.0))])
		await _shoot(0, Vector2.RIGHT, power)
		var d := _moved(0, Vector2(-2.0, 0.0))
		assert_gt(d, last, "power %.1f goes farther than the one before" % power)
		last = d


func test_a_low_power_shot_moves_a_little() -> void:
	var start := Vector2(0.0, 0.0)
	await _layout([_entry(0, 0, start)])
	await _shoot(0, Vector2.UP, 0.05)
	var d := _moved(0, start)
	assert_gt(d, 0.0, "it moved")
	assert_lt(d, 0.5, "but not far")


func test_head_on_hit_sends_the_target_along_the_line_and_slows_the_shooter() -> void:
	await _layout([_entry(0, 0, Vector2(0.0, 1.5)), _entry(1, 1, Vector2(0.0, 0.0))])
	await _shoot(0, Vector2.UP, 0.7)
	assert_true(bench.report.has_touched(1), "the report records the hit")
	var target := bench.marble(1).ground_position()
	assert_lt(target.y, -0.5, "target was driven away along the line")
	assert_lt(absf(target.x), 0.08, "straight on, so no sideways drift")
	assert_gt(bench.marble(0).ground_position().y, target.y, "shooter ends behind the target")


func test_a_glancing_hit_deflects_the_target_sideways() -> void:
	await _layout([_entry(0, 0, Vector2(0.25, 1.5)), _entry(1, 1, Vector2(0.0, 0.0))])
	await _shoot(0, Vector2.UP, 0.7)
	assert_true(bench.report.has_touched(1))
	assert_lt(bench.marble(1).ground_position().x, -0.1, "hit on the right, pushed left")


func test_a_miss_touches_nothing() -> void:
	await _layout([_entry(0, 0, Vector2(-1.5, 1.0)), _entry(1, 1, Vector2(1.0, -1.0))])
	await _shoot(0, Vector2.RIGHT, 0.4)
	assert_eq(bench.report.touched_count(), 0)


func test_a_wall_bounce_keeps_the_marble_inside() -> void:
	await _layout([_entry(0, 0, Vector2(0.0, 0.0))])
	await _shoot(0, Vector2.RIGHT, 0.9)
	var p := bench.marble(0).ground_position()
	assert_lt(p.length(), Tuning.ARENA_RADIUS, "still inside the arena")
	assert_lt(p.x, Tuning.ARENA_RADIUS - Tuning.MARBLE_RADIUS * 0.5, "came back off the wall")


func test_a_marble_pressed_against_the_boundary_settles_inside() -> void:
	var edge := Vector2(Tuning.ARENA_RADIUS - Tuning.MARBLE_RADIUS - 0.01, 0.0)
	await _layout([_entry(0, 0, edge)])
	await _shoot(0, Vector2.RIGHT, 1.0)
	assert_false(bench.detector.timed_out, "does not jitter until the timeout")
	assert_lt(bench.marble(0).ground_position().length(), Tuning.ARENA_RADIUS)


func test_maximum_power_never_escapes_in_any_direction() -> void:
	for i in 8:
		var dir := Vector2.from_angle(TAU * float(i) / 8.0)
		await _layout([_entry(0, 0, Vector2.ZERO)])
		await _shoot(0, dir, 1.0)
		var p := bench.marble(0)
		assert_lt(
			p.ground_position().length(), Tuning.ARENA_RADIUS, "direction %d stayed inside" % i
		)
		assert_lt(absf(p.global_position.y), 1.0, "and did not leave the ground plane")


func test_the_same_shot_gives_the_same_result() -> void:
	var layout := [_entry(0, 0, Vector2(0.0, 1.5)), _entry(1, 1, Vector2(0.1, 0.0))]
	await _layout(layout)
	await _shoot(0, Vector2.UP, 0.7)
	var first_a := bench.marble(0).ground_position()
	var first_b := bench.marble(1).ground_position()
	await _layout(layout)
	await _shoot(0, Vector2.UP, 0.7)
	assert_lt(bench.marble(0).ground_position().distance_to(first_a), 0.02, "shooter repeats")
	assert_lt(bench.marble(1).ground_position().distance_to(first_b), 0.02, "target repeats")


func test_a_shot_is_refused_while_the_previous_one_is_resolving() -> void:
	await _layout([_entry(0, 0, Vector2(-1.5, 0.0))])
	var command := ShotCommand.create(0, 0, Vector2.RIGHT, 0.5)
	assert_true(bench.fire(command))
	assert_eq(bench.state, Board.State.ROLLING)
	assert_false(bench.fire(command), "no second shot while rolling")
	await wait_for_signal(bench.shot_resolved, 30.0)
	assert_eq(bench.state, Board.State.READY)
	assert_true(bench.fire(command), "ready again once settled")


func test_a_shot_is_refused_while_resetting() -> void:
	bench.reset(Board.default_layout())
	assert_eq(bench.state, Board.State.RESETTING)
	assert_false(bench.fire(ShotCommand.create(0, 0, Vector2.UP, 0.5)))
	await wait_physics_frames(3)
	assert_eq(bench.state, Board.State.READY)


func test_rapid_repeated_resets_restore_the_exact_layout() -> void:
	var layout := Board.default_layout()
	for i in 20:
		await bench.reset(layout)
		if i % 4 == 0:
			bench.fire(ShotCommand.create(0, 0, Vector2.UP, 0.8))
			await wait_physics_frames(6)
	await bench.reset(layout)
	for entry in layout:
		var m := bench.marble(entry["id"])
		assert_lt(
			m.ground_position().distance_to(entry["pos"]),
			0.001,
			"marble %d is where it started" % entry["id"]
		)
		assert_eq(m.linear_velocity, Vector3.ZERO, "and at rest")
	assert_eq(bench.state, Board.State.READY)
