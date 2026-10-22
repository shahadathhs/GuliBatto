extends PhysicsTest
## Pass and play: every side is a person, the device is handed round, and each game runs to its
## end with two and with five people.

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


func test_the_first_turn_waits_for_the_device_to_be_handed_over() -> void:
	await _setup(RuleProfile.kep())
	match_controller.start(board, profile, KepRules.new(), MatchSetup.pass_and_play(3), 5)
	await wait_physics_frames(3)
	assert_eq(match_controller.phase, MatchController.Phase.HANDOVER)
	assert_false(match_controller.is_human_turn(), "nobody may shoot before the hand-over")
	var command := ShotCommand.create(0, 0, Vector2(0.0, -1.0), 0.5)
	assert_false(match_controller.submit_shot(command), "a shot before the hand-over is refused")
	match_controller.confirm_handover()
	assert_eq(match_controller.phase, MatchController.Phase.WAITING_FOR_SHOT)
	assert_true(match_controller.is_human_turn())


func test_only_the_side_whose_turn_it_is_can_shoot() -> void:
	await _setup(RuleProfile.kep())
	match_controller.start(board, profile, KepRules.new(), MatchSetup.pass_and_play(3), 5)
	await wait_physics_frames(3)
	match_controller.confirm_handover()
	var side := match_controller.current_side()
	var other := (side + 1) % 3
	assert_false(
		match_controller.submit_shot(ShotCommand.create(other, other, Vector2(0.0, -1.0), 0.5)),
		"another side's marble cannot be shot"
	)
	assert_true(
		match_controller.submit_shot(ShotCommand.create(side, side, Vector2(0.0, -1.0), 0.5))
	)


func test_a_new_person_is_asked_to_take_the_device_before_each_turn() -> void:
	await _setup(RuleProfile.kep())
	var driver := PeopleDriver.new(match_controller, board, KepRules.new(), profile)
	add_child_autofree(driver)
	match_controller.start(board, profile, KepRules.new(), MatchSetup.pass_and_play(3), 5)
	await wait_physics_frames(3)
	for toss in 3:
		await wait_for_signal(match_controller.shot_judged, 30.0)
	await wait_for_signal(match_controller.round_scored, 30.0)
	assert_gte(driver.handovers.size(), 3, "one hand-over for each of the three tosses")
	var distinct := {}
	for side in driver.handovers.slice(0, 3):
		distinct[side] = true
	assert_eq(distinct.size(), 3, "each of the three people took the device in turn")


func test_there_are_no_computer_sides_in_pass_and_play() -> void:
	await _setup(RuleProfile.kep())
	match_controller.start(board, profile, KepRules.new(), MatchSetup.pass_and_play(4), 5)
	await wait_physics_frames(3)
	for side in 4:
		assert_true(match_controller.setup.is_human(side))
	assert_eq(match_controller._ai.size(), 0)


func test_ending_a_batto_match_early_ranks_every_side() -> void:
	await _setup(RuleProfile.batto())
	match_controller.start(board, profile, BattoRules.new(), MatchSetup.pass_and_play(4), 5)
	await wait_physics_frames(3)
	match_controller.confirm_handover()
	var ranking: Array[int] = []
	match_controller.match_over.connect(func(r: Array[int]) -> void: ranking.assign(r))
	assert_true(match_controller.give_up(), "pass and play can always be ended")
	assert_eq(match_controller.phase, MatchController.Phase.MATCH_OVER)
	assert_eq(ranking.size(), 4)
	for side in 4:
		assert_eq(ranking.count(side), 1)


func test_kep_runs_to_the_end_with_two_and_with_five_people() -> void:
	for people in [2, 5]:
		await _full_match(RuleProfile.kep(), KepRules.new(), people, 11)


func test_batto_runs_to_the_end_with_two_and_with_five_people() -> void:
	for people in [2, 5]:
		await _full_match(RuleProfile.batto(), BattoRules.new(), people, 22)


func test_guli_khela_runs_to_the_end_with_two_and_with_five_people() -> void:
	for people in [2, 5]:
		var p := RuleProfile.guli()
		p.dan_limit = 2
		await _full_match(p, GuliRules.new(), people, 33)


func test_quick_dan_runs_to_the_end_with_two_and_with_five_people() -> void:
	for people in [2, 5]:
		await _full_match(RuleProfile.quick_dan(), GuliRules.new(), people, 44)


## Plays a whole pass-and-play match and checks that every side is ranked once.
func _full_match(p: RuleProfile, rules: RuleSet, people: int, seed_value: int) -> void:
	await _setup(p)
	var driver := PeopleDriver.new(match_controller, board, rules, p)
	add_child_autofree(driver)
	match_controller.start(board, p, rules, MatchSetup.pass_and_play(people), seed_value)
	await wait_for_signal(match_controller.match_over, 900.0)
	var ranking := rules.ranking(match_controller.state)
	assert_eq(ranking.size(), people, "%s with %d people ranks every side" % [p.mode_id, people])
	for side in people:
		assert_eq(ranking.count(side), 1)
	assert_gt(driver.handovers.size(), 0, "the device was handed round")
	if match_controller.state is GuliState:
		var s := match_controller.state as GuliState
		var total := s.pot
		for purse in s.totals:
			total += purse
		assert_eq(total, p.purse * people, "every marble is in a purse or on the ground")


func test_five_people_stand_apart_on_the_line_in_every_game() -> void:
	for p in [RuleProfile.kep(), RuleProfile.batto(), RuleProfile.guli()]:
		var spots: Array[Vector2] = []
		for side in 5:
			spots.append(TossLine.spawn(side, 5, p, BoardSnapshot.new()))
		for i in spots.size():
			for j in range(i + 1, spots.size()):
				assert_gt(
					spots[i].distance_to(spots[j]),
					p.marble_radius * 2.0,
					"%s: sides %d and %d do not overlap" % [p.mode_id, i, j]
				)


func test_the_stake_of_five_sides_fits_round_the_kep() -> void:
	var p := RuleProfile.guli()
	var rng := RandomNumberGenerator.new()
	rng.seed = 9
	var spots := StakeLayout.scatter(p.stake * 5, Vector2.ZERO, p, rng, [] as Array[Vector2])
	assert_eq(spots.size(), 15)
	for i in spots.size():
		assert_lt(spots[i].length(), Tuning.ARENA_RADIUS - 0.2, "inside the ground")
		for j in range(i + 1, spots.size()):
			assert_gt(spots[i].distance_to(spots[j]), p.marble_radius * 2.0, "no two overlap")
