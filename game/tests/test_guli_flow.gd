extends PhysicsTest
## Guli Khela through the real physics: matches with computer sides, and the player's baad.

var board: Board
var match_controller: MatchController
var profile: RuleProfile


func _setup(p: RuleProfile) -> void:
	profile = p
	board = Board.new(profile)
	add_child_autofree(board)
	match_controller = MatchController.new()
	add_child_autofree(match_controller)
	match_controller.ai_delay = 0.05
	match_controller.cue_delay = 0.05
	match_controller.auto_continue = true
	await wait_physics_frames(3)


func test_computer_sides_play_a_match_and_no_marble_is_lost() -> void:
	var p := RuleProfile.guli()
	p.dan_limit = 3
	await _setup(p)
	var dans := [0]
	match_controller.round_scored.connect(
		func(_r: RuleResult, _t: Array[int]) -> void: dans[0] += 1
	)
	match_controller.start(board, profile, GuliRules.new(), MatchSetup.computers_only(3), 4242)
	await wait_for_signal(match_controller.match_over, 900.0)
	var s := match_controller.state as GuliState
	var rules := GuliRules.new()
	var ranking := rules.ranking(s)
	assert_eq(ranking.size(), 3)
	for side in 3:
		assert_eq(ranking.count(side), 1)
	var total := 0
	for purse in s.totals:
		total += purse
	assert_eq(total + s.pot, profile.purse * 3, "every marble is in a purse or on the ground")
	assert_eq(s.dan_index, 3, "three dans were played")
	gut.p("Guli Khela, computer sides: %d dans, purses %s" % [dans[0], s.totals])


func test_quick_dan_with_computer_sides_ends_after_one_dan() -> void:
	await _setup(RuleProfile.quick_dan())
	match_controller.start(board, profile, GuliRules.new(), MatchSetup.computers_only(3), 77)
	await wait_for_signal(match_controller.match_over, 600.0)
	var s := match_controller.state as GuliState
	assert_eq(s.dan_index, 1)
	assert_eq(GuliRules.new().ranking(s).size(), 3)


func test_the_stake_appears_round_the_kep_after_the_opening_tosses() -> void:
	await _setup(RuleProfile.guli())
	match_controller.start(board, profile, GuliRules.new(), MatchSetup.computers_only(3), 5)
	for toss in 3:
		await wait_for_signal(match_controller.shot_judged, 30.0)
	await wait_for_signal(match_controller.turn_started, 5.0)
	var neutral := 0
	for m in board.marbles():
		if m.side == SideStyle.NEUTRAL:
			neutral += 1
	assert_eq(neutral, 9, "the stake of three sides, three marbles each")
	assert_lte(
		board.marble_count(), 9 + 1, "the tossed marbles went home, one throw is on the line"
	)


func test_the_computer_names_a_baad_and_sometimes_wins_and_sometimes_fines() -> void:
	var p := RuleProfile.guli()
	await _setup(p)
	var ai := GuliAI.new(31)
	var state := GuliRules.new().start(p, 2) as GuliState
	state.stage = GuliState.Stage.PASSES
	var spots: Array[Vector2] = StakeLayout.scatter(
		6, state.kep, p, state.rng, [] as Array[Vector2]
	)
	var snap := BoardSnapshot.new()
	var from := Vector2(0.0, Tuning.JALLA_Z + 0.28)
	snap.add(1, 1, from)
	for i in spots.size():
		state.ground.append(100 + i)
		snap.add(100 + i, SideStyle.NEUTRAL, spots[i])
	var outcomes := {"win": 0, "fine": 0, "miss": 0}
	for i in 12:
		var cmd := ai.choose(state, p, snap, 1)
		assert_true(state.ground.has(cmd.baad_marble_id), "it names a marble on the ground")
		await board.reset(_board_layout(from, spots))
		board.fire(cmd)
		await wait_for_signal(board.shot_resolved, 30.0)
		var touched := 0
		for id in board.report.touched:
			if state.ground.has(id):
				touched += 1
		if touched == 1 and not board.report.has_touched(cmd.baad_marble_id):
			outcomes["win"] += 1
		elif touched == 0:
			outcomes["miss"] += 1
		else:
			outcomes["fine"] += 1
	gut.p("Computer attempts over 12 throws: %s" % [outcomes])
	assert_gt(outcomes["win"], 0, "it can touch exactly one")
	assert_lt(outcomes["win"], 12, "and it does not always")


func _board_layout(from: Vector2, spots: Array[Vector2]) -> Array:
	var layout: Array = [{"id": 1, "side": 1, "pos": from}]
	for i in spots.size():
		layout.append({"id": 100 + i, "side": SideStyle.NEUTRAL, "pos": spots[i]})
	return layout


## Runs the match until it is the player's turn to name a baad. The player tosses weakly, so one of
## the computer sides is closest and scatters.
func _until_the_player_must_name_a_baad() -> void:
	var needed := [false]
	match_controller.baad_needed.connect(func() -> void: needed[0] = true)
	match_controller.start(board, profile, GuliRules.new(), MatchSetup.solo(2), 90)
	for step in 600:
		if needed[0]:
			return
		if match_controller.is_human_turn():
			# A weak toss that stops short, so one of the computer sides is closest and scatters.
			match_controller.submit_shot(ShotCommand.create(0, 0, Vector2.UP, 0.12))
		await wait_physics_frames(10)
	fail_test("the player was never asked to name a baad")


func test_the_player_must_name_a_baad_before_throwing() -> void:
	await _setup(RuleProfile.guli())
	await _until_the_player_must_name_a_baad()
	assert_eq(match_controller.phase, MatchController.Phase.WAITING_FOR_BAAD)
	assert_false(match_controller.is_human_turn(), "no aiming yet")
	var throw := ShotCommand.create(0, 0, Vector2.UP, 0.5)
	assert_false(match_controller.submit_shot(throw), "a throw with no baad is refused")
	assert_false(match_controller.name_baad(0), "a side's own marble cannot be the baad")
	assert_false(match_controller.name_baad(9999), "nor a marble that is not there")
	var choices := match_controller.baad_choices()
	assert_eq(choices.size(), 9)
	var named := [-1]
	match_controller.baad_named.connect(func(id: int) -> void: named[0] = id)
	assert_true(match_controller.name_baad(choices[2]))
	assert_eq(named[0], choices[2])
	assert_true(match_controller.is_human_turn(), "now the marble can be thrown")
	assert_true(match_controller.name_baad(choices[4]), "the baad can be changed before the throw")
	assert_true(match_controller.submit_shot(throw))
	assert_eq(board.report.baad_id, choices[4], "the shot carries the baad that was last named")


func test_giving_up_ends_the_match_with_the_player_last() -> void:
	await _setup(RuleProfile.guli())
	match_controller.start(board, profile, GuliRules.new(), MatchSetup.solo(2), 3)
	var ranking: Array[int] = []
	match_controller.match_over.connect(func(r: Array[int]) -> void: ranking.assign(r))
	assert_true(match_controller.surrender())
	assert_eq(match_controller.phase, MatchController.Phase.MATCH_OVER)
	assert_eq(ranking.back(), 0)
	assert_false(match_controller.surrender(), "only once")


func test_kep_and_batto_cannot_be_surrendered() -> void:
	await _setup(RuleProfile.kep())
	match_controller.start(board, profile, KepRules.new(), MatchSetup.solo(2), 3)
	assert_false(match_controller.surrender())
