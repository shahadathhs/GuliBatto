class_name RuleSet
extends RefCounted
## The interface every mode implements. A ruleset reads a profile, the state the match keeps, the
## settled board and the shot report, and decides. It never touches nodes. The text methods say
## what the HUD and the result screens show, so the UI holds no mode branches.


func start(_profile: RuleProfile, _side_count: int) -> MatchState:
	return MatchState.new()


## Where the current side's marble starts its turn, given what already rests on the board. Only
## asked when the side has no marble on the board yet.
func spawn_position(_state: MatchState, _profile: RuleProfile, _snapshot: BoardSnapshot) -> Vector2:
	return Vector2.ZERO


## Called once per shot, after the board settles. Updates the state and says what happened.
func evaluate(
	_state: MatchState, _profile: RuleProfile, _snapshot: BoardSnapshot, _report: ShotReport
) -> RuleResult:
	return RuleResult.new()


## Sides best first, once the match is over.
func ranking(state: MatchState) -> Array[int]:
	return state.ranking()


## The computer side that plays this mode.
func make_ai(seed_value: int) -> TossAI:
	return TossAI.new(seed_value)


## A short line over the arena: the mode and where the match is.
func caption(_state: MatchState, profile: RuleProfile) -> String:
	return profile.title


## What the turn label says for the side about to shoot.
func turn_text(_state: MatchState, is_human: bool) -> String:
	return "Your shot" if is_human else "Their shot"


## One short label per side for the scoreboard chips.
func standings(state: MatchState) -> Array[String]:
	var out: Array[String] = []
	for side in state.side_count:
		out.append(str(state.totals[side]))
	return out


## The cue shown when a shot has been judged and play goes on.
func cue_text(_result: RuleResult, _profile: RuleProfile, _snapshot: BoardSnapshot) -> String:
	return ""


## One line per side for the match-over screen.
func final_text(state: MatchState, side: int) -> String:
	return "%d points" % state.totals[side]
