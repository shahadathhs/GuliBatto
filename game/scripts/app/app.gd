class_name App
extends Node
## The shell: shows the menu and the pages, starts a match, and moves between the match, its
## result screens and back. One screen is on the UI layer at a time; a match lives beside it.

var _layer: CanvasLayer
var _screen: Control
var _match: MatchScene
var _mode: StringName = &"kep"
## Who plays the match being started or played; chosen on the "Who plays?" screen.
var _setup: MatchSetup = MatchSetup.solo()
var _pause: Control


func _ready() -> void:
	Settings.load_from_disk()
	add_child(Sfx.new())
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
			AppDebug.open(self, arg.trim_prefix("--screen="))


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
	s.how_to_play_pressed.connect(func() -> void: _show_page("how_to_play", _show_menu))
	s.about_pressed.connect(func() -> void: _show_page("about", _show_menu))
	s.settings_pressed.connect(func() -> void: _show_settings(_show_menu))
	_show(s)


func _show_modes() -> void:
	_end_match()
	var s := ModesScreen.new()
	s.back_pressed.connect(_show_menu)
	s.about_pressed.connect(func() -> void: _show_page("about", _show_modes))
	s.rules_pressed.connect(
		func(mode_id: StringName) -> void: _show_page(ModeRegistry.page_id(mode_id), _show_modes)
	)
	s.start_pressed.connect(_choose_players)
	_show(s)


## A page of the shared content. A link on it opens another page (and comes back to this one) or a
## web address. `back` is where this page's back button goes.
func _show_page(page_id: String, back: Callable) -> void:
	_show(_page(page_id, back, _show))


func _page(page_id: String, back: Callable, place: Callable) -> PageScreen:
	var s := PageScreen.new(page_id)
	s.back_pressed.connect(back)
	s.link_pressed.connect(
		func(target: String) -> void:
			var here := func() -> void: place.call(_page(page_id, back, place))
			_follow_link(target, here, place)
	)
	return s


func _follow_link(target: String, back_here: Callable, place: Callable) -> void:
	var parts := target.split(":", true, 1)
	if parts[0] == "page":
		place.call(_page(parts[1], back_here, place))
	elif parts[0] == "url":
		OS.shell_open(Content.link(parts[1]))


## After the game is chosen, who plays: the computer or people passing the device.
func _choose_players(mode_id: StringName) -> void:
	var s := WhoPlaysScreen.new()
	s.back_pressed.connect(_show_modes)
	s.play_pressed.connect(
		func(chosen: MatchSetup) -> void:
			_setup = chosen
			_play(mode_id)
	)
	_show(s)


## The first time a game is started its rules card comes first; after that it starts at once.
func _play(mode_id: StringName) -> void:
	if Settings.has_seen_rules(mode_id):
		_start_match(mode_id)
		return
	var s := RulesCard.new(mode_id, "Start", true)
	s.back_pressed.connect(_choose_players.bind(mode_id))
	s.primary_pressed.connect(
		func() -> void:
			Settings.mark_rules_seen(mode_id)
			_start_match(mode_id)
	)
	s.full_rules_pressed.connect(
		func() -> void: _show_page(ModeRegistry.page_id(mode_id), _play.bind(mode_id))
	)
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
	# Connected before the match starts: pass and play asks for the first hand-over at once.
	_match.handover_requested.connect(_show_handover)
	_match.pause_requested.connect(_open_pause)
	_match.help_requested.connect(_open_help)
	_match.round_finished.connect(_on_round_finished)
	_match.match_finished.connect(_on_match_finished)
	_match.start(ModeRegistry.profile(_mode), ModeRegistry.rules(_mode), _setup)


func _end_match() -> void:
	_close_pause()
	if _match != null:
		_match.queue_free()
		_match = null


func _on_round_finished(
	result: RuleResult, totals: Array[int], caption: String, total_word: String
) -> void:
	if result.kind == &"match":
		return
	var s := RoundResultScreen.new(result, totals, _match.setup, caption, total_word)
	s.next_pressed.connect(
		func() -> void:
			_clear_screen()
			_match.controller.continue_after_result()
	)
	_show(s)


func _on_match_finished(ranking: Array[int], details: Array[String]) -> void:
	var s := MatchOverScreen.new(ranking, details, _match.setup)
	s.rematch_pressed.connect(func() -> void: _start_match())
	s.modes_pressed.connect(_show_modes)
	s.menu_pressed.connect(_show_menu)
	_show(s)


func _open_pause() -> void:
	if _pause != null or _match == null:
		return
	var s := PauseScreen.new(_give_up_label())
	s.surrender_pressed.connect(
		func() -> void:
			_close_pause()
			_match.controller.give_up()
	)
	s.resume_pressed.connect(_close_pause)
	s.restart_pressed.connect(func() -> void: _start_match())
	s.menu_pressed.connect(_show_menu)
	_pause = s
	_layer.add_child(s)
	get_tree().paused = true


## What the pause menu calls ending the match: a surrender against the computer where the rules
## allow one, and "End the match" in pass and play.
func _give_up_label() -> String:
	if _match.setup.hands_over():
		return "End the match"
	return "Surrender" if _match.rules.can_surrender() else ""


## Pass and play: the next person takes the device, then the turn goes on.
func _show_handover(side: int) -> void:
	var s := HandoverScreen.new(side, _match.rules.caption(_match.controller.state, _match.profile))
	s.ready_pressed.connect(
		func() -> void:
			_clear_screen()
			_match.controller.confirm_handover()
	)
	_show(s)


## The "?" in a match: the rules card over the paused match, with the full rules a tap away.
func _open_help() -> void:
	if _pause != null or _match == null:
		return
	_show_help_card()
	get_tree().paused = true


func _show_help_card() -> void:
	var s := RulesCard.new(_mode, "Back to match")
	s.primary_pressed.connect(_close_pause)
	s.full_rules_pressed.connect(
		func() -> void:
			_put_overlay(_page(ModeRegistry.page_id(_mode), _show_help_card, _put_overlay))
	)
	_put_overlay(s)


## Replaces the overlay over the match (the pause menu, the rules card, a page) with another.
func _put_overlay(screen: Control) -> void:
	screen.process_mode = Node.PROCESS_MODE_ALWAYS
	if _pause != null:
		_pause.queue_free()
	_pause = screen
	_layer.add_child(screen)


func _close_pause() -> void:
	get_tree().paused = false
	if _pause != null:
		_pause.queue_free()
		_pause = null
