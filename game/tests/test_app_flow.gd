extends PhysicsTest
## The shell moves from the menu to a match without errors and the player can start a toss.

var app: App


func before_each() -> void:
	MatchScene.coach_seen = true
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


func test_the_about_page_has_the_text_from_the_data_file() -> void:
	assert_gt(Copy.about().size(), 3, "about sections load")
	assert_gt(Copy.how_to_play().size(), 2, "how to play sections load")
	assert_string_contains(Copy.about()[1][1], "Nothing here is invented from nothing")


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
