class_name App
extends Node
## The shell: shows the menu and the pages, starts a match, and moves between the match, its
## result screens and back. One screen is on the UI layer at a time; a match lives beside it.

var _layer: CanvasLayer
var _screen: Control
var _match: MatchScene
var _mode: StringName = &"kep"
var _pause: Control


func _ready() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 10
	add_child(_layer)
	for arg in OS.get_cmdline_user_args():
		if arg == "--theme=light":
			Appearance.choice = Appearance.Choice.LIGHT
		elif arg == "--theme=dark":
			Appearance.choice = Appearance.Choice.DARK
	_show_menu()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screen="):
			_debug_screen(arg.trim_prefix("--screen="))


func _show(screen: Control) -> void:
	if _screen != null:
		_screen.queue_free()
	_screen = screen
	_layer.add_child(screen)


func _clear_screen() -> void:
	if _screen != null:
		_screen.queue_free()
		_screen = null


func _show_menu() -> void:
	_end_match()
	var s := MenuScreen.new()
	s.play_pressed.connect(_show_modes)
	s.how_to_play_pressed.connect(
		func() -> void: _show_text("How to play", Copy.how_to_play(), _show_menu)
	)
	s.about_pressed.connect(
		func() -> void: _show_text("About these games", Copy.about(), _show_menu)
	)
	s.settings_pressed.connect(func() -> void: _show_settings(_show_menu))
	_show(s)


func _show_modes() -> void:
	_end_match()
	var s := ModesScreen.new()
	s.back_pressed.connect(_show_menu)
	s.about_pressed.connect(
		func() -> void: _show_text("About these games", Copy.about(), _show_modes)
	)
	s.start_pressed.connect(func(mode_id: StringName) -> void: _start_match(mode_id))
	_show(s)


func _show_text(title: String, sections: Array[Array], back: Callable) -> void:
	var s := TextScreen.new(title, sections)
	s.back_pressed.connect(back)
	_show(s)


func _show_settings(back: Callable) -> void:
	var s := SettingsScreen.new()
	s.back_pressed.connect(back)
	s.appearance_changed.connect(func() -> void: _show_settings(back))
	_show(s)


## Starts a match of `mode_id`, or of the last mode played when none is given (restart, rematch).
func _start_match(mode_id: StringName = &"") -> void:
	if mode_id != &"":
		_mode = mode_id
	_end_match()
	_clear_screen()
	_match = MatchScene.new()
	add_child(_match)
	_match.start(ModeRegistry.profile(_mode), ModeRegistry.rules(_mode))
	_match.pause_requested.connect(_open_pause)
	_match.round_finished.connect(_on_round_finished)
	_match.match_finished.connect(_on_match_finished)


func _end_match() -> void:
	_close_pause()
	if _match != null:
		_match.queue_free()
		_match = null


func _on_round_finished(result: RuleResult, totals: Array[int], round_no: int, rounds: int) -> void:
	if result.kind == &"match":
		return
	var s := RoundResultScreen.new(result, totals, _match.human_side, round_no, rounds)
	s.next_pressed.connect(
		func() -> void:
			_clear_screen()
			_match.controller.continue_after_result()
	)
	_show(s)


func _on_match_finished(ranking: Array[int], details: Array[String]) -> void:
	var s := MatchOverScreen.new(ranking, details, _match.human_side)
	s.rematch_pressed.connect(func() -> void: _start_match())
	s.modes_pressed.connect(_show_modes)
	s.menu_pressed.connect(_show_menu)
	_show(s)


func _open_pause() -> void:
	if _pause != null or _match == null:
		return
	var s := PauseScreen.new()
	s.resume_pressed.connect(_close_pause)
	s.restart_pressed.connect(func() -> void: _start_match())
	s.menu_pressed.connect(_show_menu)
	_pause = s
	_layer.add_child(s)
	get_tree().paused = true


func _close_pause() -> void:
	get_tree().paused = false
	if _pause != null:
		_pause.queue_free()
		_pause = null


## Debug only: `godot --path game -- --screen=modes` opens one screen so it can be photographed.
func _debug_screen(name: String) -> void:
	var sample_points := {0: 3, 1: 2, 2: 1}
	var sample_placing := {0: &"in_kep", 1: &"closest", 2: &"second"}
	match name:
		"modes":
			_show_modes()
		"about":
			_show_text("About these games", Copy.about(), _show_menu)
		"how":
			_show_text("How to play", Copy.how_to_play(), _show_menu)
		"settings":
			_show_settings(_show_menu)
		"result":
			var r := RuleResult.new()
			r.points = sample_points
			r.placing = sample_placing
			_show(RoundResultScreen.new(r, [6, 5, 2] as Array[int], 0, 2, 5))
		"over":
			_show(
				MatchOverScreen.new(
					[0, 2, 1] as Array[int],
					["13 points", "11 points", "9 points"] as Array[String],
					0
				)
			)
		"match", "aim", "pause", "batto", "batto_aim", "batto_top":
			MatchScene.coach_seen = name.ends_with("aim")
			_start_match(&"batto" if name.begins_with("batto") else &"kep")
			if name != "match" and name != "batto":
				await get_tree().create_timer(0.6, false).timeout
			if name == "pause":
				_open_pause()
			if name == "batto_top":
				_match.rig.set_view(CameraRig.View.TOP_DOWN)
				await get_tree().create_timer(1.0, false).timeout
			if name.ends_with("aim"):
				_debug_aim()


func _debug_aim() -> void:
	MatchScene.coach_seen = true
	var m := _match.board.marble(0)
	var from := _match.rig.camera.unproject_position(m.global_position)
	var to := from + Vector2(20.0, 110.0)
	var transform := get_viewport().get_final_transform()
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = transform * from
	Input.parse_input_event(press)
	await get_tree().create_timer(0.2, false).timeout
	var drag := InputEventMouseMotion.new()
	drag.position = transform * to
	drag.relative = to - from
	Input.parse_input_event(drag)
