class_name MatchScene
extends Node
## One match on screen: the 3D world (arena, marbles, camera, light), the aim controller, the match
## controller and the HUD, wired together. The app creates one per match and frees it afterwards.

signal pause_requested
signal help_requested
signal round_finished(result: RuleResult, totals: Array[int], caption: String, total_word: String)
signal match_finished(ranking: Array[int], details: Array[String])

var profile: RuleProfile
var rules: RuleSet
var board: Board
var rig: CameraRig
var controller: MatchController
var aim: AimController
var director: CameraDirector
var baad_marker: BaadMarker
var hud: Hud
var human_side: int = 0


func start(rule_profile: RuleProfile, rule_set: RuleSet) -> void:
	profile = rule_profile
	rules = rule_set
	var scheme := Appearance.scheme()
	_build_environment(scheme)
	board = Board.new(profile, scheme)
	add_child(board)
	rig = CameraRig.new()
	add_child(rig)
	rig.frame(profile)
	var visual := AimVisual.new(scheme, profile.marble_radius)
	add_child(visual)
	controller = MatchController.new()
	add_child(controller)
	aim = AimController.new(rig, board, controller, visual)
	add_child(aim)
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	hud = Hud.new()
	layer.add_child(hud)
	director = CameraDirector.new(rig, board, controller, aim, rules, profile)
	add_child(director)
	add_child(SoundDirector.new(board, controller))
	baad_marker = BaadMarker.new(scheme, profile.marble_radius)
	add_child(baad_marker)
	_connect()
	hud.highlight_view(CameraRig.View.ANGLED)
	controller.start(board, profile, rules, human_side)
	hud.set_mode_caption(rules.caption(controller.state, profile))
	hud.set_standings(rules.standings(controller.state), human_side)


func cancel_aim() -> void:
	aim.cancel()


func _connect() -> void:
	hud.pause_pressed.connect(
		func() -> void:
			aim.cancel()
			pause_requested.emit()
	)
	hud.help_pressed.connect(
		func() -> void:
			aim.cancel()
			help_requested.emit()
	)
	hud.view_selected.connect(
		func(v: CameraRig.View) -> void:
			rig.set_view(v)
			hud.highlight_view(v)
	)
	hud.reset_pressed.connect(
		func() -> void:
			rig.reset()
			hud.highlight_view(CameraRig.View.ANGLED)
	)
	hud.cancel_aim_pressed.connect(aim.cancel)
	hud.coach_dismissed.connect(Settings.mark_coach_seen)
	aim.aim_changed.connect(_on_aim_changed)
	controller.turn_started.connect(_on_turn_started)
	controller.shot_started.connect(_on_shot_started)
	controller.shot_judged.connect(_on_shot_judged)
	controller.baad_needed.connect(_on_baad_needed)
	controller.baad_named.connect(_on_baad_named)
	controller.round_scored.connect(_on_round_scored)
	controller.match_over.connect(_on_match_over)


func _on_turn_started(side: int, is_human: bool) -> void:
	var state := controller.state
	baad_marker.clear()
	hud.set_hint("")
	hud.set_mode_caption(rules.caption(state, profile))
	hud.set_turn(side, rules.turn_text(state, is_human))
	hud.set_standings(rules.standings(state), human_side)
	if is_human:
		hud.show_camera_bar()
		if not Settings.coach_seen:
			hud.show_coach()
	else:
		hud.show_waiting("Waiting for their shot")


func _on_baad_needed() -> void:
	baad_marker.clear()
	hud.set_hint("Tap the marble you must not touch: the baad")


func _on_baad_named(marble_id: int) -> void:
	baad_marker.show_on(board.marble(marble_id))
	hud.set_hint("Baad named. Tap another to change it, or pull back to throw")


func _on_shot_started(_side: int) -> void:
	hud.set_hint("")
	# Whoever throws, the baad stays marked while the marble rolls.
	if controller.last_baad >= 0:
		baad_marker.show_on(board.marble(controller.last_baad))
	hud.show_waiting("Rolling")


func _on_aim_changed(active: bool, power: float) -> void:
	if active:
		Settings.mark_coach_seen()
		hud.hide_coach()
		hud.show_aim(power)
	elif controller.phase == MatchController.Phase.WAITING_FOR_SHOT:
		hud.show_camera_bar()


func _on_shot_judged(_side: int, result: RuleResult) -> void:
	hud.show_cue(rules.cue_text(result, profile, board.snapshot()))


func _on_round_scored(result: RuleResult, _totals: Array[int]) -> void:
	var state := controller.state
	hud.set_standings(rules.standings(state), human_side)
	var shown := result.totals if not result.totals.is_empty() else state.totals
	round_finished.emit(result, shown, rules.round_caption(state), rules.total_word())


func _on_match_over(ranking: Array[int]) -> void:
	var details: Array[String] = []
	for side in controller.state.side_count:
		details.append(rules.final_text(controller.state, side))
	match_finished.emit(ranking, details)


func _build_environment(scheme: Palette.Scheme) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Palette.get_color(&"ground", scheme)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Palette.get_color(&"highlight", scheme)
	env.ambient_light_energy = 0.55
	var world := WorldEnvironment.new()
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-58.0, 25.0, 0.0)
	sun.light_energy = 0.9
	add_child(sun)
