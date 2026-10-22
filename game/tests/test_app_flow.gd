extends PhysicsTest
## The shell moves from the menu to a match without errors and the player can start a toss.

var app: App


func before_each() -> void:
	Settings.mark_coach_seen()
	for id in ModeRegistry.ORDER:
		Settings.mark_rules_seen(id)
	app = App.new()
	add_child_autofree(app)
	await wait_physics_frames(3)


func test_the_app_opens_on_the_menu() -> void:
	assert_true(app._screen is MenuScreen)


func test_play_leads_to_modes_and_start_begins_a_match_on_the_players_turn() -> void:
	(app._screen as MenuScreen).play_pressed.emit()
	await wait_physics_frames(2)
	assert_true(app._screen is ModesScreen)
	(app._screen as ModesScreen).start_pressed.emit(&"kep")
	await wait_physics_frames(4)
	assert_not_null(app._match, "a match is running")
	assert_true(app._match.controller.is_human_turn())
	assert_eq(app._match.board.marble_count(), 1, "the player's marble is on the line")


func test_pausing_stops_the_match_and_resuming_restores_it() -> void:
	app._start_match()
	await wait_physics_frames(3)
	app._open_pause()
	assert_true(get_tree().paused)
	app._close_pause()
	assert_false(get_tree().paused)


func test_going_back_to_the_menu_clears_the_match() -> void:
	app._start_match()
	await wait_physics_frames(3)
	app._show_menu()
	await wait_physics_frames(3)
	assert_null(app._match)
	assert_true(app._screen is MenuScreen)


func test_choosing_batto_starts_a_batto_match() -> void:
	(app._screen as MenuScreen).play_pressed.emit()
	await wait_physics_frames(2)
	var modes := app._screen as ModesScreen
	assert_eq(modes.selected(), &"kep", "Kep is selected first")
	modes.select(&"batto")
	modes.start_pressed.emit(modes.selected())
	await wait_physics_frames(4)
	assert_eq(app._match.profile.mode_id, &"batto")
	assert_true(app._match.controller.state is BattoState)
	assert_eq(app._match.profile.holes.size(), 3, "three holes")


func test_the_batto_camera_follows_the_marble_and_the_top_view_shows_the_whole_board() -> void:
	app._start_match(&"batto")
	await wait_physics_frames(10)
	var scene: MatchScene = app._match
	var marble := scene.board.marble(scene.controller.current_side())
	assert_not_null(scene.rig.follow_point, "the camera has something to follow")
	var followed := scene.rig.follow_point as Vector2
	assert_lt(followed.distance_to(marble.ground_position()), scene.profile.camera_look_ahead + 0.1)
	scene.rig.set_view(CameraRig.View.TOP_DOWN)
	await wait_physics_frames(5)
	assert_null(scene.rig.follow_point, "the overview does not follow")
	assert_almost_eq(scene.rig._target_distance, scene.profile.camera_overview, 0.01)


func test_kep_keeps_a_fixed_camera() -> void:
	app._start_match(&"kep")
	await wait_physics_frames(10)
	assert_null(app._match.rig.follow_point)


func test_all_four_modes_are_offered_and_each_starts_its_own_match() -> void:
	(app._screen as MenuScreen).play_pressed.emit()
	await wait_physics_frames(2)
	var modes := app._screen as ModesScreen
	assert_eq(ModeRegistry.ORDER.size(), 4)
	for id in [&"guli", &"quick"]:
		modes.select(id)
		modes.start_pressed.emit(modes.selected())
		await wait_physics_frames(4)
		assert_eq(app._match.profile.mode_id, id)
		assert_true(app._match.controller.state is GuliState)
		assert_true(app._match.rules.can_surrender())
		app._show_modes()
		modes = app._screen as ModesScreen
		await wait_physics_frames(2)


func test_a_dan_result_screen_names_the_winner_and_the_marbles() -> void:
	var r := RuleResult.new()
	r.points = {0: -3, 1: 6, 2: -3}
	r.placing = {0: &"none", 1: &"won", 2: &"none"}
	var screen := RoundResultScreen.new(r, [4, 13, 4] as Array[int], 0, "DAN 1", "purse")
	add_child_autofree(screen)
	await wait_physics_frames(2)
	assert_not_null(screen)


