class_name CameraRig
extends Node3D
## One camera on a pivot, with orbit, zoom, elevation limits, view presets and a reset. Every view
## is the same camera at different values, and nothing here touches the physics or the rules.

enum View { ANGLED, TOP_DOWN, LOW }

const PRESETS := {
	View.ANGLED: {"yaw": 0.0, "pitch": 26.0, "distance": 8.4},
	View.TOP_DOWN: {"yaw": 0.0, "pitch": 88.0, "distance": 9.6},
	View.LOW: {"yaw": 0.0, "pitch": 11.0, "distance": 6.2},
}
const PITCH_MIN := 12.0
const PITCH_MAX := 88.0
const DISTANCE_MIN := 5.0
const DISTANCE_MAX := 12.0
const EASE_SPEED := 8.0
const FIELD_OF_VIEW := 46.0

var camera: Camera3D
var view: View = View.ANGLED
## When set (a ground position), the pivot eases toward it, to follow a marble; else it rests on
## `focus`.
var follow_point: Variant = null
## The ground point the camera looks at, and how far back it stands relative to the default.
var focus: Vector2 = Vector2(0.0, 0.3)
var scale_factor: float = 1.0
## The top-down view's distance when it should show the whole floor (0: the default), and how far
## the view may zoom out.
var overview_distance: float = 0.0
var max_distance: float = 0.0

var _yaw: float = 0.0
var _pitch: float = 26.0
var _distance: float = 8.4
var _target_yaw: float = 0.0
var _target_pitch: float = 26.0
var _target_distance: float = 8.4


func _init() -> void:
	camera = Camera3D.new()
	camera.fov = FIELD_OF_VIEW
	# The arena has to fit the width of a portrait screen, so the field of view is horizontal.
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	add_child(camera)


func _ready() -> void:
	camera.current = true
	_apply()


## Frames a floor from its profile: where to look and how far back to stand. Applied at once,
## without easing.
func frame(profile: RuleProfile) -> void:
	focus = profile.camera_focus
	scale_factor = profile.camera_scale
	overview_distance = profile.camera_overview
	max_distance = profile.camera_max_distance
	set_view(view)
	_yaw = _target_yaw
	_pitch = _target_pitch
	_distance = _target_distance
	position = Vector3(focus.x, 0.0, focus.y)
	_apply()


func set_view(new_view: View) -> void:
	view = new_view
	var p: Dictionary = PRESETS[new_view]
	_target_yaw = p["yaw"]
	_target_pitch = p["pitch"]
	_target_distance = float(p["distance"]) * scale_factor
	if new_view == View.TOP_DOWN and overview_distance > 0.0:
		_target_distance = overview_distance


func reset() -> void:
	set_view(View.ANGLED)


func orbit(delta_yaw_degrees: float, delta_pitch_degrees: float) -> void:
	_target_yaw += delta_yaw_degrees
	_target_pitch = clampf(_target_pitch + delta_pitch_degrees, PITCH_MIN, PITCH_MAX)
	_yaw = _target_yaw
	_pitch = _target_pitch


func zoom(factor: float) -> void:
	_target_distance = clampf(
		_target_distance * factor,
		DISTANCE_MIN * scale_factor,
		maxf(DISTANCE_MAX * scale_factor, max_distance)
	)


func _process(delta: float) -> void:
	var t := clampf(EASE_SPEED * delta, 0.0, 1.0)
	_yaw = lerpf(_yaw, _target_yaw, t)
	_pitch = lerpf(_pitch, _target_pitch, t)
	_distance = lerpf(_distance, _target_distance, t)
	var goal := Vector3(focus.x, 0.0, focus.y)
	if follow_point != null:
		var at := follow_point as Vector2
		goal = Vector3(at.x, 0.0, at.y)
	position = position.lerp(goal, t)
	_apply()


func _apply() -> void:
	var yaw := deg_to_rad(_yaw)
	var pitch := deg_to_rad(_pitch)
	camera.position = Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * _distance
	if camera.is_inside_tree():
		camera.look_at(global_position, Vector3.UP)
