extends PhysicsTest
## Sound reacts to what happens, respects the settings, and never touches the result.

var sfx: Sfx


func before_each() -> void:
	Settings.sound_on = true
	Settings.volume = 1.0
	Sfx.record = true
	Sfx.played.clear()
	Sfx.started = 0
	sfx = Sfx.new()
	add_child_autofree(sfx)


func after_each() -> void:
	Sfx.record = false
	Sfx.played.clear()


func test_every_event_has_a_sound_file_that_loads() -> void:
	for event in Sfx.FILES:
		var path: String = Sfx.FILES[event]
		assert_true(ResourceLoader.exists(path), "%s exists" % path)
		assert_true(load(path) is AudioStreamWAV, "%s is a wav" % path)


func test_a_sound_starts_when_sound_is_on() -> void:
	Sfx.play(Sfx.Event.TAP)
	assert_eq(Sfx.started, 1)


func test_nothing_starts_when_sound_is_off_but_the_request_is_still_seen() -> void:
	Settings.sound_on = false
	Sfx.play(Sfx.Event.TAP)
	assert_eq(Sfx.started, 0)
	assert_eq(Sfx.played, [Sfx.Event.TAP] as Array[Sfx.Event])


func test_a_volume_of_zero_is_silent() -> void:
	Settings.volume = 0.0
	Sfx.play(Sfx.Event.HIT)
	assert_eq(Sfx.started, 0)


func test_the_same_sound_is_not_restarted_within_a_moment() -> void:
	Sfx.play(Sfx.Event.HIT)
	Sfx.play(Sfx.Event.HIT)
	assert_eq(Sfx.started, 1, "a rattle of contacts is one sound")
	Sfx.play(Sfx.Event.WALL)
	assert_eq(Sfx.started, 2, "a different sound is not held back")


func test_a_harder_hit_is_louder_within_limits() -> void:
	assert_lt(Sfx.strength_for_speed(1.0), Sfx.strength_for_speed(4.0))
	assert_lt(Sfx.strength_for_speed(4.0), Sfx.strength_for_speed(8.0))
	assert_almost_eq(Sfx.strength_for_speed(0.0), 0.1, 0.0001, "never quite silent")
	assert_almost_eq(Sfx.strength_for_speed(50.0), 1.0, 0.0001, "never louder than full")


func test_without_a_player_in_the_scene_playing_does_nothing() -> void:
	sfx.queue_free()
	await wait_physics_frames(2)
	Sfx.play(Sfx.Event.TAP)
	assert_eq(Sfx.started, 0)


func test_buttons_make_a_tap() -> void:
	var primary := UiKit.primary("Start")
	var secondary := UiKit.secondary("Back")
	var tertiary := UiKit.text_action("About")
	for button in [primary, secondary, tertiary]:
		add_child_autofree(button)
	primary.pressed.emit()
	secondary.pressed.emit()
	tertiary.pressed.emit()
	assert_eq(Sfx.played.count(Sfx.Event.TAP), 3)


func _board_with_director() -> Array:
	var profile := RuleProfile.batto()
	var board := Board.new(profile)
	add_child_autofree(board)
	var controller := MatchController.new()
	add_child_autofree(controller)
	var director := SoundDirector.new(board, controller)
	add_child_autofree(director)
	await wait_physics_frames(3)
	return [board, controller, profile]


func test_a_hit_between_marbles_is_heard_once_for_the_pair() -> void:
	var parts: Array = await _board_with_director()
	var board: Board = parts[0]
	await (
		board
		. reset(
			[
				{"id": 0, "side": 0, "pos": Vector2(0.0, 6.0)},
				{"id": 1, "side": 1, "pos": Vector2(0.0, 5.0)},
			]
		)
	)
	board.fire(ShotCommand.create(0, 0, Vector2.UP, 0.4))
	await wait_for_signal(board.shot_resolved, 30.0)
	assert_eq(Sfx.played.count(Sfx.Event.HIT), 1, "one hit, not one per marble")


func test_a_marble_striking_the_wall_is_heard() -> void:
	var parts: Array = await _board_with_director()
	var board: Board = parts[0]
	await board.reset([{"id": 0, "side": 0, "pos": Vector2(0.0, 6.0)}])
	board.fire(ShotCommand.create(0, 0, Vector2.RIGHT, 0.7))
	await wait_for_signal(board.shot_resolved, 30.0)
	assert_gt(Sfx.played.count(Sfx.Event.WALL), 0)


func test_a_marble_dropping_into_a_hole_is_heard_once() -> void:
	var parts: Array = await _board_with_director()
	var board: Board = parts[0]
	var profile: RuleProfile = parts[2]
	var hole := profile.holes[1]
	await board.reset([{"id": 0, "side": 0, "pos": hole + Vector2(0.0, 1.6)}])
	board.fire(ShotCommand.create(0, 0, Vector2.UP, 0.22))
	await wait_for_signal(board.shot_resolved, 30.0)
	assert_eq(Sfx.played.count(Sfx.Event.DROP), 1)
	assert_true(board.snapshot().is_inside(0, hole, profile.hole_radius))


func test_a_shot_is_heard_and_the_end_of_the_match_has_its_own_sound() -> void:
	var parts: Array = await _board_with_director()
	var controller: MatchController = parts[1]
	controller.setup = MatchSetup.solo()
	controller.shot_started.emit(0)
	controller.match_over.emit([0, 1] as Array[int])
	controller.match_over.emit([1, 0] as Array[int])
	assert_eq(Sfx.played.count(Sfx.Event.SHOT), 1)
	assert_eq(Sfx.played.count(Sfx.Event.WIN), 1, "the player came first")
	assert_eq(Sfx.played.count(Sfx.Event.LOSE), 1, "the player came second")


func test_pass_and_play_marks_the_hand_over_and_each_turn_but_alone_it_is_quiet() -> void:
	var parts: Array = await _board_with_director()
	var controller: MatchController = parts[1]
	controller.setup = MatchSetup.pass_and_play(3)
	controller.handover_needed.emit(1)
	controller.turn_started.emit(1, true)
	assert_eq(Sfx.played.count(Sfx.Event.PASS), 1)
	assert_eq(Sfx.played.count(Sfx.Event.TURN), 1)
	Sfx.played.clear()
	controller.setup = MatchSetup.solo()
	controller.turn_started.emit(0, true)
	assert_eq(Sfx.played.count(Sfx.Event.TURN), 0, "no tock when one person plays")


func test_each_side_has_a_higher_tock_than_the_one_before() -> void:
	for side in range(1, SideStyle.MAX_SIDES):
		assert_gt(Sfx.pitch_for_side(side), Sfx.pitch_for_side(side - 1))
	assert_almost_eq(Sfx.pitch_for_side(0), 1.0, 0.0001)
