extends GutTest


func test_a_unit_direction_and_a_power_in_range_is_valid() -> void:
	assert_true(ShotCommand.create(0, 0, Vector2(0.0, -1.0), 0.5).is_valid())
	assert_true(ShotCommand.create(0, 0, Vector2(1.0, 0.0), 1.0).is_valid())


func test_a_direction_that_is_not_a_unit_vector_is_refused() -> void:
	assert_false(ShotCommand.create(0, 0, Vector2.ZERO, 0.5).is_valid())
	assert_false(ShotCommand.create(0, 0, Vector2(2.0, 0.0), 0.5).is_valid())


func test_power_outside_zero_to_one_is_refused() -> void:
	assert_false(ShotCommand.create(0, 0, Vector2.UP, 0.0).is_valid())
	assert_false(ShotCommand.create(0, 0, Vector2.UP, 1.01).is_valid())
	assert_false(ShotCommand.create(0, 0, Vector2.UP, -0.2).is_valid())


func test_impulse_lies_on_the_ground_plane_and_scales_with_power() -> void:
	var half := ShotCommand.create(0, 0, Vector2(0.0, -1.0), 0.5).impulse(6.0, 1.0)
	assert_eq(half.y, 0.0, "no vertical component")
	assert_almost_eq(half.z, -3.0, 0.0001, "y of the direction maps to world Z")
	assert_almost_eq(half.x, 0.0, 0.0001)
	var full := ShotCommand.create(0, 0, Vector2(1.0, 0.0), 1.0).impulse(6.0, 2.0)
	assert_almost_eq(full.x, 12.0, 0.0001, "mass scales the impulse so speed stays the same")


func test_the_baad_marble_defaults_to_none() -> void:
	assert_eq(ShotCommand.create(0, 0, Vector2.UP, 0.5).baad_marble_id, -1)
