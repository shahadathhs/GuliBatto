class_name CameraRig
extends Node3D
## One camera on a pivot, with orbit, zoom, elevation limits, view presets and a reset. Every view
## is the same camera at different values, and nothing here touches the physics or the rules.

enum View { ANGLED, TOP_DOWN, LOW }

const PRESETS := {
	View.ANGLED: {"yaw": 0.0, "pitch": 52.0, "distance": 9.6},
	View.TOP_DOWN: {"yaw": 0.0, "pitch": 88.0, "distance": 9.6},
	View.LOW: {"yaw": 0.0, "pitch": 16.0, "distance": 7.5},
}
const PITCH_MIN := 12.0
const PITCH_MAX := 88.0
const DISTANCE_MIN := 5.0
const DISTANCE_MAX := 12.0
const EASE_SPEED := 8.0
const FIELD_OF_VIEW := 46.0

var camera: Camera3D
var view: View = View.ANGLED
## When set, the pivot eases toward this world position (shot-follow); else it rests mid-arena.
var follow_point: Variant = null

var _yaw: float = 0.0
var _pitch: float = 52.0
var _distance: float = 9.6
var _target_yaw: float = 0.0
var _target_pitch: float = 52.0
var _target_distance: float = 9.6


func _init() -> void:
	camera = Camera3D.new()
	camera.fov = FIELD_OF_VIEW
	# The arena has to fit the width of a portrait screen, so the field of view is horizontal.
	camera.keep_aspect = Camera3D.KEEP_WIDTH
	add_child(camera)


func _ready() -> void:
	camera.current = true
	_apply()


func set_view(new_view: View) -> void:
	view = new_view
	var p: Dictionary = PRESETS[new_view]
	_target_yaw = p["yaw"]
	_target_pitch = p["pitch"]
	_target_distance = p["distance"]


func reset() -> void:
	set_view(View.ANGLED)


func orbit(delta_yaw_degrees: float, delta_pitch_degrees: float) -> void:
	_target_yaw += delta_yaw_degrees
	_target_pitch = clampf(_target_pitch + delta_pitch_degrees, PITCH_MIN, PITCH_MAX)
	_yaw = _target_yaw
	_pitch = _target_pitch


func zoom(factor: float) -> void:
	_target_distance = clampf(_target_distance * factor, DISTANCE_MIN, DISTANCE_MAX)


func _process(delta: float) -> void:
	var t := clampf(EASE_SPEED * delta, 0.0, 1.0)
	_yaw = lerpf(_yaw, _target_yaw, t)
	_pitch = lerpf(_pitch, _target_pitch, t)
	_distance = lerpf(_distance, _target_distance, t)
	var goal := Vector3(0.0, 0.0, 0.3)
	if follow_point != null:
		goal = (follow_point as Vector3) * 0.6
	position = position.lerp(goal, t)
	_apply()


func _apply() -> void:
	var yaw := deg_to_rad(_yaw)
	var pitch := deg_to_rad(_pitch)
	camera.position = Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * _distance
	if camera.is_inside_tree():
		camera.look_at(global_position, Vector3.UP)
