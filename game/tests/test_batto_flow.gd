extends PhysicsTest
## A Batto match through the real physics: the opening toss, the race, and computer sides that
## play to an end.

var board: Board
var match_controller: MatchController
var profile: RuleProfile


func before_each() -> void:
	profile = RuleProfile.batto()
	board = Board.new(profile)
	add_child_autofree(board)
	match_controller = MatchController.new()
	add_child_autofree(match_controller)
	match_controller.ai_delay = 0.05
	match_controller.cue_delay = 0.05
	await wait_physics_frames(3)


func test_the_opening_tosses_leave_every_marble_where_it_lands_and_start_the_race() -> void:
	match_controller.start(board, profile, BattoRules.new(), MatchSetup.computers_only(3), 321)
	for toss in 3:
		await wait_for_signal(match_controller.shot_judged, 30.0)
	await wait_for_signal(match_controller.turn_started, 5.0)
	var state := match_controller.state as BattoState
	assert_false(state.opening, "the race has begun")
	assert_eq(board.marble_count(), 3, "all three marbles stayed on the ground")
	assert_eq(state.order.size(), 3)


func test_a_race_turn_starts_from_where_the_marble_rests() -> void:
	match_controller.start(board, profile, BattoRules.new(), MatchSetup.solo(2), 11)
	assert_true(match_controller.submit_shot(ShotCommand.create(0, 0, Vector2.UP, 0.3)))
	var rested := [Vector2.ZERO]
	var judged := [0]
	match_controller.shot_judged.connect(
		func(_s: int, _r: RuleResult) -> void:
			judged[0] += 1
			if judged[0] == 3:
				rested[0] = board.snapshot().position_of(0)
	)
	for toss in 3:
		await wait_for_signal(match_controller.shot_judged, 30.0)
	await wait_for_signal(match_controller.turn_started, 5.0)
	var side := match_controller.current_side()
	var at := board.snapshot().position_of(0)
	assert_lt(at.distance_to(rested[0]), 0.01, "side 0 was not put back on the line")
	assert_eq(board.marble_count(), 3)
	assert_true(side >= 0)


func test_computer_sides_race_to_the_end_and_everyone_is_ranked() -> void:
	# A shorter route and a turn cap keep this quick; the rules are the same.
	profile.route = PackedInt32Array([0, 1])
	profile.turn_cap = 14
	match_controller.start(board, profile, BattoRules.new(), MatchSetup.computers_only(3), 2468)
	var shots := [0]
	match_controller.shot_judged.connect(func(_s: int, _r: RuleResult) -> void: shots[0] += 1)
	await wait_for_signal(match_controller.match_over, 900.0)
	assert_eq(match_controller.phase, MatchController.Phase.MATCH_OVER)
	var ranking := BattoRules.new().ranking(match_controller.state)
	assert_eq(ranking.size(), profile.side_count, "every side is ranked")
	for side in profile.side_count:
		assert_eq(ranking.count(side), 1, "side %d appears once" % side)
	gut.p("Batto with computer sides: %d shots judged, ranking %s" % [shots[0], ranking])


func test_the_computer_chooses_between_a_hole_and_a_hit() -> void:
	var ai := BattoAI.new(5)
	var state := BattoRules.new().start(profile, 3) as BattoState
	state.opening = false
	var snap := BoardSnapshot.new()
	snap.add(0, 0, Vector2(0.0, profile.jalla_z))
	snap.add(1, 1, Vector2(1.0, 15.5))
	snap.add(2, 2, Vector2(-3.0, -8.0))
	state.progress[1] = 2
	var at_hole := 0
	var at_rival := 0
	for i in 60:
		var cmd := ai.choose(state, profile, snap, 0)
		var to_hole := (profile.holes[0] - snap.position_of(0)).normalized()
		var to_rival := (snap.position_of(1) - snap.position_of(0)).normalized()
		if cmd.direction.dot(to_hole) > cmd.direction.dot(to_rival):
			at_hole += 1
		else:
			at_rival += 1
	gut.p("AI choices over 60 turns: %d at the hole, %d at a rival" % [at_hole, at_rival])
	assert_gt(at_hole, 0, "it goes for the hole")
	assert_gt(at_rival, 0, "and sometimes for a hit")


func test_the_computer_never_aims_at_a_marble_down_in_a_hole() -> void:
	var ai := BattoAI.new(8)
	var state := BattoRules.new().start(profile, 3) as BattoState
	state.opening = false
	state.progress[1] = 3
	var snap := BoardSnapshot.new()
	snap.add(0, 0, Vector2(2.0, 0.8))
	snap.add(1, 1, profile.holes[1])
	snap.add(2, 2, Vector2(-3.0, -9.0))
	var to_hole := (profile.holes[0] - snap.position_of(0)).normalized()
	for i in 40:
		var cmd := ai.choose(state, profile, snap, 0)
		assert_gt(cmd.direction.dot(to_hole), 0.9, "turn %d goes for its own hole" % i)


func test_after_a_bonus_shot_the_computer_gets_on_with_the_route() -> void:
	var ai := BattoAI.new(3)
	var state := BattoRules.new().start(profile, 3) as BattoState
	state.opening = false
	state.progress[1] = 3
	state.bonus_chain = 2
	var snap := BoardSnapshot.new()
	snap.add(0, 0, Vector2(0.0, 9.0))
	snap.add(1, 1, Vector2(0.8, 8.0))
	snap.add(2, 2, Vector2(-3.0, -9.0))
	var to_hole := (profile.holes[0] - snap.position_of(0)).normalized()
	var at_hole := 0
	for i in 40:
		if ai.choose(state, profile, snap, 0).direction.dot(to_hole) > 0.9:
			at_hole += 1
	assert_gt(at_hole, 34, "it mostly goes for the hole, not another hit")
