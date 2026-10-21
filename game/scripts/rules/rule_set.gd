class_name RuleSet
extends RefCounted
## The interface every mode implements. A ruleset reads a profile, the state the match keeps, the
## settled board and the shot report, and decides. It never touches nodes.


func start(_profile: RuleProfile, _side_count: int) -> MatchState:
	return MatchState.new()


## Where the current side's marble starts its turn, given what already rests on the board.
func spawn_position(_state: MatchState, _profile: RuleProfile, _snapshot: BoardSnapshot) -> Vector2:
	return Vector2.ZERO


## Called once per shot, after the board settles. Updates the state and says what happened.
func evaluate(
	_state: MatchState, _profile: RuleProfile, _snapshot: BoardSnapshot, _report: ShotReport
) -> RuleResult:
	return RuleResult.new()
