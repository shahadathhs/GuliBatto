extends GutTest

var detector: SettleDetector


func before_each() -> void:
	detector = SettleDetector.new()


func _calm() -> PackedFloat32Array:
	return PackedFloat32Array([0.0, 0.01])


func test_not_settled_before_any_time_has_passed() -> void:
	assert_false(detector.is_settled())


func test_settles_after_a_calm_window() -> void:
	var steps := int(ceil(detector.window / 0.1))
	for i in steps - 1:
		detector.feed(0.1, _calm(), _calm())
	assert_false(detector.is_settled(), "one step short of the window")
	detector.feed(0.1, _calm(), _calm())
	assert_true(detector.is_settled())


func test_movement_restarts_the_window() -> void:
	for i in 4:
		detector.feed(0.1, _calm(), _calm())
	detector.feed(0.1, PackedFloat32Array([1.0]), _calm())
	assert_eq(detector.calm_time, 0.0)
	assert_false(detector.is_settled())


func test_spinning_alone_keeps_the_board_unsettled() -> void:
	for i in 20:
		detector.feed(0.1, _calm(), PackedFloat32Array([5.0]))
	assert_false(detector.is_settled(), "angular speed counts too")


func test_one_fast_marble_among_calm_ones_blocks_settling() -> void:
	for i in 20:
		detector.feed(0.1, PackedFloat32Array([0.0, 0.0, 2.0]), PackedFloat32Array([0.0, 0.0, 0.0]))
	assert_false(detector.is_settled())


func test_the_timeout_settles_a_board_that_never_calms() -> void:
	var moving := PackedFloat32Array([3.0])
	var steps := int(ceil(detector.timeout / 0.5))
	for i in steps:
		detector.feed(0.5, moving, moving)
	assert_true(detector.timed_out)
	assert_true(detector.is_settled())


func test_reset_clears_everything() -> void:
	detector.feed(9.0, PackedFloat32Array([3.0]), PackedFloat32Array([3.0]))
	detector.reset()
	assert_eq(detector.elapsed, 0.0)
	assert_false(detector.timed_out)
	assert_false(detector.is_settled())
