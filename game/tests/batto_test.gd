class_name BattoTest
extends GutTest
## Shared setup for the Batto rule tests: hand-built boards, no physics. Marble ids equal side
## indices.

var profile: RuleProfile
var rules: BattoRules
var state: BattoState
var h1: Vector2
var h2: Vector2
var h3: Vector2
var far: Vector2 = Vector2(2.0, 1.5)
var r: float


func before_each() -> void:
	profile = RuleProfile.batto()
	rules = BattoRules.new()
	state = rules.start(profile, profile.side_count) as BattoState
	h1 = profile.holes[0]
	h2 = profile.holes[1]
	h3 = profile.holes[2]
	r = profile.hole_radius


func _board(positions: Array) -> BoardSnapshot:
	var snap := BoardSnapshot.new()
	for i in positions.size():
		if positions[i] != null:
			snap.add(i, i, positions[i])
	return snap


func _report(shooter: int, touched: Array = []) -> ShotReport:
	var report := ShotReport.new()
	report.shooter_id = shooter
	for id in touched:
		report.add_touch(id)
	return report


## Plays the opening toss with every marble resting at `positions`, and starts the race.
func _open(positions: Array) -> void:
	var snap := _board(positions)
	for side in positions.size():
		rules.evaluate(state, profile, snap, _report(side))


## Shoots for the side on turn: its marble ends at `at`, touching `touched`.
func _shoot(positions: Array, touched: Array = []) -> RuleResult:
	var side := state.current_side()
	return rules.evaluate(state, profile, _board(positions), _report(side, touched))
