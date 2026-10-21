class_name MatchScene
extends Node
## One match on screen: the 3D world (arena, marbles, camera, light), the aim controller, the match
## controller and the HUD, wired together. The app creates one per match and frees it afterwards.

signal pause_requested
signal round_finished(result: RuleResult, totals: Array[int], round_no: int, rounds: int)
signal match_finished(ranking: Array[int], totals: Array[int])

## The first-use prompt is shown once per run.
static var coach_seen: bool = false

var profile: RuleProfile
var board: Board
var rig: CameraRig
var controller: MatchController
var aim: AimController
var hud: Hud
var human_side: int = 0


func start(rule_profile: RuleProfile, rules: RuleSet) -> void:
	profile = rule_profile
	var scheme := Appearance.scheme()
	_build_environment(scheme)
	board = Board.new(profile, scheme)
	add_child(board)
	rig = CameraRig.new()
	add_child(rig)
	var visual := AimVisual.new(scheme)
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
	_connect()
	hud.set_mode_caption("Kep · round 1 of %d" % profile.rounds)
	hud.highlight_view(CameraRig.View.ANGLED)
	controller.start(board, profile, rules, human_side)
	hud.set_scores(controller.state.totals, human_side)


func cancel_aim() -> void:
	aim.cancel()


func _connect() -> void:
	hud.pause_pressed.connect(
		func() -> void:
			aim.cancel()
			pause_requested.emit()
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
	hud.coach_dismissed.connect(func() -> void: coach_seen = true)
	aim.aim_changed.connect(_on_aim_changed)
	controller.turn_started.connect(_on_turn_started)
	controller.shot_started.connect(_on_shot_started)
	controller.toss_resolved.connect(_on_toss_resolved)
	controller.round_scored.connect(_on_round_scored)
	controller.match_over.connect(_on_match_over)


func _on_turn_started(side: int, is_human: bool) -> void:
	var state := controller.state
	hud.set_mode_caption("Kep · round %d of %d" % [state.round_index + 1, state.rounds])
	hud.set_turn(side, "Your toss" if is_human else "Their toss")
	hud.set_scores(state.totals, human_side)
	if is_human:
		hud.show_camera_bar()
		if not coach_seen:
			hud.show_coach()
	else:
		hud.show_waiting("Waiting for their toss")


func _on_shot_started(_side: int) -> void:
	hud.show_waiting("Rolling")


func _on_aim_changed(active: bool, power: float) -> void:
	if active:
		coach_seen = true
		hud.hide_coach()
		hud.show_aim(power)
	elif controller.phase == MatchController.Phase.WAITING_FOR_SHOT:
		hud.show_camera_bar()


func _on_toss_resolved(side: int) -> void:
	var snap := board.snapshot()
	var d := snap.position_of(side).distance_to(profile.holes[0])
	var text := "In the kep" if d <= Tuning.KEP_RADIUS else "%.1f m from the kep" % d
	hud.show_cue(text)


func _on_round_scored(result: RuleResult, totals: Array[int]) -> void:
	var state := controller.state
	hud.set_scores(totals, human_side)
	var round_no := state.round_index if result.kind == &"match" else state.round_index
	round_finished.emit(result, totals, round_no, state.rounds)


func _on_match_over(ranking: Array[int]) -> void:
	match_finished.emit(ranking, controller.state.totals)


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
