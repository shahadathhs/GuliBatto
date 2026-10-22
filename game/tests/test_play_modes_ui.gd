extends GutTest
## The screens of the play modes: choosing who plays, the hand-over, and the words for people.

var app: App


func before_each() -> void:
	Settings.path = PhysicsTest.TEST_SETTINGS
	DirAccess.remove_absolute(Settings.path)
	Settings.load_from_disk()
	Settings.mark_coach_seen()
	for id in ModeRegistry.ORDER:
		Settings.mark_rules_seen(id)
	app = App.new()
	add_child_autofree(app)
	await wait_physics_frames(3)


func after_each() -> void:
	get_tree().paused = false
	DirAccess.remove_absolute(Settings.path)
	Settings.path = Settings.DEFAULT_PATH
	Settings.load_from_disk()


func _who() -> WhoPlaysScreen:
	app._choose_players(&"kep")
	await wait_physics_frames(2)
	return app._screen as WhoPlaysScreen


func test_the_screen_starts_on_the_remembered_choice() -> void:
	Settings.remember_setup(MatchSetup.Kind.PASS_AND_PLAY, 1, 4)
	var s := await _who()
	assert_true(s.setup().hands_over())
	assert_eq(s.setup().side_count, 4)


func test_the_counts_stay_within_their_limits() -> void:
	var s := await _who()
	for i in 6:
		s.step(MatchSetup.Kind.COMPUTERS, 1)
	assert_eq(s.setup().side_count, 4, "you and three computers at most")
	for i in 6:
		s.step(MatchSetup.Kind.PASS_AND_PLAY, 1)
	assert_eq(s.setup().side_count, 5, "five people at most")
	for i in 6:
		s.step(MatchSetup.Kind.PASS_AND_PLAY, -1)
	assert_eq(s.setup().side_count, 2, "two people at least")


func test_choosing_is_remembered_for_next_time() -> void:
	var s := await _who()
	s.step(MatchSetup.Kind.PASS_AND_PLAY, 1)
	Settings.load_from_disk()
	assert_eq(Settings.play_kind, MatchSetup.Kind.PASS_AND_PLAY)
	assert_eq(Settings.people, 4)


func test_play_starts_a_match_for_the_chosen_people() -> void:
	var s := await _who()
	s.select(MatchSetup.Kind.PASS_AND_PLAY)
	s.play_pressed.emit(s.setup())
	await wait_physics_frames(4)
	assert_not_null(app._match)
	assert_eq(app._match.controller.setup.side_count, 3)
	assert_true(app._screen is HandoverScreen, "the first person is asked to take the device")


func test_ready_hands_the_turn_to_the_person() -> void:
	app._setup = MatchSetup.pass_and_play(2)
	app._start_match(&"kep")
	await wait_physics_frames(4)
	assert_true(app._screen is HandoverScreen)
	assert_false(app._match.controller.is_human_turn())
	(app._screen as HandoverScreen).ready_pressed.emit()
	await wait_physics_frames(2)
	assert_null(app._screen, "the hand-over screen is gone")
	assert_true(app._match.controller.is_human_turn())


func test_the_pause_menu_ends_a_pass_and_play_match_instead_of_surrender() -> void:
	app._setup = MatchSetup.pass_and_play(3)
	app._start_match(&"kep")
	await wait_physics_frames(3)
	assert_eq(app._give_up_label(), "End the match")
	app._setup = MatchSetup.solo(2)
	app._start_match(&"guli")
	await wait_physics_frames(3)
	assert_eq(app._give_up_label(), "Surrender")
	app._start_match(&"kep")
	await wait_physics_frames(3)
	assert_eq(app._give_up_label(), "", "Kep against the computer cannot be given up")


func test_the_turn_label_names_the_side_in_pass_and_play() -> void:
	app._setup = MatchSetup.pass_and_play(3)
	app._start_match(&"kep")
	await wait_physics_frames(3)
	(app._screen as HandoverScreen).ready_pressed.emit()
	await wait_physics_frames(2)
	var side := app._match.controller.current_side()
	var text := app._match.rules.turn_text(
		app._match.controller.state, app._match.setup.owner_word(side)
	)
	assert_eq(text, "%s's toss" % SideStyle.side_name(side))


func test_the_end_screen_names_the_winner_in_pass_and_play_and_says_you_alone() -> void:
	var ranking: Array[int] = [3, 0, 4, 1, 2]
	var details: Array[String] = ["a", "b", "c", "d", "e"]
	var party := MatchOverScreen.new(ranking, details, MatchSetup.pass_and_play(5))
	var one: Array[int] = [1, 0, 2]
	var lines: Array[String] = ["a", "b", "c"]
	var alone := MatchOverScreen.new(one, lines, MatchSetup.solo())
	add_child_autofree(party)
	add_child_autofree(alone)
	var texts := func(root: Node) -> PackedStringArray:
		var out := PackedStringArray()
		for l in root.find_children("*", "Label", true, false):
			out.append((l as Label).text)
		return out
	assert_true(texts.call(party).has("PLUM WON"))
	assert_true(texts.call(alone).has("YOU CAME SECOND"))


func test_the_hand_over_screen_names_the_side() -> void:
	var s := HandoverScreen.new(4, "Kep · round 1 of 5")
	add_child_autofree(s)
	await wait_physics_frames(2)
	var found := false
	for l in s.find_children("*", "Label", true, false):
		if (l as Label).text == "ROSE":
			found = true
	assert_true(found)
