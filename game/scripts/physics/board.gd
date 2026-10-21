class_name Board
extends Node3D
## The physical board: the arena, the marbles, one shot at a time, and settle detection. It knows
## nothing about rules, turns or UI. It fires a ShotCommand, waits for everything to stop, and
## reports what rests where and what the shooter touched.

## Emitted once per shot, after the board settles (or the timeout fires).
signal shot_resolved(snapshot: BoardSnapshot, report: ShotReport, timed_out: bool)

enum State { READY, ROLLING, RESETTING }

var state: State = State.READY
var report: ShotReport = ShotReport.new()
var detector: SettleDetector = SettleDetector.new()
var profile: RuleProfile
var scheme: Palette.Scheme

var _marbles: Dictionary = {}
var _badges: Dictionary = {}
var _layout: Array = []


func _init(
	rule_profile: RuleProfile = null, colour_scheme: Palette.Scheme = Palette.Scheme.LIGHT
) -> void:
	profile = rule_profile if rule_profile != null else RuleProfile.bench()
	scheme = colour_scheme


func _ready() -> void:
	add_child(Arena.new(profile, scheme))


## A repeatable starting board for the physics tests: three marbles on a flat arena.
static func default_layout() -> Array:
	return [
		{"id": 0, "side": 0, "pos": Vector2(0.0, 2.0)},
		{"id": 1, "side": 1, "pos": Vector2(0.0, -0.4)},
		{"id": 2, "side": 2, "pos": Vector2(0.9, -1.2)},
	]


## Restores a layout exactly: every marble is held at its place, then all are released on the same
## physics step. The board is RESETTING until then, and a shot is refused. Await it in tests.
func reset(layout: Array) -> void:
	state = State.RESETTING
	_layout = layout
	for id in _marbles.keys():
		if not layout.any(func(e: Dictionary) -> bool: return e["id"] == id):
			remove_marble(id)
	for entry in layout:
		var m: Marble = _marbles.get(entry["id"])
		if m == null:
			m = _spawn(entry["id"], entry["side"], entry["pos"])
		m.hold_at(entry["pos"])
	detector.reset()
	report = ShotReport.new()
	await get_tree().physics_frame
	for id in _marbles:
		_marbles[id].release()
	state = State.READY


## Adds a marble at rest at a ground position (it must not overlap another marble).
func place(id: int, side: int, pos: Vector2) -> Marble:
	return _spawn(id, side, pos)


func remove_marble(id: int) -> void:
	if _marbles.has(id):
		_marbles[id].queue_free()
		_marbles.erase(id)
	if _badges.has(id):
		_badges[id].queue_free()
		_badges.erase(id)


func clear_marbles() -> void:
	for id in _marbles.keys():
		remove_marble(id)


func marble(id: int) -> Marble:
	return _marbles.get(id)


func marble_count() -> int:
	return _marbles.size()


## Fires one shot. Refused unless the board is READY and the command is valid.
func fire(command: ShotCommand) -> bool:
	if state != State.READY or not command.is_valid() or not _marbles.has(command.marble_id):
		return false
	report = ShotReport.new()
	report.shooter_id = command.marble_id
	detector.reset()
	state = State.ROLLING
	ShotApplier.apply(_marbles[command.marble_id], command)
	return true


func snapshot() -> BoardSnapshot:
	var snap := BoardSnapshot.new()
	for id in _marbles:
		var m: Marble = _marbles[id]
		snap.add(id, m.side, m.ground_position())
	return snap


func _physics_process(delta: float) -> void:
	if state != State.ROLLING:
		return
	var linear := PackedFloat32Array()
	var angular := PackedFloat32Array()
	for id in _marbles:
		var m: Marble = _marbles[id]
		linear.append(m.linear_velocity.length())
		angular.append(m.angular_velocity.length())
	detector.feed(delta, linear, angular)
	if detector.is_settled():
		_resolve()


func _resolve() -> void:
	var timed_out := detector.timed_out
	if timed_out:
		for id in _marbles:
			_marbles[id].linear_velocity = Vector3.ZERO
			_marbles[id].angular_velocity = Vector3.ZERO
	state = State.READY
	shot_resolved.emit(snapshot(), report, timed_out)


func _spawn(id: int, side: int, at: Vector2) -> Marble:
	var m := Marble.new()
	m.setup(id, side, SideStyle.colour(side, scheme))
	m.position = Vector3(at.x, Tuning.MARBLE_RADIUS, at.y)
	m.touched_marble.connect(_on_touched)
	add_child(m)
	_marbles[id] = m
	var badge := MarbleBadge.new(m, side, scheme)
	add_child(badge)
	_badges[id] = badge
	return m


func _on_touched(first: Marble, other: Marble) -> void:
	if state != State.ROLLING:
		return
	if first.marble_id == report.shooter_id:
		report.add_touch(other.marble_id)
	elif other.marble_id == report.shooter_id:
		report.add_touch(first.marble_id)
