extends PhysicsTest
## The camera follows shots when asked to, holds still when not, and never touches the result.

var scene: MatchScene


func before_each() -> void:
	Settings.follow_shots = true
	Settings.mark_coach_seen()


func _start(profile: RuleProfile, rules: RuleSet) -> void:
	scene = MatchScene.new()
	add_child_autofree(scene)
	scene.start(profile, rules)
	await wait_physics_frames(6)


func _toss() -> void:
	var from := scene.board.marble(0).ground_position()
	var to := scene.profile.holes[0] - from
	assert_true(scene.controller.submit_shot(ShotCommand.create(0, 0, to.normalized(), 0.5)))
	await wait_physics_frames(15)


func test_a_small_board_stays_framed_until_a_shot_rolls() -> void:
	await _start(RuleProfile.kep(), KepRules.new())
	assert_null(scene.rig.follow_point)


func test_a_small_board_follows_the_rolling_marble_a_little_and_then_lets_go() -> void:
	await _start(RuleProfile.kep(), KepRules.new())
	await _toss()
	var marble := scene.board.marble(0)
	assert_not_null(scene.rig.follow_point, "following while it rolls")
	var expected := marble.ground_position() * CameraDirector.ROLL_PULL
	assert_lt((scene.rig.follow_point as Vector2).distance_to(expected), 0.5)
	await wait_for_signal(scene.controller.shot_judged, 30.0)
	await wait_physics_frames(3)
	assert_null(scene.rig.follow_point, "and back to the framed view once it has settled")


func test_following_can_be_turned_off() -> void:
	Settings.follow_shots = false
	await _start(RuleProfile.kep(), KepRules.new())
	await _toss()
	assert_null(scene.rig.follow_point)


func test_a_tap_skips_following_for_that_shot_only() -> void:
	await _start(RuleProfile.kep(), KepRules.new())
	await _toss()
	assert_not_null(scene.rig.follow_point)
	var tap := InputEventMouseButton.new()
	tap.pressed = true
	tap.button_index = MOUSE_BUTTON_LEFT
	scene.director._unhandled_input(tap)
	await wait_physics_frames(2)
	assert_null(scene.rig.follow_point, "skipped")
	await wait_for_signal(scene.controller.turn_started, 30.0)
	await wait_for_signal(scene.controller.shot_started, 30.0)
	await wait_physics_frames(15)
	assert_not_null(scene.rig.follow_point, "the next shot is followed again")


func test_a_big_board_keeps_the_camera_where_it_was_when_following_is_off() -> void:
	Settings.follow_shots = false
	await _start(RuleProfile.batto(), BattoRules.new())
	var before: Variant = scene.rig.follow_point
	assert_not_null(before, "it still follows the shooter between shots")
	await _toss()
	assert_eq(scene.rig.follow_point, before, "but holds still while the shot rolls")


func test_a_big_board_follows_the_rolling_marble_when_following_is_on() -> void:
	await _start(RuleProfile.batto(), BattoRules.new())
	var before := scene.rig.follow_point as Vector2
	await _toss()
	var marble := scene.board.marble(0)
	var now := scene.rig.follow_point as Vector2
	assert_ne(now, before)
	assert_lt(now.distance_to(marble.ground_position()), 1.0, "on the marble itself")
