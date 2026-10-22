class_name CameraDirector
extends Node
## Decides where the camera looks during a match. It only reads the match and moves the camera
## rig; it never touches a shot, a result or the physics.
##
## A board bigger than the screen (profile.camera_follow): the camera follows the marble about to
## shoot, looking ahead toward its target, and holds still while aiming. A small board stays
## framed, but while a shot rolls the camera follows it a little and eases back afterwards. In both
## cases the player can turn following off in Settings, or skip it for one shot with a tap.

## How far a small board's camera moves toward a rolling marble (a share of its position).
const ROLL_PULL := 0.6

var rig: CameraRig
var board: Board
var controller: MatchController
var aim: AimController
var rules: RuleSet
var profile: RuleProfile

var _skipped: bool = false


func _init(
	camera_rig: CameraRig,
	game_board: Board,
	match_controller: MatchController,
	aim_controller: AimController,
	rule_set: RuleSet,
	rule_profile: RuleProfile
) -> void:
	rig = camera_rig
	board = game_board
	controller = match_controller
	aim = aim_controller
	rules = rule_set
	profile = rule_profile
	controller.turn_started.connect(func(_side: int, _human: bool) -> void: _skipped = false)


func _process(_delta: float) -> void:
	if controller.state == null:
		return
	if profile.camera_follow:
		_follow_shooter()
	else:
		_follow_roll()


## A tap while a shot rolls skips following for that shot.
func _unhandled_input(event: InputEvent) -> void:
	if not _rolling():
		return
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		_skipped = true
	elif event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
		_skipped = true


func _rolling() -> bool:
	return controller.phase == MatchController.Phase.SHOT_IN_FLIGHT


func _following_the_roll() -> bool:
	return Settings.follow_shots and not _skipped


## A big board: the shooter, looking ahead toward its target. The whole board in the top view.
func _follow_shooter() -> void:
	if rig.view == CameraRig.View.TOP_DOWN and profile.camera_overview > 0.0:
		rig.follow_point = null
		return
	var side := controller.current_side()
	var m := board.marble(side)
	if m == null or aim.mode == AimController.Mode.AIM:
		return
	# With following off, or skipped, the camera stays where it was while the shot rolls.
	if _rolling() and not _following_the_roll():
		return
	var at := m.ground_position()
	var ahead: Variant = rules.aim_point(controller.state, profile, side)
	if controller.phase == MatchController.Phase.WAITING_FOR_SHOT and ahead != null:
		at += ((ahead as Vector2) - at).limit_length(profile.camera_look_ahead)
	var limit := profile.arena_size - Vector2(1.5, 2.0)
	rig.follow_point = Vector2(clampf(at.x, -limit.x, limit.x), clampf(at.y, -limit.y, limit.y))


## A small board: follow the rolling marble a little, then ease back to the framed view.
func _follow_roll() -> void:
	var m := board.marble(controller.current_side())
	if _rolling() and _following_the_roll() and m != null:
		rig.follow_point = m.ground_position() * ROLL_PULL
	else:
		rig.follow_point = null
