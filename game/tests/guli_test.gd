class_name GuliTest
extends GutTest
## Shared setup for the Guli Khela rule tests: hand-built boards, no physics. A throwing marble's
## id is its side; the stake and the fines have ids from 100 and belong to no side.

var profile: RuleProfile
var rules: GuliRules
var state: GuliState
var kep: Vector2
var spots: Dictionary = {}


func before_each() -> void:
	_new_match(RuleProfile.guli(), 3)


func _new_match(p: RuleProfile, sides: int) -> void:
	profile = p
	rules = GuliRules.new()
	state = rules.start(profile, sides) as GuliState
	rules.seed_state(state, 1234)
	kep = profile.holes[0]
	spots = {}


func _report(shooter: int, touched: Array = [], baad: int = -1) -> ShotReport:
	var report := ShotReport.new()
	report.shooter_id = shooter
	report.baad_id = baad
	for id in touched:
		report.add_touch(id)
	return report


## Everyone tosses; `distances` is how far each side's marble rests from the kep.
func _toss(distances: Array) -> RuleResult:
	var snap := BoardSnapshot.new()
	for side in distances.size():
		snap.add(side, side, kep + Vector2(distances[side], 0.0))
	var last: RuleResult
	for side in distances.size():
		last = rules.evaluate(state, profile, snap, _report(side))
	_remember(last)
	return last


func _remember(result: RuleResult) -> void:
	for placed in result.place_marbles:
		spots[placed["id"]] = placed["pos"]


## The board as it is when a throw has settled: the ground marbles where they were set down.
func _snapshot(thrower: int) -> BoardSnapshot:
	var snap := BoardSnapshot.new()
	snap.add(thrower, thrower, Vector2(0.0, 2.0))
	for id in state.ground:
		snap.add(id, SideStyle.NEUTRAL, spots[id])
	return snap


func _throw(touched: Array, baad: int) -> RuleResult:
	var side := state.current_side()
	var result := rules.evaluate(state, profile, _snapshot(side), _report(side, touched, baad))
	_remember(result)
	return result


## Starts a dan: the toss, with side 0 closest, so side 0 scatters and 1 and 2 attempt.
func _scatter() -> RuleResult:
	return _toss([0.1, 1.0, 2.0])
