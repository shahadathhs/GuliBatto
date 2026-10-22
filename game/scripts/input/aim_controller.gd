class_name AimController
extends Node
## Turns pointer input into a shot or a camera move. The gesture is decided when it starts and
## kept until it ends:
##   press on the active marble's handle -> aim (slingshot: pull back, release to shoot)
##   press on empty ground, or right/middle button -> orbit the camera
##   two fingers, or the wheel -> zoom
## The aim is computed in world space on the ground plane, so the same pull gives the same shot
## from every camera view.

signal aim_changed(active: bool, power: float)

enum Mode { NONE, AIM, ORBIT, PINCH }

## Screen distance from the marble within which a press grabs it, much larger than the marble.
const HANDLE_PIXELS := 56.0
## Screen distance within which a tap names a marble as baad.
const BAAD_PIXELS := 40.0
const ORBIT_DEGREES_PER_PIXEL := 0.3
const ZOOM_STEP := 0.92

var rig: CameraRig
var board: Board
var match_controller: MatchController
var visual: AimVisual
var mode: Mode = Mode.NONE

var _direction: Vector2 = Vector2.UP
var _power: float = 0.0
var _touches: Dictionary = {}
var _pinch_distance: float = 0.0


func _init(
	camera_rig: CameraRig, game_board: Board, controller: MatchController, aim_visual: AimVisual
) -> void:
	rig = camera_rig
	board = game_board
	match_controller = controller
	visual = aim_visual


func cancel() -> void:
	if mode == Mode.AIM:
		_end_aim()
	mode = Mode.NONE


func _process(_delta: float) -> void:
	var m := _active_marble()
	if m != null and match_controller.phase == MatchController.Phase.WAITING_FOR_SHOT:
		visual.show_ring(m.ground_position())
	else:
		visual.hide_ring()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_on_touch(event)
	elif event is InputEventScreenDrag:
		_on_drag(event)
	elif event is InputEventMouseButton:
		_on_button(event)
	elif event is InputEventMouseMotion:
		_on_motion(event)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		cancel()


func _on_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touches[event.index] = event.position
	else:
		_touches.erase(event.index)
	if _touches.size() >= 2:
		cancel()
		mode = Mode.PINCH
		_pinch_distance = _touch_spread()
	elif mode == Mode.PINCH and _touches.size() < 2:
		mode = Mode.NONE


func _on_drag(event: InputEventScreenDrag) -> void:
	_touches[event.index] = event.position
	if mode == Mode.PINCH and _touches.size() >= 2:
		var spread := _touch_spread()
		if _pinch_distance > 1.0 and spread > 1.0:
			rig.zoom(_pinch_distance / spread)
		_pinch_distance = spread


func _on_button(event: InputEventMouseButton) -> void:
	if mode == Mode.PINCH:
		return
	if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		rig.zoom(ZOOM_STEP)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		rig.zoom(1.0 / ZOOM_STEP)
	elif event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_press(event.position)
		else:
			_release()
	elif event.button_index in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		if event.pressed and mode == Mode.NONE:
			mode = Mode.ORBIT
		elif not event.pressed and mode == Mode.ORBIT:
			mode = Mode.NONE


func _on_motion(event: InputEventMouseMotion) -> void:
	if mode == Mode.AIM:
		_update_aim(event.position)
	elif mode == Mode.ORBIT:
		rig.orbit(
			-event.relative.x * ORBIT_DEGREES_PER_PIXEL, event.relative.y * ORBIT_DEGREES_PER_PIXEL
		)


func _press(screen: Vector2) -> void:
	if mode != Mode.NONE:
		return
	var handle := _handle_distance(screen)
	var pick := _baad_pick(screen)
	# A tap on a marble that can be named names it, unless the shooter's own marble is nearer.
	if not pick.is_empty() and pick["distance"] <= BAAD_PIXELS and pick["distance"] < handle:
		match_controller.name_baad(pick["id"])
		return
	if handle <= HANDLE_PIXELS:
		mode = Mode.AIM
		_update_aim(screen)
	else:
		mode = Mode.ORBIT


func _release() -> void:
	if mode == Mode.AIM:
		_fire()
	mode = Mode.NONE


## How far, on screen, a press is from the shooter's marble; infinite when it cannot be grabbed.
func _handle_distance(screen: Vector2) -> float:
	if not match_controller.is_human_turn():
		return INF
	var m := _active_marble()
	if m == null:
		return INF
	return rig.camera.unproject_position(m.global_position).distance_to(screen)


## The marble that could be named as baad nearest the press: {"id", "distance"}, or empty.
func _baad_pick(screen: Vector2) -> Dictionary:
	if not match_controller.can_name_baad():
		return {}
	var best := {}
	for id in match_controller.baad_choices():
		var m := board.marble(id)
		if m == null:
			continue
		var d := rig.camera.unproject_position(m.global_position).distance_to(screen)
		if best.is_empty() or d < best["distance"]:
			best = {"id": id, "distance": d}
	return best


func _active_marble() -> Marble:
	if match_controller.state == null:
		return null
	return board.marble(match_controller.current_side())


## The point on the ground (marble-centre height) under a screen position.
func _ground_point(screen: Vector2) -> Vector2:
	var origin := rig.camera.project_ray_origin(screen)
	var normal := rig.camera.project_ray_normal(screen)
	var hit: Variant = Plane(Vector3.UP, board.profile.marble_radius).intersects_ray(origin, normal)
	if hit == null:
		return Vector2.ZERO
	return Vector2((hit as Vector3).x, (hit as Vector3).z)


func _update_aim(screen: Vector2) -> void:
	var m := _active_marble()
	if m == null:
		return
	var from := m.ground_position()
	var pointer := _ground_point(screen)
	var pull := pointer - from
	_power = clampf(pull.length() / board.profile.max_pull, 0.0, 1.0)
	if pull.length() > 0.001:
		_direction = (-pull).normalized()
	if _power < Tuning.AIM_DEAD_ZONE:
		visual.clear()
	else:
		# The pull line ends at the finger, but no farther than full pull.
		var shown := from + pull.limit_length(board.profile.max_pull)
		visual.show_aim(from, _direction, _power, shown)
	aim_changed.emit(true, _power)


func _fire() -> void:
	var side := match_controller.current_side()
	var fired := false
	if _power >= Tuning.AIM_DEAD_ZONE:
		fired = match_controller.submit_shot(ShotCommand.create(side, side, _direction, _power))
	_end_aim()
	if not fired:
		return


func _end_aim() -> void:
	_power = 0.0
	visual.clear()
	aim_changed.emit(false, 0.0)


func _touch_spread() -> float:
	var points: Array = _touches.values()
	return (points[0] as Vector2).distance_to(points[1] as Vector2)
