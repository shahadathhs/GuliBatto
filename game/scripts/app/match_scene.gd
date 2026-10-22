class_name MatchScene
extends Node
## One match on screen: the 3D world (arena, marbles, camera, light), the aim controller, the match
## controller and the HUD, wired together. The app creates one per match and frees it afterwards.

signal pause_requested
signal round_finished(result: RuleResult, totals: Array[int], round_no: int, rounds: int)
signal match_finished(ranking: Array[int], details: Array[String])

## The first-use prompt is shown once per run.
static var coach_seen: bool = false

var profile: RuleProfile
var rules: RuleSet
var board: Board
var rig: CameraRig
var controller: MatchController
var aim: AimController
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
	_connect()
	hud.highlight_view(CameraRig.View.ANGLED)
	controller.start(board, profile, rules, human_side)
	hud.set_mode_caption(rules.caption(controller.state, profile))
	hud.set_standings(rules.standings(controller.state), human_side)


func _process(_delta: float) -> void:
	if profile.camera_follow and controller != null and controller.state != null:
		_follow_shooter()


## A board bigger than the screen: the camera follows the marble about to shoot, looking ahead
## toward its target. It holds still while aiming (the aim is read from the ground under the
## finger) and shows the whole board from the top-down view.
func _follow_shooter() -> void:
	if rig.view == CameraRig.View.TOP_DOWN and profile.camera_overview > 0.0:
		rig.follow_point = null
		return
	var side := controller.current_side()
	var m := board.marble(side)
	if m == null or aim.mode == AimController.Mode.AIM:
		return
	var at := m.ground_position()
	var ahead: Variant = rules.aim_point(controller.state, profile, side)
	if controller.phase == MatchController.Phase.WAITING_FOR_SHOT and ahead != null:
		at += ((ahead as Vector2) - at).limit_length(profile.camera_look_ahead)
	var limit := profile.arena_size - Vector2(1.5, 2.0)
	rig.follow_point = Vector2(clampf(at.x, -limit.x, limit.x), clampf(at.y, -limit.y, limit.y))


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
	controller.shot_judged.connect(_on_shot_judged)
	controller.round_scored.connect(_on_round_scored)
	controller.match_over.connect(_on_match_over)


func _on_turn_started(side: int, is_human: bool) -> void:
	var state := controller.state
	hud.set_mode_caption(rules.caption(state, profile))
	hud.set_turn(side, rules.turn_text(state, is_human))
	hud.set_standings(rules.standings(state), human_side)
	if is_human:
		hud.show_camera_bar()
		if not coach_seen:
			hud.show_coach()
	else:
		hud.show_waiting("Waiting for their shot")


func _on_shot_started(_side: int) -> void:
	hud.show_waiting("Rolling")


func _on_aim_changed(active: bool, power: float) -> void:
	if active:
		coach_seen = true
		hud.hide_coach()
		hud.show_aim(power)
	elif controller.phase == MatchController.Phase.WAITING_FOR_SHOT:
		hud.show_camera_bar()


func _on_shot_judged(_side: int, result: RuleResult) -> void:
	hud.show_cue(rules.cue_text(result, profile, board.snapshot()))


func _on_round_scored(result: RuleResult, _totals: Array[int]) -> void:
	var state := controller.state
	hud.set_standings(rules.standings(state), human_side)
	round_finished.emit(result, state.totals, state.round_index, state.rounds)


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
