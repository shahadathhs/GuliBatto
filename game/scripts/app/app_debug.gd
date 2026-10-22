class_name AppDebug
extends RefCounted
## Debug only: `godot --path game -- --screen=NAME` opens one screen so it can be photographed.
## NAME is a screen (modes, who_plays, settings, result, dan, over, over_five), a match state
## (match, aim, pause, batto, batto_aim, batto_top, guli, guli_stake, pass_to, five), `page_ID` for
## a page of the content (page_game_kep) or `card_MODE` for a rules card (card_guli).


static func open(app: App, name: String) -> void:
	var sample_points := {0: 3, 1: 2, 2: 1}
	var sample_placing := {0: &"in_kep", 1: &"closest", 2: &"second"}
	if name.begins_with("page_"):
		app._show_page(name.trim_prefix("page_"), app._show_menu)
		return
	if name.begins_with("help_"):
		app._show(RulesCard.new(StringName(name.trim_prefix("help_")), "Back to match"))
		return
	if name.begins_with("card_"):
		var mode := StringName(name.trim_prefix("card_"))
		app._show(RulesCard.new(mode, "Start", true))
		return
	match name:
		"modes":
			app._show_modes()
		"menu":
			app._show_menu()
		"about":
			app._show_page("about", app._show_menu)
		"how":
			app._show_page("how_to_play", app._show_menu)
		"settings":
			app._show_settings(app._show_menu)
		"result":
			var r := RuleResult.new()
			r.points = sample_points
			r.placing = sample_placing
			app._show(
				RoundResultScreen.new(
					r, [6, 5, 2] as Array[int], MatchSetup.solo(), "ROUND 2 OF 5", "total"
				)
			)
		"dan":
			var d := RuleResult.new()
			d.points = {0: -3, 1: 6, 2: -3}
			d.placing = {0: &"none", 1: &"won", 2: &"none"}
			app._show(
				RoundResultScreen.new(
					d, [4, 13, 4] as Array[int], MatchSetup.solo(), "DAN 1", "purse"
				)
			)
		"over":
			app._show(
				MatchOverScreen.new(
					[0, 2, 1] as Array[int],
					["13 points", "11 points", "9 points"] as Array[String],
					MatchSetup.solo()
				)
			)
		"who_plays":
			app._choose_players(&"kep")
		"pass_to":
			app._setup = MatchSetup.pass_and_play(3)
			app._start_match(&"kep")
		"five":
			app._setup = MatchSetup.pass_and_play(5)
			Settings.coach_seen = true
			app._start_match(&"kep")
			await app.get_tree().create_timer(0.4, false).timeout
			app._clear_screen()
			app._match.controller.confirm_handover()
		"over_five":
			app._show(
				MatchOverScreen.new(
					[3, 0, 4, 1, 2] as Array[int],
					["14 points", "11 points", "9 points", "7 points", "5 points"] as Array[String],
					MatchSetup.pass_and_play(5)
				)
			)
		"match", "aim", "pause", "batto", "batto_aim", "batto_top", "guli", "guli_stake":
			Settings.coach_seen = name.ends_with("aim")
			var mode := &"kep"
			if name.begins_with("batto"):
				mode = &"batto"
			elif name.begins_with("guli"):
				mode = &"guli"
			app._start_match(mode)
			if name != "match" and name != "batto":
				await app.get_tree().create_timer(0.6, false).timeout
			if name == "pause":
				app._open_pause()
			if name == "guli_stake":
				await _guli_stake(app)
			if name == "batto_top":
				app._match.rig.set_view(CameraRig.View.TOP_DOWN)
				await app.get_tree().create_timer(1.0, false).timeout
			if name.ends_with("aim"):
				await _aim(app)


## Debug only: Guli Khela at the start of the attempts, the stake scattered and one marble named.
static func _guli_stake(app: App) -> void:
	var scene: MatchScene = app._match
	var s := scene.controller.state as GuliState
	scene.board.clear_marbles()
	s.stage = GuliState.Stage.PASSES
	var order: Array[int] = [0, 1]
	s.order = order
	s.turn_index = 0
	s.scatterer = 2
	s.pot = 9
	var spots := StakeLayout.scatter(9, s.kep, scene.profile, s.rng, [] as Array[Vector2])
	for i in spots.size():
		s.ground.append(100 + i)
		scene.board.place(100 + i, SideStyle.NEUTRAL, spots[i])
	scene.controller._begin_turn()
	await app.get_tree().create_timer(0.3, false).timeout
	scene.controller.name_baad(103)


static func _aim(app: App) -> void:
	Settings.coach_seen = true
	var scene: MatchScene = app._match
	var m := scene.board.marble(0)
	var from := scene.rig.camera.unproject_position(m.global_position)
	var to := from + Vector2(20.0, 110.0)
	var transform := app.get_viewport().get_final_transform()
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = transform * from
	Input.parse_input_event(press)
	await app.get_tree().create_timer(0.2, false).timeout
	var drag := InputEventMouseMotion.new()
	drag.position = transform * to
	drag.relative = to - from
	Input.parse_input_event(drag)
