extends PhysicsTest
## A hit is the shooter's marble touching a rival's, recorded for the rules. It must be found
## whether the rival has been resting a long time, is already touching the shooter, or is knocked
## into a hole by the hit.

var profile: RuleProfile
var board: Board


func before_each() -> void:
	profile = RuleProfile.batto()
	board = Board.new(profile)
	add_child_autofree(board)
	await wait_physics_frames(3)


## Flat ground between H1 and H2, well clear of both dishes.
func _flat(z: float) -> Vector2:
	return Vector2(0.0, z)


func _shoot(shooter: Vector2, rival: Vector2, direction: Vector2, power: float) -> bool:
	await board.reset([{"id": 0, "side": 0, "pos": shooter}, {"id": 1, "side": 1, "pos": rival}])
	# Long enough for both marbles to be at rest, as they are in a real match.
	await wait_physics_frames(90)
	board.fire(ShotCommand.create(0, 0, direction, power))
	await wait_for_signal(board.shot_resolved, 30.0)
	return board.report.has_touched(1)


func test_a_marble_that_has_been_resting_is_hit() -> void:
	var hit: bool = await _shoot(_flat(4.0), _flat(2.5), Vector2.UP, 0.3)
	assert_true(hit)


func test_a_rival_touching_the_shooter_is_hit_when_the_shot_goes_into_it() -> void:
	for power in [0.1, 0.3, 0.6]:
		var hit: bool = await _shoot(_flat(4.0), _flat(3.8), Vector2.UP, power)
		assert_true(hit, "power %.1f into a marble that is already touching" % power)


func test_a_rival_touching_the_shooter_is_not_hit_when_the_shot_goes_away() -> void:
	for dir in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var hit: bool = await _shoot(_flat(4.0), _flat(3.8), dir, 0.3)
		assert_false(hit, "shooting %s, away from the marble" % dir)


func test_a_rival_knocked_into_a_hole_by_the_hit_still_counts_as_hit() -> void:
	var hole := profile.holes[1]
	# The rival rests just outside the dish, on the side facing the shooter.
	var rival := hole + Vector2(0.0, profile.dish_radius + 0.15)
	var hit: bool = await _shoot(rival + Vector2(0.0, 1.6), rival, Vector2.UP, 0.3)
	assert_true(hit, "the marble was hit")
	assert_true(
		board.snapshot().is_inside(1, hole, profile.hole_radius), "and it fell into the hole"
	)


func test_a_shot_that_misses_a_rival_records_no_hit() -> void:
	var hit: bool = await _shoot(_flat(4.0), Vector2(2.0, 2.5), Vector2.UP, 0.3)
	assert_false(hit)