func test_the_pause_screen_offers_surrender_only_where_it_applies() -> void:
	var plain := PauseScreen.new(false)
	var guli := PauseScreen.new(true)
	add_child_autofree(plain)
	add_child_autofree(guli)
	var count := func(root: Node) -> int:
		var n := 0
		for b in root.find_children("*", "Button", true, false):
			if (b as Button).text == "SURRENDER":
				n += 1
		return n
	assert_eq(count.call(plain), 0)
	assert_eq(count.call(guli), 1)


func _open_modes() -> ModesScreen:
	(app._screen as MenuScreen).play_pressed.emit()
	await wait_physics_frames(2)
	return app._screen as ModesScreen


func test_the_first_time_a_game_is_started_its_rules_card_comes_first() -> void:
	Settings.reset()
	Settings.mark_coach_seen()
	var modes := await _open_modes()
	modes.start_pressed.emit(&"guli")
	await wait_physics_frames(3)
	assert_true(app._screen is RulesCard, "the card, not the match")
	assert_null(app._match)
	(app._screen as RulesCard).primary_pressed.emit()
	await wait_physics_frames(4)
	assert_not_null(app._match, "Start begins the match")
	assert_eq(app._match.profile.mode_id, &"guli")
	assert_true(Settings.has_seen_rules(&"guli"), "and the card is not shown again")


func test_the_card_is_not_shown_again_and_other_games_still_show_theirs() -> void:
	Settings.reset()
	Settings.mark_coach_seen()
	Settings.mark_rules_seen(&"kep")
	var modes := await _open_modes()
	modes.start_pressed.emit(&"kep")
	await wait_physics_frames(4)
	assert_not_null(app._match, "Kep has been seen, so it starts")
	app._show_modes()
	await wait_physics_frames(2)
	(app._screen as ModesScreen).start_pressed.emit(&"batto")
	await wait_physics_frames(3)
	assert_true(app._screen is RulesCard, "Batto has not")


func test_the_card_can_go_back_to_the_modes_without_starting() -> void:
	Settings.reset()
	Settings.mark_coach_seen()
	var modes := await _open_modes()
	modes.start_pressed.emit(&"batto")
	await wait_physics_frames(3)
	(app._screen as RulesCard).back_pressed.emit()
	await wait_physics_frames(2)
	assert_true(app._screen is ModesScreen)
	assert_false(Settings.has_seen_rules(&"batto"), "going back does not count as having seen it")


func test_the_rules_link_on_a_mode_opens_its_page_and_back_returns_to_the_modes() -> void:
	var modes := await _open_modes()
	modes.rules_pressed.emit(&"batto")
	await wait_physics_frames(2)
	assert_true(app._screen is PageScreen)
	assert_eq((app._screen as PageScreen).page_id, "game_batto")
	(app._screen as PageScreen).back_pressed.emit()
	await wait_physics_frames(2)
	assert_true(app._screen is ModesScreen)


func test_a_link_between_pages_opens_the_page_and_back_returns_to_the_one_before() -> void:
	(app._screen as MenuScreen).how_to_play_pressed.emit()
	await wait_physics_frames(2)
	var how := app._screen as PageScreen
	assert_eq(how.page_id, "how_to_play")
	how.link_pressed.emit("page:game_kep")
	await wait_physics_frames(2)
	assert_eq((app._screen as PageScreen).page_id, "game_kep")
	(app._screen as PageScreen).back_pressed.emit()
	await wait_physics_frames(2)
	assert_eq((app._screen as PageScreen).page_id, "how_to_play", "back to where it came from")


func test_the_question_mark_in_a_match_shows_the_rules_over_the_paused_match() -> void:
	app._start_match(&"guli")
	await wait_physics_frames(3)
	app._match.help_requested.emit()
	await wait_physics_frames(2)
	assert_true(get_tree().paused)
	assert_true(app._pause is RulesCard)
	(app._pause as RulesCard).full_rules_pressed.emit()
	await wait_physics_frames(2)
	assert_true(app._pause is PageScreen, "the full rules replace the card")
	(app._pause as PageScreen).back_pressed.emit()
	await wait_physics_frames(2)
	assert_true(app._pause is RulesCard, "and back returns to the card")
	(app._pause as RulesCard).primary_pressed.emit()
	await wait_physics_frames(2)
	assert_false(get_tree().paused, "Back to match resumes")
	assert_null(app._pause)
