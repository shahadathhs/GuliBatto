extends PhysicsTest
## A whole Kep match through the real physics, with computer sides, must finish and score.

var board: Board
var match_controller: MatchController
var profile: RuleProfile


func before_each() -> void:
	profile = RuleProfile.kep()
	board = Board.new(profile)
	add_child_autofree(board)
	match_controller = MatchController.new()
	add_child_autofree(match_controller)
	match_controller.ai_delay = 0.05
	match_controller.cue_delay = 0.05
	match_controller.auto_continue = true
	await wait_physics_frames(3)


func test_three_computer_sides_play_five_rounds_to_the_end() -> void:
	var scored: Array[int] = []
	match_controller.round_scored.connect(
		func(_r: RuleResult, _t: Array[int]) -> void: scored.append(1)
	)
	match_controller.start(board, profile, KepRules.new(), -1, 1234)
	await wait_for_signal(match_controller.match_over, 600.0)
	assert_eq(match_controller.phase, MatchController.Phase.MATCH_OVER)
	assert_eq(scored.size(), profile.rounds, "every round was scored once")
	var total := 0
	for t in match_controller.state.totals:
		total += t
	assert_gt(total, 0, "somebody scored")
	assert_lte(total, profile.rounds * 3 * profile.side_count, "no more than the best possible")
	assert_eq(match_controller.state.ranking().size(), profile.side_count)


func test_the_player_can_only_shoot_on_their_own_turn() -> void:
	match_controller.start(board, profile, KepRules.new(), 1, 99)
	await wait_for_signal(match_controller.turn_started, 5.0)
	# Side 0 is first and is a computer, so a shot from the player (side 1) is refused.
	var shot := ShotCommand.create(1, 1, Vector2.UP, 0.5)
	assert_false(match_controller.submit_shot(shot), "not the player's turn yet")


func test_a_human_toss_is_taken_and_the_next_side_follows() -> void:
	match_controller.start(board, profile, KepRules.new(), 0, 7)
	assert_true(match_controller.is_human_turn(), "side 0 goes first and is the player")
	var shot := ShotCommand.create(
		0, 0, (profile.holes[0] - board.marble(0).ground_position()).normalized(), 0.55
	)
	assert_true(match_controller.submit_shot(shot))
	assert_eq(match_controller.phase, MatchController.Phase.SHOT_IN_FLIGHT)
	assert_false(match_controller.submit_shot(shot), "no second shot while it rolls")
	await wait_for_signal(match_controller.shot_judged, 30.0)
	await wait_for_signal(match_controller.turn_started, 5.0)
	assert_eq(match_controller.current_side(), 1, "the next side is up")
	assert_false(match_controller.is_human_turn())


func test_the_ai_sometimes_lands_in_the_kep_and_sometimes_misses() -> void:
	var ai := TossAI.new(42)
	var in_kep := 0
	var out := 0
	var probe := Board.new(profile)
	add_child_autofree(probe)
	await wait_physics_frames(3)
	for i in 14:
		var from := Vector2(0.0, Tuning.JALLA_Z + 0.28)
		await probe.reset([{"id": 0, "side": 0, "pos": from}])
		probe.fire(ai.choose_toss(0, 0, from, profile.holes[0]))
		await wait_for_signal(probe.shot_resolved, 30.0)
		if probe.marble(0).ground_position().distance_to(profile.holes[0]) <= Tuning.KEP_RADIUS:
			in_kep += 1
		else:
			out += 1
	gut.p("AI over 14 tosses: %d in the kep, %d out" % [in_kep, out])
	assert_gt(in_kep, 0, "it can score")
	assert_gt(out, 0, "and it can miss")
